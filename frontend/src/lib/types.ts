export interface ApiResponse<T = unknown> {
  data: T | null;
  error: string | null;
  meta: Record<string, unknown> | null;
}

export interface Bean {
  id: string;
  name: string;
  roaster: string | null;
  origin: string | null;
  variety: string | null;
  process: string | null;
  roast_level: string | null;
  roast_date: string | null;
  tasting_notes: string[] | null;
  cupping_score: number | null;
  source_url: string | null;
  is_verified: boolean;
  created_at: string;
}

export interface BrewLog {
  id: string;
  user_id: string;
  bean_id: string;
  brewer: string;
  grinder: string | null;
  grind_setting: number | null;
  dose_g: number | null;
  yield_g: number | null;
  water_temp_c: number | null;
  brew_time_seconds: number | null;
  tds: number | null;
  rating: number | null;
  notes: string | null;
  generated_by: string | null;
  timestamp: string;
}

export interface Recommendation {
  id: string;
  bean_id: string;
  brewer: string;
  grinder: string | null;
  parameters: Record<string, unknown> | null;
  generated_by: string;
  confidence_score: number | null;
  created_at: string;
}

export interface User {
  id: string;
  clerk_id: string;
  display_name: string | null;
  created_at: string;
}

export interface Equipment {
  equipment_type: string;
  brand: string | null;
  model: string | null;
  burr_type: string | null;
}
