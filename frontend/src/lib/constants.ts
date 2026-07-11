// Keys must match the backend recommendation engine's alias/conversion tables.

export const BREWERS = [
  { key: "v60", label: "V60 / Pour Over" },
  { key: "espresso", label: "Espresso" },
  { key: "french_press", label: "French Press" },
] as const;

export const GRINDERS = [
  { key: "comandante_c40", label: "Comandante C40" },
  { key: "1zpresso_jx", label: "1Zpresso JX" },
  { key: "1zpresso_jx_pro", label: "1Zpresso JX-Pro" },
  { key: "1zpresso_k_plus", label: "1Zpresso K-Plus" },
  { key: "timemore_c2", label: "Timemore C2" },
  { key: "timemore_c3", label: "Timemore C3" },
  { key: "baratza_encore", label: "Baratza Encore" },
  { key: "baratza_virtuoso", label: "Baratza Virtuoso+" },
  { key: "fellow_ode_gen2", label: "Fellow Ode Gen 2" },
  { key: "niche_zero", label: "Niche Zero" },
  { key: "wilfa_uniform", label: "Wilfa Uniform" },
  { key: "hario_skerton", label: "Hario Skerton" },
] as const;

export const PROCESSES = ["washed", "natural", "honey", "anaerobic", "wet_hulled"] as const;

export const ROAST_LEVELS = [
  { key: "light", label: "Light" },
  { key: "medium_light", label: "Medium-Light" },
  { key: "medium", label: "Medium" },
  { key: "medium_dark", label: "Medium-Dark" },
  { key: "dark", label: "Dark" },
] as const;

export function roastLabel(key: string | null): string {
  if (!key) return "—";
  return ROAST_LEVELS.find((r) => r.key === key)?.label ?? key;
}

export function formatBrewTime(range: { min: number; max: number }): string {
  const fmt = (s: number) =>
    s >= 60 ? `${Math.floor(s / 60)}:${String(s % 60).padStart(2, "0")}` : `${s}s`;
  return range.min === range.max ? fmt(range.min) : `${fmt(range.min)}–${fmt(range.max)}`;
}
