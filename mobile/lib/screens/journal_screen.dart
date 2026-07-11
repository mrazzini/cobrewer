import 'package:flutter/material.dart';

import '../api/client.dart';
import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/rating_stars.dart';

class JournalScreen extends StatefulWidget {
  final ApiClient api;

  const JournalScreen({super.key, required this.api});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<BrewLog> _brews = [];
  Map<String, Bean> _beans = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await widget.api.listBrews();
    if (!mounted) return;
    if (!res.ok) {
      setState(() {
        _loading = false;
        _error = res.error;
      });
      return;
    }
    final brews = res.data!;
    final beanIds = brews.map((b) => b.beanId).toSet();
    final beanResults =
        await Future.wait(beanIds.map((id) => widget.api.getBean(id)));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _brews = brews;
      _beans = {
        for (final r in beanResults)
          if (r.ok) r.data!.id: r.data!,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            onPressed: _fetch,
            icon: const Icon(Icons.refresh, color: CobraColors.textMuted),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: CobraColors.green));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: CobraColors.textMuted)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _fetch, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_brews.isEmpty) {
      return const Center(
        child: Text('No brews yet — dial one in!',
            style: TextStyle(color: CobraColors.textMuted)),
      );
    }
    return RefreshIndicator(
      color: CobraColors.green,
      onRefresh: _fetch,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _brews.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _brewCard(_brews[i]),
      ),
    );
  }

  Widget _brewCard(BrewLog brew) {
    final bean = _beans[brew.beanId];
    final when = brew.timestamp.toLocal();
    final date =
        '${when.year}-${when.month.toString().padLeft(2, '0')}-${when.day.toString().padLeft(2, '0')}';
    final params = <String>[
      if (brew.doseG != null && brew.yieldG != null)
        '${brew.doseG}g → ${brew.yieldG}g',
      if (brew.grindSetting != null)
        'grind ${brew.grindSetting} (${grinderLabel(brew.grinder)})',
      if (brew.waterTempC != null) '${brew.waterTempC}°C',
      if (brew.brewTimeSeconds != null) formatSeconds(brew.brewTimeSeconds!),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bean?.name ?? 'Unknown bean',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: CobraColors.text),
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
              style:
                  const TextStyle(color: CobraColors.textMuted, fontSize: 13),
            ),
            if (params.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                params.join(' · '),
                style: const TextStyle(color: CobraColors.textMuted, fontSize: 13),
              ),
            ],
            if (brew.notes?.isNotEmpty ?? false) ...[
              const SizedBox(height: 6),
              Text(
                brew.notes!,
                style: const TextStyle(
                    color: CobraColors.text,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
