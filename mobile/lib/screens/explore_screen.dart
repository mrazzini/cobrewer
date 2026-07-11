import 'dart:async';

import 'package:flutter/material.dart';

import '../api/client.dart';
import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/bean_card.dart';

class ExploreScreen extends StatefulWidget {
  final ApiClient api;
  final ValueChanged<Bean> onDialIn;

  const ExploreScreen({super.key, required this.api, required this.onDialIn});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Bean> _beans = [];
  int _total = 0;
  bool _loading = true;
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
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await widget.api.listBeans(
      search: _searchController.text.trim(),
      origin: _origin,
      process: _process,
      roastLevel: _roastLevel,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore beans',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search beans, roasters, origins…',
                prefixIcon: Icon(Icons.search, color: CobraColors.textMuted),
              ),
            ),
          ),
          SizedBox(
            height: 44,
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
        : options.firstWhere((o) => o.$1 == value, orElse: () => (value, value)).$2;
    return PopupMenuButton<String?>(
      color: CobraColors.surfaceRaised,
      onSelected: (v) => onChanged(v == '' ? null : v),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('Any')),
        for (final (key, optLabel) in options)
          PopupMenuItem(value: key, child: Text(optLabel)),
      ],
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedLabel,
                style: TextStyle(
                  color: value == null ? CobraColors.textMuted : CobraColors.green,
                  fontSize: 13,
                )),
            Icon(Icons.arrow_drop_down,
                size: 18,
                color: value == null ? CobraColors.textMuted : CobraColors.green),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: CobraColors.green));
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _fetch);
    }
    if (_beans.isEmpty) {
      return const Center(
        child: Text('No beans match those filters.',
            style: TextStyle(color: CobraColors.textMuted)),
      );
    }
    return RefreshIndicator(
      color: CobraColors.green,
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _beans.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Text(
              '$_total bean${_total == 1 ? '' : 's'}',
              style: const TextStyle(color: CobraColors.textMuted, fontSize: 13),
            );
          }
          final bean = _beans[i - 1];
          return BeanCard(bean: bean, onTap: () => widget.onDialIn(bean));
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
          Text(message, style: const TextStyle(color: CobraColors.textMuted)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
