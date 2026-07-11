/// Keys must match the backend recommendation engine's alias/conversion tables
/// (mirrors frontend/src/lib/constants.ts).
library;

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
