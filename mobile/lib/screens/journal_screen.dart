import 'package:flutter/material.dart';

import '../api/client.dart';
import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/rating_stars.dart';
import '../widgets/skeletons.dart';

class JournalScreen extends StatefulWidget {
  final ApiClient api;

  /// Bumped by the shell whenever a brew is logged elsewhere, so the
  /// journal refetches even though IndexedStack keeps it alive.
  final int refreshToken;

  const JournalScreen({super.key, required this.api, this.refreshToken = 0});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<BrewLog> _brews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(covariant JournalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshToken != oldWidget.refreshToken) _fetch();
  }

  /// [silent] keeps the current list on screen (pull-to-refresh) instead of
  /// swapping it for a full-screen spinner. Brews embed their bean summary,
  /// so a single request is enough.
  Future<void> _fetch({bool silent = false}) async {
    setState(() {
      if (!silent) _loading = true;
      _error = null;
    });
    final res = await widget.api.listBrews();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.ok) {
        _brews = res.data!;
      } else {
        _error = res.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PosterHeader(
              title: 'BREW',
              accent: 'JOURNAL',
              banner: _brews.isEmpty
                  ? 'EVERY CUP MAKES IT SMARTER'
                  : '${_brews.length} BREW${_brews.length == 1 ? '' : 'S'} · GETTING SMARTER',
              trailing: IconButton(
                onPressed: () => _fetch(),
                icon: const Icon(Icons.refresh, color: Palette.cream),
                tooltip: 'Refresh',
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return SkeletonList(
        count: 4,
        itemBuilder: () => const BrewCardSkeleton(),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Palette.creamDim)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_brews.isEmpty) {
      return const Center(
        child: Text('No brews yet — dial one in!',
            style: TextStyle(color: Palette.creamDim)),
      );
    }
    return RefreshIndicator(
      color: Palette.blush,
      onRefresh: () => _fetch(silent: true),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _brews.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => KeyedSubtree(
          key: ValueKey(_brews[i].id),
          child: _brewCard(_brews[i]),
        ),
      ),
    );
  }

  Widget _brewCard(BrewLog brew) {
    final bean = brew.bean;
    final when = brew.timestamp.toLocal();
    final date =
        '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    final params = <String>[
      if (brew.doseG != null && brew.yieldG != null)
        '${brew.doseG}g in · ${brew.yieldG}g out',
      if (brew.grindSetting != null)
        'grind ${brew.grindSetting} (${grinderLabel(brew.grinder)})',
      if (brew.waterTempC != null) '${brew.waterTempC}°C',
      if (brew.brewTimeSeconds != null) formatSeconds(brew.brewTimeSeconds!),
    ];
    return BrutCard(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (bean?.name ?? 'Unknown bean').toUpperCase(),
                    style: const TextStyle(
                        fontFamily: 'Anton',
                        fontSize: 15,
                        letterSpacing: 0.5,
                        color: Palette.ink),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (brew.rating != null)
                  RatingStars(rating: brew.rating!, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${brewerLabel(brew.brewer)} · $date'
              '${brew.generatedBy == 'rules' ? ' · from recipe' : ''}',
              style: const TextStyle(
                  color: Palette.inkSoft,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            if (params.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                params.join(' · '),
                style: const TextStyle(
                    color: Palette.inkSoft,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ],
            if (brew.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                brew.notes!,
                style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
    );
  }
}
