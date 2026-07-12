import 'dart:convert';

import 'package:cobrewer_mobile/api/client.dart';
import 'package:cobrewer_mobile/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

void main() {
  test('listBeans builds query params and unwraps the envelope', () async {
    late http.Request captured;
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode(envelope([beanJson, bean2Json], meta: {'total': 2})),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final res = await api.listBeans(
        search: 'worka', origin: 'Ethiopia', roastLevel: 'light');

    expect(captured.url.path, '/api/v1/beans');
    expect(captured.url.queryParameters['search'], 'worka');
    expect(captured.url.queryParameters['origin'], 'Ethiopia');
    expect(captured.url.queryParameters['roast_level'], 'light');
    expect(captured.url.queryParameters.containsKey('process'), isFalse);
    expect(captured.headers['X-Dev-User'], isNotEmpty);

    expect(res.ok, isTrue);
    expect(res.data, hasLength(2));
    expect(res.data!.first.name, 'Worka Chelbesa');
    expect(res.meta?['total'], 2);
  });

  test('error envelope surfaces the backend message', () async {
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async =>
          http.Response(jsonEncode(errorEnvelope('Bean not found')), 404)),
    );

    final res = await api.getBean('missing-id');
    expect(res.ok, isFalse);
    expect(res.error, 'Bean not found');
    expect(res.data, isNull);
  });

  test('network failure returns a friendly error instead of throwing', () async {
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async => throw Exception('boom')),
    );

    final res = await api.listBrews();
    expect(res.ok, isFalse);
    expect(res.error, 'Could not reach the Cobrewer API');
  });

  test('logBrew POSTs JSON body with Content-Type header', () async {
    late http.Request captured;
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async {
        captured = req;
        return http.Response(jsonEncode(envelope(brewLogJson)), 200);
      }),
    );

    final res = await api.logBrew({
      'bean_id': beanJson['id'],
      'brewer': 'v60',
      'rating': 4,
    });

    expect(captured.method, 'POST');
    expect(captured.headers['content-type'], contains('application/json'));
    final sent = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(sent['brewer'], 'v60');
    expect(sent['rating'], 4);
    expect(res.ok, isTrue);
    expect(res.data!.rating, 4);
  });

  test('updateEquipment sends full replace payload and parses the list',
      () async {
    late http.Request captured;
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async {
        captured = req;
        return http.Response(
          jsonEncode(envelope({
            'equipment': [
              {
                'equipment_type': 'grinder',
                'brand': 'Comandante',
                'model': 'C40',
                'burr_type': 'conical',
              }
            ]
          })),
          200,
        );
      }),
    );

    final res = await api.updateEquipment(const [
      Equipment(
          equipmentType: 'grinder',
          brand: 'Comandante',
          model: 'C40',
          burrType: 'conical'),
    ]);

    expect(captured.method, 'PUT');
    final sent = jsonDecode(captured.body) as Map<String, dynamic>;
    expect(sent['equipment'], hasLength(1));
    expect(res.ok, isTrue);
    expect(res.data!.single.model, 'C40');
  });

  test('bearer token is attached when a token provider is set', () async {
    late http.Request captured;
    final api = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((req) async {
        captured = req;
        return http.Response(jsonEncode(envelope(profileJson)), 200);
      }),
      tokenProvider: () async => 'clerk-session-token',
    );

    await api.getMe();
    expect(captured.headers['authorization'], 'Bearer clerk-session-token');
  });

  test('naive UTC timestamps parse as UTC so toLocal() can shift them', () {
    final naive = Map<String, dynamic>.from(brewLogJson)
      ..['timestamp'] = '2026-07-11T09:30:00.123456';
    final brew = BrewLog.fromJson(naive);
    expect(brew.timestamp.isUtc, isTrue);
    expect(brew.timestamp.hour, 9);

    final zoned = BrewLog.fromJson(Map<String, dynamic>.from(brewLogJson));
    expect(zoned.timestamp.isUtc, isTrue);
  });
}
