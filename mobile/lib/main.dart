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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Palette.ink, width: 3)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
            NavigationDestination(icon: Icon(Icons.tune), label: 'Dial-in'),
            NavigationDestination(icon: Icon(Icons.menu_book), label: 'Journal'),
            NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
