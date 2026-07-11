/// Dart models mirroring the backend Pydantic schemas
/// (and frontend/src/lib/types.ts).
library;

class Bean {
  final String id;
  final String name;
  final String? roaster;
  final String? origin;
  final String? variety;
  final String? process;
  final String? roastLevel;
  final String? roastDate;
  final List<String> tastingNotes;
  final double? cuppingScore;
  final String? sourceUrl;
  final bool isVerified;

  const Bean({
    required this.id,
    required this.name,
    this.roaster,
    this.origin,
    this.variety,
    this.process,
    this.roastLevel,
    this.roastDate,
    this.tastingNotes = const [],
    this.cuppingScore,
    this.sourceUrl,
    this.isVerified = false,
  });

  factory Bean.fromJson(Map<String, dynamic> json) => Bean(
        id: json['id'] as String,
        name: json['name'] as String,
        roaster: json['roaster'] as String?,
        origin: json['origin'] as String?,
        variety: json['variety'] as String?,
        process: json['process'] as String?,
        roastLevel: json['roast_level'] as String?,
        roastDate: json['roast_date'] as String?,
        tastingNotes: (json['tasting_notes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        cuppingScore: (json['cupping_score'] as num?)?.toDouble(),
        sourceUrl: json['source_url'] as String?,
        isVerified: json['is_verified'] as bool? ?? false,
      );
}

class GrindSetting {
  final String? grinder;
  final num value;
  final String unit;
  final String reference;
  final bool converted;

  const GrindSetting({
    this.grinder,
    required this.value,
    required this.unit,
    required this.reference,
    required this.converted,
  });

  factory GrindSetting.fromJson(Map<String, dynamic> json) => GrindSetting(
        grinder: json['grinder'] as String?,
        value: json['value'] as num,
        unit: json['unit'] as String? ?? 'clicks',
        reference: json['reference'] as String? ?? '',
        converted: json['converted'] as bool? ?? false,
      );
}

class RecommendationParameters {
  final String brewer;
  final GrindSetting grindSetting;
  final int grindSettingC40Clicks;
  final double doseG;
  final String ratio;
  final double yieldG;
  final double waterTempC;
  final int brewTimeMinSeconds;
  final int brewTimeMaxSeconds;
  final int? pressureBar;
  final List<String> notes;

  const RecommendationParameters({
    required this.brewer,
    required this.grindSetting,
    required this.grindSettingC40Clicks,
    required this.doseG,
    required this.ratio,
    required this.yieldG,
    required this.waterTempC,
    required this.brewTimeMinSeconds,
    required this.brewTimeMaxSeconds,
    this.pressureBar,
    this.notes = const [],
  });

  factory RecommendationParameters.fromJson(Map<String, dynamic> json) {
    final time = json['brew_time_seconds'] as Map<String, dynamic>? ?? const {};
    return RecommendationParameters(
      brewer: json['brewer'] as String,
      grindSetting:
          GrindSetting.fromJson(json['grind_setting'] as Map<String, dynamic>),
      grindSettingC40Clicks: (json['grind_setting_c40_clicks'] as num).toInt(),
      doseG: (json['dose_g'] as num).toDouble(),
      ratio: json['ratio'] as String,
      yieldG: (json['yield_g'] as num).toDouble(),
      waterTempC: (json['water_temp_c'] as num).toDouble(),
      brewTimeMinSeconds: (time['min'] as num? ?? 0).toInt(),
      brewTimeMaxSeconds: (time['max'] as num? ?? 0).toInt(),
      pressureBar: (json['pressure_bar'] as num?)?.toInt(),
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }
}

class Recommendation {
  final String id;
  final String beanId;
  final String brewer;
  final String? grinder;
  final RecommendationParameters? parameters;
  final String generatedBy;
  final double? confidenceScore;

  const Recommendation({
    required this.id,
    required this.beanId,
    required this.brewer,
    this.grinder,
    this.parameters,
    required this.generatedBy,
    this.confidenceScore,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        id: json['id'] as String,
        beanId: json['bean_id'] as String,
        brewer: json['brewer'] as String,
        grinder: json['grinder'] as String?,
        parameters: json['parameters'] == null
            ? null
            : RecommendationParameters.fromJson(
                json['parameters'] as Map<String, dynamic>),
        generatedBy: json['generated_by'] as String? ?? 'rules',
        confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
      );
}

class BrewLog {
  final String id;
  final String beanId;
  final String brewer;
  final String? grinder;
  final num? grindSetting;
  final double? doseG;
  final double? yieldG;
  final double? waterTempC;
  final int? brewTimeSeconds;
  final double? tds;
  final int? rating;
  final String? notes;
  final String? generatedBy;
  final DateTime timestamp;

  const BrewLog({
    required this.id,
    required this.beanId,
    required this.brewer,
    this.grinder,
    this.grindSetting,
    this.doseG,
    this.yieldG,
    this.waterTempC,
    this.brewTimeSeconds,
    this.tds,
    this.rating,
    this.notes,
    this.generatedBy,
    required this.timestamp,
  });

  factory BrewLog.fromJson(Map<String, dynamic> json) => BrewLog(
        id: json['id'] as String,
        beanId: json['bean_id'] as String,
        brewer: json['brewer'] as String,
        grinder: json['grinder'] as String?,
        grindSetting: json['grind_setting'] as num?,
        doseG: (json['dose_g'] as num?)?.toDouble(),
        yieldG: (json['yield_g'] as num?)?.toDouble(),
        waterTempC: (json['water_temp_c'] as num?)?.toDouble(),
        brewTimeSeconds: (json['brew_time_seconds'] as num?)?.toInt(),
        tds: (json['tds'] as num?)?.toDouble(),
        rating: (json['rating'] as num?)?.toInt(),
        notes: json['notes'] as String?,
        generatedBy: json['generated_by'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class Equipment {
  final String equipmentType;
  final String? brand;
  final String? model;
  final String? burrType;

  const Equipment({
    required this.equipmentType,
    this.brand,
    this.model,
    this.burrType,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) => Equipment(
        equipmentType: json['equipment_type'] as String,
        brand: json['brand'] as String?,
        model: json['model'] as String?,
        burrType: json['burr_type'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'equipment_type': equipmentType,
        'brand': brand,
        'model': model,
        'burr_type': burrType,
      };
}

class AiCredits {
  final int extractionsUsed;
  final int extractionsLimit;

  const AiCredits({required this.extractionsUsed, required this.extractionsLimit});

  int get remaining =>
      (extractionsLimit - extractionsUsed).clamp(0, extractionsLimit);

  factory AiCredits.fromJson(Map<String, dynamic> json) => AiCredits(
        extractionsUsed: (json['extractions_used'] as num? ?? 0).toInt(),
        extractionsLimit: (json['extractions_limit'] as num? ?? 3).toInt(),
      );
}

class UserProfile {
  final String id;
  final String clerkId;
  final String? displayName;
  final List<Equipment> equipment;
  final AiCredits aiCredits;

  const UserProfile({
    required this.id,
    required this.clerkId,
    this.displayName,
    this.equipment = const [],
    this.aiCredits = const AiCredits(extractionsUsed: 0, extractionsLimit: 3),
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        clerkId: json['clerk_id'] as String,
        displayName: json['display_name'] as String?,
        equipment: (json['equipment'] as List<dynamic>?)
                ?.map((e) => Equipment.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        aiCredits: json['ai_credits'] == null
            ? const AiCredits(extractionsUsed: 0, extractionsLimit: 3)
            : AiCredits.fromJson(json['ai_credits'] as Map<String, dynamic>),
      );
}
