import 'dart:async';

import 'package:flutter/material.dart';

import '../api/client.dart';
import '../constants.dart';
import '../models/models.dart';
import '../theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/rating_stars.dart';

class DialInScreen extends StatefulWidget {
  final ApiClient api;
  final Bean? initialBean;
  final VoidCallback onLogged;

  const DialInScreen({
    super.key,
    required this.api,
    this.initialBean,
    required this.onLogged,
  });

  @override
  State<DialInScreen> createState() => _DialInScreenState();
}

class _DialInScreenState extends State<DialInScreen> {
  Bean? _bean;
  String _brewer = 'v60';
  String? _grinder;
  bool _equipmentTouched = false;

  Recommendation? _rec;
  bool _loadingRec = false;
  String? _recError;

  // Equipment + prefilled values the current recipe was computed with, so
  // generated_by only says "rules" when the log actually matches the recipe.
  String? _recBrewer;
  String? _recGrinder;
  Map<String, String> _prefill = const {};

  // Bean picker state (when no bean was carried over from Explore).
  final _beanSearchController = TextEditingController();
  Timer? _debounce;
  List<Bean> _beanResults = [];
  bool _searchingBeans = false;
  String? _beanSearchError;

  // Brew log form.
  final _grindController = TextEditingController();
  final _doseController = TextEditingController();
  final _yieldController = TextEditingController();
  final _tempController = TextEditingController();
  final _timeController = TextEditingController();
  final _tdsController = TextEditingController();
  final _notesController = TextEditingController();
  int _rating = 0;
  bool _logging = false;

  @override
  void initState() {
    super.initState();
    _bean = widget.initialBean;
    if (_bean == null) _searchBeans('');
    _applyProfileDefaults();
  }

  /// Preselect the brewer/grinder saved in the profile — until the user
  /// touches the dropdowns themselves.
  Future<void> _applyProfileDefaults() async {
    final res = await widget.api.getMe();
    if (!mounted || !res.ok || _equipmentTouched) return;
    final equipment = res.data!.equipment;
    setState(() {
      final g = matchGrinderKey(equipment);
      if (g != null && _grinder == null) _grinder = g;
      final b = matchBrewerKey(equipment);
      if (b != null && _brewer == 'v60') _brewer = b;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _beanSearchController.dispose();
    _grindController.dispose();
    _doseController.dispose();
    _yieldController.dispose();
    _tempController.dispose();
    _timeController.dispose();
    _tdsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _searchBeans(String query) async {
    setState(() {
      _searchingBeans = true;
      _beanSearchError = null;
    });
    final res = await widget.api.listBeans(search: query, limit: 15);
    if (!mounted) return;
    setState(() {
      _searchingBeans = false;
      _beanResults = res.data ?? [];
      if (!res.ok) _beanSearchError = res.error ?? 'Could not load beans.';
    });
  }

  void _onBeanSearchChanged(String query) {
    _debounce?.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 300), () => _searchBeans(query));
  }

  Future<void> _getRecipe() async {
    final bean = _bean;
    if (bean == null) return;
    setState(() {
      _loadingRec = true;
      _recError = null;
      _rec = null;
    });
    final res = await widget.api.getRecommendation(
      beanId: bean.id,
      brewer: _brewer,
      grinder: _grinder,
    );
    if (!mounted) return;
    setState(() {
      _loadingRec = false;
      if (res.ok) {
        _rec = res.data;
        _prefillForm(res.data!.parameters);
      } else {
        _recError = res.error;
      }
    });
  }

  void _prefillForm(RecommendationParameters? p) {
    if (p == null) return;
    _grindController.text = p.grindSetting.value.toString();
    _doseController.text = p.doseG.toString();
    _yieldController.text = p.yieldG.toString();
    _tempController.text = p.waterTempC.toString();
    _timeController.text =
        ((p.brewTimeMinSeconds + p.brewTimeMaxSeconds) ~/ 2).toString();
    _recBrewer = _brewer;
    _recGrinder = _grinder;
    _prefill = {
      'grind': _grindController.text,
      'dose': _doseController.text,
      'yield': _yieldController.text,
      'temp': _tempController.text,
      'time': _timeController.text,
    };
  }

  /// True only when equipment and every prefilled value still match the
  /// fetched recipe — the generated_by label future ML training relies on.
  bool get _logMatchesRecipe =>
      _rec != null &&
      _brewer == _recBrewer &&
      _grinder == _recGrinder &&
      _grindController.text == _prefill['grind'] &&
      _doseController.text == _prefill['dose'] &&
      _yieldController.text == _prefill['yield'] &&
      _tempController.text == _prefill['temp'] &&
      _timeController.text == _prefill['time'];

  /// Parses a form value, accepting European decimal commas ("15,5").
  /// Adds a message to [problems] when the text isn't a number or is
  /// outside the given bounds; empty text is simply null.
  double? _parseField(
      TextEditingController controller, String boundsKey, List<String> problems) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    final bounds = brewBounds[boundsKey]!;
    final n = double.tryParse(raw.replaceAll(',', '.'));
    if (n == null) {
      problems.add("${bounds.label} isn't a number");
      return null;
    }
    if (n < bounds.min || n > bounds.max) {
      problems.add(
          '${bounds.label} must be between ${bounds.min}${bounds.unit} and ${bounds.max}${bounds.unit}');
      return null;
    }
    return n;
  }

  Future<void> _logBrew() async {
    final bean = _bean;
    if (bean == null) return;

    final problems = <String>[];
    final grind = _parseField(_grindController, 'grind_setting', problems);
    final dose = _parseField(_doseController, 'dose_g', problems);
    final yieldG = _parseField(_yieldController, 'yield_g', problems);
    final temp = _parseField(_tempController, 'water_temp_c', problems);
    final time = _parseField(_timeController, 'brew_time_seconds', problems);
    final tds = _parseField(_tdsController, 'tds', problems);
    if (problems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(problems.join('. '))),
      );
      return;
    }

    setState(() => _logging = true);
    final res = await widget.api.logBrew({
      'bean_id': bean.id,
      'brewer': _brewer,
      if (_grinder != null) 'grinder': _grinder,
      'grind_setting': grind,
      'dose_g': dose,
      'yield_g': yieldG,
      'water_temp_c': temp,
      'brew_time_seconds': time?.round(),
      'tds': tds,
      if (_rating > 0) 'rating': _rating,
      if (_notesController.text.trim().isNotEmpty)
        'notes': _notesController.text.trim(),
      'generated_by': _logMatchesRecipe ? 'rules' : 'manual',
    });
    if (!mounted) return;
    setState(() => _logging = false);
    final messenger = ScaffoldMessenger.of(context);
    if (res.ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Brew logged — check your journal.')),
      );
      widget.onLogged();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(res.error ?? 'Could not log the brew.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Dial-in', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _bean == null ? _beanPicker() : _dialInFlow(),
    );
  }

  Widget _beanPicker() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _beanSearchController,
            onChanged: _onBeanSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Pick a bean to dial in…',
              prefixIcon: Icon(Icons.search, color: Palette.creamDim),
            ),
          ),
        ),
        Expanded(child: _beanPickerResults()),
      ],
    );
  }

  Widget _beanPickerResults() {
    if (_searchingBeans) {
      return const Center(
          child: CircularProgressIndicator(color: Palette.blush));
    }
    if (_beanSearchError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_beanSearchError!,
                style: const TextStyle(color: Palette.creamDim)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _searchBeans(_beanSearchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_beanResults.isEmpty) {
      final query = _beanSearchController.text.trim();
      return Center(
        child: Text(
          query.isEmpty
              ? 'No beans in the library yet.'
              : 'Nothing matches “$query” — try another name.',
          style: const TextStyle(color: Palette.creamDim),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _beanResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final bean = _beanResults[i];
        return BeanCard(
          key: ValueKey(bean.id),
          bean: bean,
          compact: true,
          onTap: () => setState(() => _bean = bean),
        );
      },
    );
  }

  Widget _dialInFlow() {
    final bean = _bean!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('1 · Bean'),
        BeanCard(bean: bean, compact: true),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => setState(() {
              _bean = null;
              _rec = null;
              _searchBeans(_beanSearchController.text);
            }),
            child: const Text('Change bean',
                style: TextStyle(color: Palette.blush)),
          ),
        ),
        _sectionTitle('2 · Equipment'),
        DropdownButtonFormField<String>(
          value: _brewer,
          decoration: const InputDecoration(labelText: 'Brewer'),
          dropdownColor: Palette.periWell,
          items: [
            for (final b in brewers)
              DropdownMenuItem(value: b.key, child: Text(b.label)),
          ],
          onChanged: (v) => setState(() {
            _brewer = v ?? _brewer;
            _equipmentTouched = true;
          }),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String?>(
          value: _grinder,
          decoration: const InputDecoration(labelText: 'Grinder (optional)'),
          dropdownColor: Palette.periWell,
          items: [
            const DropdownMenuItem<String?>(
                value: null, child: Text('No grinder / other')),
            for (final g in grinders)
              DropdownMenuItem<String?>(value: g.key, child: Text(g.label)),
          ],
          onChanged: (v) => setState(() {
            _grinder = v;
            _equipmentTouched = true;
          }),
        ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: _loadingRec ? null : _getRecipe,
          child: Text(_loadingRec ? 'Computing…' : 'Get recipe'),
        ),
        if (_recError != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_recError!,
                style: const TextStyle(color: Palette.blushDeep)),
          ),
        if (_rec?.parameters != null) ...[
          _sectionTitle('3 · Recipe'),
          _recipeCard(_rec!),
        ],
        _sectionTitle(_rec != null ? '4 · Log this brew' : '3 · Log a brew'),
        _logForm(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Palette.blush,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _recipeCard(Recommendation rec) {
    final p = rec.parameters!;
    final grindUnit = p.grindSetting.unit;
    final stats = <(String, String)>[
      ('Grind', '${p.grindSetting.value} $grindUnit'),
      ('Dose', '${p.doseG} g'),
      ('Ratio', p.ratio),
      ('Yield', '${p.yieldG} g'),
      ('Water', '${p.waterTempC} °C'),
      ('Time', formatBrewTime(p.brewTimeMinSeconds, p.brewTimeMaxSeconds)),
      if (p.pressureBar != null) ('Pressure', '${p.pressureBar} bar'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Palette.blush,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (label, value) in stats)
                  SizedBox(
                    width: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                color: Palette.inkSoft, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(value,
                            style: const TextStyle(
                                color: Palette.ink,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ],
                    ),
                  ),
              ],
            ),
            if (p.grindSetting.converted)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Converted from ${p.grindSettingC40Clicks} C40 clicks for ${grinderLabel(p.grindSetting.grinder)}.',
                  style: const TextStyle(
                      color: Palette.inkSoft, fontSize: 12),
                ),
              ),
            for (final note in p.notes)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(color: Palette.ink)),
                    Expanded(
                      child: Text(note,
                          style: const TextStyle(
                              color: Palette.inkSoft, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            if (rec.confidenceScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Confidence ${(rec.confidenceScore! * 100).round()}%',
                  style:
                      const TextStyle(color: Palette.inkSoft, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _logForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _numField(_grindController, 'Grind setting')),
            const SizedBox(width: 10),
            Expanded(child: _numField(_doseController, 'Dose (g)')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _numField(_yieldController, 'Yield (g)')),
            const SizedBox(width: 10),
            Expanded(child: _numField(_tempController, 'Water (°C)')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _numField(_timeController, 'Brew time (seconds)')),
            const SizedBox(width: 10),
            Expanded(child: _numField(_tdsController, 'TDS % (optional)')),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'Notes'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Rating',
                style: TextStyle(color: Palette.creamDim)),
            const SizedBox(width: 10),
            RatingStars(
              rating: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _logging ? null : _logBrew,
            child: Text(_logging ? 'Logging…' : 'Log brew'),
          ),
        ),
      ],
    );
  }

  Widget _numField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}
