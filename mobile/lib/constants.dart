/// Keys must match the backend recommendation engine's alias/conversion tables
/// (mirrors frontend/src/lib/constants.ts).
library;

import 'models/models.dart';

class Option {
  final String key;
  final String label;
  const Option(this.key, this.label);
}

const brewers = [
  Option('v60', 'V60 / Pour Over'),
  Option('espresso', 'Espresso'),
  Option('french_press', 'French Press'),
];

const grinders = [
  Option('comandante_c40', 'Comandante C40'),
  Option('1zpresso_jx', '1Zpresso JX'),
  Option('1zpresso_jx_pro', '1Zpresso JX-Pro'),
  Option('1zpresso_k_plus', '1Zpresso K-Plus'),
  Option('timemore_c2', 'Timemore C2'),
  Option('timemore_c3', 'Timemore C3'),
  Option('baratza_encore', 'Baratza Encore'),
  Option('baratza_virtuoso', 'Baratza Virtuoso+'),
  Option('fellow_ode_gen2', 'Fellow Ode Gen 2'),
  Option('niche_zero', 'Niche Zero'),
  Option('wilfa_uniform', 'Wilfa Uniform'),
  Option('hario_skerton', 'Hario Skerton'),
];

const processes = ['washed', 'natural', 'honey', 'anaerobic', 'wet_hulled'];

const roastLevels = [
  Option('light', 'Light'),
  Option('medium_light', 'Medium-Light'),
  Option('medium', 'Medium'),
  Option('medium_dark', 'Medium-Dark'),
  Option('dark', 'Dark'),
];

const origins = [
  'Ethiopia',
  'Kenya',
  'Colombia',
  'Brazil',
  'Guatemala',
  'Costa Rica',
  'Panama',
  'Honduras',
  'El Salvador',
  'Peru',
  'Rwanda',
  'Burundi',
  'Indonesia',
  'Yemen',
];

String roastLabel(String? key) {
  if (key == null || key.isEmpty) return '—';
  for (final r in roastLevels) {
    if (r.key == key) return r.label;
  }
  return key;
}

String brewerLabel(String key) {
  for (final b in brewers) {
    if (b.key == key) return b.label;
  }
  return key;
}

String grinderLabel(String? key) {
  if (key == null || key.isEmpty) return '—';
  for (final g in grinders) {
    if (g.key == key) return g.label;
  }
  return key;
}

String processLabel(String? key) {
  if (key == null || key.isEmpty) return '—';
  return key.replaceAll('_', ' ');
}

/// Client-side mirror of the backend's BrewLogCreate bounds.
class BrewBound {
  final double min;
  final double max;
  final String label;
  final String unit;
  const BrewBound(this.min, this.max, this.label, this.unit);
}

const brewBounds = <String, BrewBound>{
  'grind_setting': BrewBound(0, 500, 'Grind setting', ''),
  'dose_g': BrewBound(0.1, 200, 'Dose', ' g'),
  'yield_g': BrewBound(0.1, 2000, 'Yield', ' g'),
  'water_temp_c': BrewBound(1, 100, 'Water temp', ' °C'),
  'brew_time_seconds': BrewBound(1, 7200, 'Brew time', ' s'),
  'tds': BrewBound(0, 20, 'TDS', '%'),
};

String _normEquip(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

/// Best-effort map of free-text profile equipment onto a grinder key.
/// Prefers the longest label contained in the entry so "1Zpresso JX-Pro"
/// beats "1Zpresso JX"; falls back to model-only entries like "JX-Pro".
String? matchGrinderKey(List<Equipment> equipment) {
  for (final row in equipment.where((e) => e.equipmentType == 'grinder')) {
    final cand = _normEquip('${row.brand ?? ''}${row.model ?? ''}');
    if (cand.length < 2) continue;
    final hits = grinders.where((g) {
      final label = _normEquip(g.label);
      return cand.contains(label) || (cand.length >= 4 && label.contains(cand));
    }).toList()
      ..sort((a, b) => _normEquip(b.label).length.compareTo(_normEquip(a.label).length));
    if (hits.isNotEmpty) return hits.first.key;
  }
  return null;
}

const _brewerHints = [
  ('espresso', ['espresso']),
  ('v60', ['v60', 'pourover', 'hario']),
  ('french_press', ['frenchpress', 'press']),
];

String? matchBrewerKey(List<Equipment> equipment) {
  for (final row in equipment.where((e) => e.equipmentType == 'brewer')) {
    final cand = _normEquip('${row.brand ?? ''}${row.model ?? ''}');
    for (final (key, hints) in _brewerHints) {
      if (hints.any(cand.contains)) return key;
    }
  }
  return null;
}

String formatSeconds(int s) {
  if (s < 60) return '${s}s';
  final m = s ~/ 60;
  final rest = s % 60;
  return '$m:${rest.toString().padLeft(2, '0')}';
}

String formatBrewTime(int min, int max) {
  if (min == max) return formatSeconds(min);
  return '${formatSeconds(min)}–${formatSeconds(max)}';
}
