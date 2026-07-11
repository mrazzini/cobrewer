import 'package:cobrewer_mobile/constants.dart';
import 'package:cobrewer_mobile/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';

void main() {
  group('Bean.fromJson', () {
    test('parses full bean', () {
      final bean = Bean.fromJson(beanJson);
      expect(bean.name, 'Worka Chelbesa');
      expect(bean.origin, 'Ethiopia');
      expect(bean.roastLevel, 'light');
      expect(bean.tastingNotes, ['bergamot', 'peach', 'black tea']);
      expect(bean.cuppingScore, 88.25);
      expect(bean.isVerified, isTrue);
    });

    test('tolerates missing optional fields', () {
      final bean = Bean.fromJson(const {'id': 'x', 'name': 'Mystery'});
      expect(bean.roaster, isNull);
      expect(bean.tastingNotes, isEmpty);
      expect(bean.isVerified, isFalse);
    });
  });

  group('Recommendation.fromJson', () {
    test('parses nested parameters including converted grind', () {
      final rec = Recommendation.fromJson(recommendationJson);
      final p = rec.parameters!;
      expect(p.grindSetting.value, 66);
      expect(p.grindSetting.converted, isTrue);
      expect(p.grindSettingC40Clicks, 22);
      expect(p.brewTimeMinSeconds, 180);
      expect(p.brewTimeMaxSeconds, 210);
      expect(p.pressureBar, isNull);
      expect(p.notes, hasLength(1));
      expect(rec.confidenceScore, 0.95);
    });
  });

  group('BrewLog.fromJson', () {
    test('parses timestamps and numeric fields', () {
      final brew = BrewLog.fromJson(brewLogJson);
      expect(brew.rating, 4);
      expect(brew.doseG, 15.0);
      expect(brew.timestamp.isUtc, isTrue);
      expect(brew.generatedBy, 'rules');
    });
  });

  group('UserProfile.fromJson', () {
    test('parses equipment and credits', () {
      final profile = UserProfile.fromJson(profileJson);
      expect(profile.clerkId, 'dev_mobile');
      expect(profile.equipment, hasLength(1));
      expect(profile.equipment.first.burrType, 'conical');
      expect(profile.aiCredits.remaining, 2);
    });
  });

  group('constants helpers', () {
    test('formatBrewTime renders ranges and sub-minute values', () {
      expect(formatBrewTime(180, 210), '3:00–3:30');
      expect(formatBrewTime(28, 28), '28s');
      expect(formatBrewTime(25, 30), '25s–30s');
    });

    test('labels fall back gracefully', () {
      expect(roastLabel('medium_light'), 'Medium-Light');
      expect(roastLabel(null), '—');
      expect(grinderLabel('1zpresso_jx_pro'), '1Zpresso JX-Pro');
      expect(grinderLabel('unknown_grinder'), 'unknown_grinder');
      expect(processLabel('wet_hulled'), 'wet hulled');
    });
  });
}
