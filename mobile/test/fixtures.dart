/// Canned backend responses matching the real API's {data, error, meta}
/// envelope and field names.
library;

const beanJson = {
  'id': '9b2f7c1e-1111-2222-3333-444455556666',
  'name': 'Worka Chelbesa',
  'roaster': 'September Coffee Co',
  'origin': 'Ethiopia',
  'variety': 'Heirloom',
  'process': 'washed',
  'roast_level': 'light',
  'roast_date': null,
  'tasting_notes': ['bergamot', 'peach', 'black tea'],
  'cupping_score': 88.25,
  'source_url': null,
  'is_verified': true,
  'created_at': '2026-07-01T10:00:00Z',
};

const bean2Json = {
  'id': '9b2f7c1e-aaaa-bbbb-cccc-444455556666',
  'name': 'Finca El Paraiso',
  'roaster': 'Onyx Coffee Lab',
  'origin': 'Colombia',
  'variety': 'Castillo',
  'process': 'anaerobic',
  'roast_level': 'medium_light',
  'roast_date': null,
  'tasting_notes': ['lychee', 'cola'],
  'cupping_score': 89.5,
  'source_url': null,
  'is_verified': true,
  'created_at': '2026-07-01T10:00:00Z',
};

const recommendationJson = {
  'id': '0f0e0d0c-1111-2222-3333-444455556666',
  'bean_id': '9b2f7c1e-1111-2222-3333-444455556666',
  'brewer': 'v60',
  'grinder': '1zpresso_jx_pro',
  'parameters': {
    'brewer': 'v60',
    'grind_setting': {
      'grinder': '1zpresso_jx_pro',
      'value': 66,
      'unit': 'clicks',
      'reference': 'comandante_c40',
      'converted': true,
    },
    'grind_setting_c40_clicks': 22,
    'dose_g': 15.0,
    'ratio': '1:16',
    'yield_g': 240.0,
    'water_temp_c': 95.5,
    'brew_time_seconds': {'min': 180, 'max': 210},
    'notes': ['Light roast: raise the temperature and grind finer.'],
  },
  'generated_by': 'rules',
  'confidence_score': 0.95,
  'created_at': '2026-07-11T10:00:00Z',
};

const brewLogJson = {
  'id': 'aaaa0d0c-1111-2222-3333-444455556666',
  'user_id': 'bbbb0d0c-1111-2222-3333-444455556666',
  'bean_id': '9b2f7c1e-1111-2222-3333-444455556666',
  'bean': {
    'id': '9b2f7c1e-1111-2222-3333-444455556666',
    'name': 'Worka Chelbesa',
    'roaster': 'September Coffee Co',
    'origin': 'Ethiopia',
  },
  'brewer': 'v60',
  'grinder': '1zpresso_jx_pro',
  'grind_setting': 66,
  'dose_g': 15.0,
  'yield_g': 240.0,
  'water_temp_c': 95.5,
  'brew_time_seconds': 195,
  'tds': null,
  'rating': 4,
  'notes': 'Juicy, slightly astringent finish.',
  'generated_by': 'rules',
  'timestamp': '2026-07-11T09:30:00Z',
};

const profileJson = {
  'id': 'bbbb0d0c-1111-2222-3333-444455556666',
  'clerk_id': 'dev_mobile',
  'display_name': null,
  'created_at': '2026-07-01T10:00:00Z',
  'equipment': [
    {
      'equipment_type': 'grinder',
      'brand': '1Zpresso',
      'model': 'JX-Pro',
      'burr_type': 'conical',
    },
  ],
  'ai_credits': {'extractions_used': 1, 'extractions_limit': 3},
};

Map<String, dynamic> envelope(Object? data, {Map<String, dynamic>? meta}) =>
    {'data': data, 'error': null, 'meta': meta};

Map<String, dynamic> errorEnvelope(String error) =>
    {'data': null, 'error': error, 'meta': null};
