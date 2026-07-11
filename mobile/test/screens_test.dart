import 'dart:convert';

import 'package:cobrewer_mobile/api/client.dart';
import 'package:cobrewer_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

/// Fake backend routing the same paths as the real API.
ApiClient fakeApi({List<http.Request>? sink}) {
  return ApiClient(
    baseUrl: 'http://test',
    httpClient: MockClient((req) async {
      sink?.add(req);
      final path = req.url.path;
      Object? body;
      Map<String, dynamic>? meta;
      if (path == '/api/v1/beans') {
        final search = req.url.queryParameters['search'] ?? '';
        final all = [beanJson, bean2Json];
        final filtered = search.isEmpty
            ? all
            : all
                .where((b) => (b['name'] as String)
                    .toLowerCase()
                    .contains(search.toLowerCase()))
                .toList();
        body = filtered;
        meta = {'total': filtered.length};
      } else if (path == '/api/v1/beans/${beanJson['id']}') {
        body = beanJson;
      } else if (path == '/api/v1/recommendations') {
        body = recommendationJson;
      } else if (path == '/api/v1/brews' && req.method == 'POST') {
        body = brewLogJson;
      } else if (path == '/api/v1/brews') {
        body = [brewLogJson];
      } else if (path == '/api/v1/users/me') {
        body = profileJson;
      } else {
        return http.Response(jsonEncode(errorEnvelope('Not found')), 404);
      }
      return http.Response(jsonEncode(envelope(body, meta: meta)), 200);
    }),
  );
}

void main() {
  Future<void> pumpApp(WidgetTester tester, ApiClient api) async {
    // Tall phone viewport so full screens (recipe card, log form) are built.
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CobrewerApp(api: api));
  }

  testWidgets('explore lists beans and total from the API', (tester) async {
    await pumpApp(tester, fakeApi());
    await tester.pumpAndSettle();

    expect(find.text('Worka Chelbesa'), findsOneWidget);
    expect(find.text('Finca El Paraiso'), findsOneWidget);
    expect(find.text('2 beans · showing 2'), findsOneWidget);
  });

  testWidgets('tapping a bean opens dial-in; recipe prefills the log form',
      (tester) async {
    final requests = <http.Request>[];
    await pumpApp(tester, fakeApi(sink: requests));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Worka Chelbesa'));
    await tester.pumpAndSettle();

    // Dial-in flow shows the carried-over bean and equipment pickers.
    expect(find.text('1 · Bean'), findsOneWidget);
    expect(find.text('Worka Chelbesa'), findsOneWidget);

    await tester.tap(find.text('Get recipe'));
    await tester.pumpAndSettle();

    // Recipe stats from the fixture recommendation.
    expect(find.text('3 · Recipe'), findsOneWidget);
    expect(find.text('1:16'), findsOneWidget);
    expect(find.text('3:00–3:30'), findsOneWidget);
    expect(find.textContaining('Confidence 95%'), findsOneWidget);

    // Form was prefilled from the recommendation.
    expect(find.widgetWithText(TextField, '15.0'), findsOneWidget);
    expect(find.widgetWithText(TextField, '95.5'), findsOneWidget);

    final recReq =
        requests.lastWhere((r) => r.url.path == '/api/v1/recommendations');
    expect(recReq.url.queryParameters['bean_id'], beanJson['id']);
    expect(recReq.url.queryParameters['brewer'], 'v60');
    // The grinder saved in the profile (1Zpresso JX-Pro) was preselected.
    expect(recReq.url.queryParameters['grinder'], '1zpresso_jx_pro');
  });

  testWidgets('logging a brew posts generated_by=rules and jumps to journal',
      (tester) async {
    final requests = <http.Request>[];
    await pumpApp(tester, fakeApi(sink: requests));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Worka Chelbesa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get recipe'));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Log brew'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Log brew'));
    await tester.pumpAndSettle();

    final post = requests.lastWhere(
        (r) => r.url.path == '/api/v1/brews' && r.method == 'POST');
    final sent = jsonDecode(post.body) as Map<String, dynamic>;
    expect(sent['generated_by'], 'rules');
    expect(sent['bean_id'], beanJson['id']);
    expect(sent['dose_g'], 15.0);

    // Navigated to the journal tab, which lists the brew with its embedded
    // bean summary — no per-bean fetches.
    expect(find.text('Journal'), findsWidgets);
    expect(find.textContaining('Juicy'), findsOneWidget);
    expect(find.text('Worka Chelbesa'), findsOneWidget);
    expect(
      requests.where((r) => r.url.path.startsWith('/api/v1/beans/')),
      isEmpty,
    );
  });

  testWidgets('edited values log with a comma decimal and generated_by=manual',
      (tester) async {
    final requests = <http.Request>[];
    await pumpApp(tester, fakeApi(sink: requests));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Worka Chelbesa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get recipe'));
    await tester.pumpAndSettle();

    // Tweak the prefilled dose using a European decimal comma.
    await tester.enterText(find.widgetWithText(TextField, '15.0'), '15,5');
    await tester.dragUntilVisible(
      find.text('Log brew'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Log brew'));
    await tester.pumpAndSettle();

    final post = requests.lastWhere(
        (r) => r.url.path == '/api/v1/brews' && r.method == 'POST');
    final sent = jsonDecode(post.body) as Map<String, dynamic>;
    expect(sent['dose_g'], 15.5);
    // The log no longer matches the recipe, so it's labelled manual.
    expect(sent['generated_by'], 'manual');
  });

  testWidgets('absurd values are rejected before any request is sent',
      (tester) async {
    final requests = <http.Request>[];
    await pumpApp(tester, fakeApi(sink: requests));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Worka Chelbesa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get recipe'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, '95.5'), '250');
    await tester.dragUntilVisible(
      find.text('Log brew'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    await tester.tap(find.text('Log brew'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Water temp must be between'), findsOneWidget);
    expect(
      requests.where(
          (r) => r.url.path == '/api/v1/brews' && r.method == 'POST'),
      isEmpty,
    );
  });

  testWidgets('profile shows identity, credits, and equipment',
      (tester) async {
    await pumpApp(tester, fakeApi());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('dev_mobile'), findsOneWidget);
    expect(find.textContaining('2 of 3 left'), findsOneWidget);
    expect(find.text('1Zpresso JX-Pro'), findsOneWidget);
  });
}
