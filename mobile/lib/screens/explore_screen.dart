import 'dart:async';

import 'package:flutter/material.dart';

import '../api/client.dart';
import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/skeletons.dart';

class ExploreScreen extends StatefulWidget {
  final ApiClient api;
  final ValueChanged<Bean> onDialIn;

  const ExploreScreen({super.key, required this.api, required this.onDialIn});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _pageSize = 30;

  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Bean> _beans = [];
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  String? _origin;
  String? _process;
  String? _roastLevel;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _fetch);
    // Rebuild so the clear (✕) button appears/disappears with the text.
    setState(() {});
  }

  /// [silent] keeps the current list on screen (pull-to-refresh) instead of
  /// swapping it for a full-screen spinner.
  Future<void> _fetch({bool silent = false}) async {
    setState(() {
      if (!silent) _loading = true;
      _error = null;
    });
    final res = await widget.api.listBeans(
      search: _searchController.text.trim(),
      origin: _origin,
      process: _process,
      roastLevel: _roastLevel,
      limit: _pageSize,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (res.ok) {
        _beans = res.data!;
        _total = (res.meta?['total'] as num?)?.toInt() ?? _beans.length;
      } else {
        _error = res.error;
      }
    });
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final res = await widget.api.listBeans(
      search: _searchController.text.trim(),
      origin: _origin,
      process: _process,
      roastLevel: _roastLevel,
      limit: _pageSize,
      offset: _beans.length,
    );
    if (!mounted) return;
    setState(() {
      _loadingMore = false;
      if (res.ok) {
        _beans = [..._beans, ...res.data!];
        _total = (res.meta?['total'] as num?)?.toInt() ?? _total;
      } else {
        _error = res.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
        children: [
          const PosterHeader(
            title: 'EXPLORE',
            accent: 'BEANS',
            banner: '200 COFFEES. ZERO BAD CUPS.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: brutShadow(
                radius: 12,
                shadow: 4,
                child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                  color: Palette.ink, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search beans, roasters, origins…',
                prefixIcon: const Icon(Icons.search, color: Palette.inkSoft),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: Palette.inkSoft),
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                          _fetch();
                        },
                      ),
              ),
            )),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip<String>(
                  label: 'Origin',
                  value: _origin,
                  options: [for (final o in origins) (o, o)],
                  onChanged: (v) => setState(() {
                    _origin = v;
                    _fetch();
                  }),
                ),
                const SizedBox(width: 8),
                _filterChip<String>(
                  label: 'Process',
                  value: _process,
                  options: [for (final p in processes) (p, processLabel(p))],
                  onChanged: (v) => setState(() {
                    _process = v;
                    _fetch();
                  }),
                ),
                const SizedBox(width: 8),
                _filterChip<String>(
                  label: 'Roast',
                  value: _roastLevel,
                  options: [for (final r in roastLevels) (r.key, r.label)],
                  onChanged: (v) => setState(() {
                    _roastLevel = v;
                    _fetch();
                  }),
                ),
              ],
            ),
          ),
          Expanded(child: _body()),
        ],
        ),
      ),
    );
  }

  Widget _filterChip<T>({
    required String label,
    required String? value,
    required List<(String, String)> options,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedLabel = value == null
        ? label
        : '$label: ${options.firstWhere((o) => o.$1 == value, orElse: () => (value, value)).$2}';
    return PopupMenuButton<String?>(
      onSelected: (v) => onChanged(v == '' ? null : v),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Any')),
        for (final (key, optLabel) in options)
          PopupMenuItem(value: key, child: Text(optLabel)),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(13, 0, 8, 0),
        decoration: BoxDecoration(
          color: value == null ? Colors.white : Palette.blush,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Palette.ink, width: 3),
          boxShadow: const [
            BoxShadow(color: Palette.ink, offset: Offset(3, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedLabel.toUpperCase(),
                style: const TextStyle(
                  color: Palette.ink,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                )),
            const Icon(Icons.arrow_drop_down, size: 18, color: Palette.ink),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return SkeletonList(
        count: 6,
        itemBuilder: () => const BeanCardSkeleton(),
      );
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _fetch);
    }
    if (_beans.isEmpty) {
      return const Center(
        child: Text('No beans match those filters.',
            style: TextStyle(color: Palette.creamDim)),
      );
    }
    final hasMore = _beans.length < _total;
    return RefreshIndicator(
      color: Palette.blush,
      onRefresh: () => _fetch(silent: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 104),
        itemCount: _beans.length + 1 + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Text(
              'SHOWING ${_beans.length} OF $_total',
              style: const TextStyle(
                color: Palette.creamDim,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            );
          }
          if (i == _beans.length + 1) {
            return Center(
              child: OutlinedButton(
                onPressed: _loadingMore ? null : _loadMore,
                child: Text(_loadingMore
                    ? 'Loading…'
                    : 'Load more (${_total - _beans.length} left)'),
              ),
            );
          }
          final bean = _beans[i - 1];
          return BeanCard(
            key: ValueKey(bean.id),
            bean: bean,
            onTap: () => widget.onDialIn(bean),
          );
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: Palette.creamDim)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
