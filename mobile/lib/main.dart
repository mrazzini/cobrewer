import 'package:flutter/material.dart';

import 'api/client.dart';
import 'models/models.dart';
import 'screens/dial_in_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

void main() {
  runApp(CobrewerApp(api: ApiClient()));
}

class CobrewerApp extends StatelessWidget {
  final ApiClient api;

  const CobrewerApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cobrewer',
      theme: buildCobrewerTheme(),
      debugShowCheckedModeBanner: false,
      home: HomeShell(api: api),
    );
  }
}

class HomeShell extends StatefulWidget {
  final ApiClient api;

  const HomeShell({super.key, required this.api});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  /// Bean carried from Explore into Dial-in ("Dial this in" action).
  Bean? _dialInBean;

  /// Incremented whenever a brew is logged so the journal refetches.
  int _journalRefresh = 0;

  void _dialIn(Bean bean) {
    setState(() {
      _dialInBean = bean;
      _tab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ExploreScreen(api: widget.api, onDialIn: _dialIn),
      DialInScreen(
        api: widget.api,
        // Rebuild the dial-in flow when a new bean is carried over.
        key: ValueKey(_dialInBean?.id ?? 'none'),
        initialBean: _dialInBean,
        onLogged: () => setState(() {
          _tab = 2;
          _journalRefresh++;
        }),
      ),
      JournalScreen(api: widget.api, refreshToken: _journalRefresh),
      ProfileScreen(api: widget.api),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: brutBox(radius: 999, shadow: 5),
          child: Row(
            children: [
              for (final (i, label) in const [
                (0, 'EXPLORE'),
                (1, 'DIAL-IN'),
                (2, 'JOURNAL'),
                (3, 'PROFILE'),
              ])
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _tab = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: _tab == i
                          ? BoxDecoration(
                              color: Palette.ink,
                              borderRadius: BorderRadius.circular(999),
                            )
                          : null,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: _tab == i ? Palette.olive : Palette.ink,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
