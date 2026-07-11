"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useState } from "react";

import RatingStars from "@/components/RatingStars";
import { api } from "@/lib/api";
import {
  BREW_BOUNDS,
  BREWERS,
  GRINDERS,
  formatBrewTime,
  roastLabel,
  type BrewBoundsKey,
} from "@/lib/constants";
import type { Bean, BrewLog, Equipment, Recommendation, UserProfile } from "@/lib/types";

const inputClass =
  "rounded-md border border-transparent bg-peri-well px-3 py-2 text-sm text-cream placeholder:text-cream-dim/70 focus:border-cream/60 focus:outline-none";

function Stat({ label, value, accent }: { label: string; value: string; accent?: boolean }) {
  return (
    <div className="rounded-lg bg-cream/25 p-3">
      <p className="text-xs uppercase tracking-wide text-ink/70">{label}</p>
      <p className={`mt-1 text-lg font-semibold ${accent ? "text-cream" : "text-ink"}`}>{value}</p>
    </div>
  );
}

const norm = (s: string) => s.toLowerCase().replace(/[^a-z0-9]/g, "");

/** Best-effort map of free-text profile equipment onto an option key. */
function matchEquipment(
  rows: Equipment[],
  type: string,
  options: readonly { key: string; label: string }[],
): string | null {
  for (const row of rows.filter((r) => r.equipment_type === type)) {
    const cand = norm(`${row.brand ?? ""}${row.model ?? ""}`);
    if (cand.length < 2) continue;
    // Prefer the longest label contained in the entry (so "1Zpresso JX-Pro"
    // beats "1Zpresso JX"), then try the reverse for model-only entries.
    const best = options
      .filter((o) => cand.includes(norm(o.label)) || (cand.length >= 4 && norm(o.label).includes(cand)))
      .sort((a, b) => norm(b.label).length - norm(a.label).length)[0];
    if (best) return best.key;
  }
  return null;
}

const BREWER_HINTS: { key: string; hints: string[] }[] = [
  { key: "espresso", hints: ["espresso"] },
  { key: "v60", hints: ["v60", "pourover", "hario"] },
  { key: "french_press", hints: ["frenchpress", "press"] },
];

function matchBrewer(rows: Equipment[]): string | null {
  for (const row of rows.filter((r) => r.equipment_type === "brewer")) {
    const cand = norm(`${row.brand ?? ""}${row.model ?? ""}`);
    const hit = BREWER_HINTS.find((b) => b.hints.some((h) => cand.includes(h)));
    if (hit) return hit.key;
  }
  return null;
}

function DialInContent() {
  const beanParam = useSearchParams().get("bean");

  const [bean, setBean] = useState<Bean | null>(null);
  const [beanError, setBeanError] = useState<string | null>(null);
  const [beanSearch, setBeanSearch] = useState("");
  const [beanResults, setBeanResults] = useState<Bean[]>([]);
  const [brewer, setBrewer] = useState<string>("v60");
  const [grinder, setGrinder] = useState<string>("");
  const [rec, setRec] = useState<Recommendation | null>(null);
  const [recLoading, setRecLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Brew log form state
  const [grindSetting, setGrindSetting] = useState("");
  const [dose, setDose] = useState("");
  const [yieldG, setYieldG] = useState("");
  const [temp, setTemp] = useState("");
  const [time, setTime] = useState("");
  const [tds, setTds] = useState("");
  const [rating, setRating] = useState<number | null>(null);
  const [notes, setNotes] = useState("");
  const [logged, setLogged] = useState(false);
  const [logging, setLogging] = useState(false);

  useEffect(() => {
    if (beanParam) {
      api.get<Bean>(`/api/v1/beans/${beanParam}`).then((res) => {
        if (res.data) {
          setBean(res.data);
          setBeanError(null);
        } else {
          setBeanError(
            res.error
              ? `That bean link didn't load (${res.error.toLowerCase()}) — it may have been removed. Pick a bean below instead.`
              : "That bean link didn't load — pick a bean below instead.",
          );
        }
      });
    }
  }, [beanParam]);

  // Default equipment from the profile — only until the user picks their own.
  useEffect(() => {
    api.get<UserProfile>("/api/v1/users/me").then((res) => {
      const equipment = res.data?.equipment ?? [];
      if (equipment.length === 0) return;
      const g = matchEquipment(equipment, "grinder", GRINDERS);
      if (g) setGrinder((cur) => cur || g);
      const b = matchBrewer(equipment);
      if (b) setBrewer((cur) => (cur === "v60" ? b : cur));
    });
  }, []);

  useEffect(() => {
    if (!beanSearch) {
      setBeanResults([]);
      return;
    }
    const t = setTimeout(async () => {
      const res = await api.get<Bean[]>(
        `/api/v1/beans?search=${encodeURIComponent(beanSearch)}&limit=6`,
      );
      setBeanResults(res.data ?? []);
    }, 250);
    return () => clearTimeout(t);
  }, [beanSearch]);

  const getRecommendation = useCallback(async () => {
    if (!bean) return;
    setRecLoading(true);
    setError(null);
    setLogged(false);
    const params = new URLSearchParams({ bean_id: bean.id, brewer });
    if (grinder) params.set("grinder", grinder);
    const res = await api.get<Recommendation>(`/api/v1/recommendations?${params}`);
    if (res.error || !res.data?.parameters) {
      setError(res.error ?? "No recommendation returned");
      setRec(null);
    } else {
      setRec(res.data);
      const p = res.data.parameters;
      setGrindSetting(String(p.grind_setting.value));
      setDose(String(p.dose_g));
      setYieldG(String(p.yield_g));
      setTemp(String(p.water_temp_c));
      setTime(String(Math.round((p.brew_time_seconds.min + p.brew_time_seconds.max) / 2)));
    }
    setRecLoading(false);
  }, [bean, brewer, grinder]);

  function parseField(key: BrewBoundsKey, raw: string, problems: string[]): number | null {
    if (!raw.trim()) return null;
    const bounds = BREW_BOUNDS[key];
    // Accept European decimal commas ("15,5").
    const n = Number(raw.trim().replace(",", "."));
    if (Number.isNaN(n)) {
      problems.push(`${bounds.label} isn't a number`);
      return null;
    }
    if (n < bounds.min || n > bounds.max) {
      problems.push(
        `${bounds.label} must be between ${bounds.min}${bounds.unit} and ${bounds.max}${bounds.unit}`,
      );
      return null;
    }
    return n;
  }

  async function logBrew() {
    if (!bean) return;
    const problems: string[] = [];
    const grindVal = parseField("grind_setting", grindSetting, problems);
    const doseVal = parseField("dose_g", dose, problems);
    const yieldVal = parseField("yield_g", yieldG, problems);
    const tempVal = parseField("water_temp_c", temp, problems);
    const timeVal = parseField("brew_time_seconds", time, problems);
    const tdsVal = parseField("tds", tds, problems);
    if (problems.length > 0) {
      setError(problems.join(". "));
      return;
    }
    setLogging(true);
    setError(null);
    const res = await api.post<BrewLog>("/api/v1/brews", {
      bean_id: bean.id,
      brewer,
      grinder: grinder || null,
      grind_setting: grindVal,
      dose_g: doseVal,
      yield_g: yieldVal,
      water_temp_c: tempVal,
      brew_time_seconds: timeVal == null ? null : Math.round(timeVal),
      tds: tdsVal,
      rating,
      notes: notes.trim() || null,
      generated_by: rec ? "rules" : "manual",
    });
    if (res.error) {
      setError(res.error);
    } else {
      setLogged(true);
    }
    setLogging(false);
  }

  // Any edit after a successful log re-arms the button (and prevents
  // accidental double-logging of the identical brew).
  const touch = (setter: (v: string) => void) => (v: string) => {
    setter(v);
    setLogged(false);
  };

  const params = rec?.parameters ?? null;

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="font-display mb-1 text-3xl tracking-tight">Dial In</h1>
      <p className="mb-8 text-cream-dim">
        Pick a bean and your gear — get parameters, brew, then log how it went.
      </p>

      {/* Step 1: bean */}
      <section className="mb-6 rounded-xl bg-peri-deep/70 p-5">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-cream-dim/80">
          1 · Bean
        </h2>
        {bean ? (
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="font-semibold">{bean.name}</p>
              <p className="text-sm text-cream-dim">
                {[bean.roaster, bean.origin, roastLabel(bean.roast_level)]
                  .filter(Boolean)
                  .join(" · ")}
                {bean.process ? ` · ${bean.process.replace("_", " ")}` : ""}
              </p>
            </div>
            <button
              onClick={() => {
                setBean(null);
                setRec(null);
              }}
              className="text-sm text-cream-dim/80 hover:text-cream"
            >
              change
            </button>
          </div>
        ) : (
          <div className="relative">
            {beanError && (
              <p className="mb-3 rounded-md bg-blush/20 p-3 text-sm text-cream">{beanError}</p>
            )}
            <input
              type="search"
              value={beanSearch}
              onChange={(e) => setBeanSearch(e.target.value)}
              placeholder="Search the bean library…"
              aria-label="Search the bean library"
              className={`${inputClass} w-full`}
            />
            {beanResults.length > 0 && (
              <ul className="absolute z-10 mt-1 w-full overflow-hidden rounded-md bg-peri-well shadow-xl">
                {beanResults.map((b) => (
                  <li key={b.id}>
                    <button
                      className="w-full px-3 py-2 text-left text-sm hover:bg-blush/25"
                      onClick={() => {
                        setBean(b);
                        setBeanSearch("");
                        setBeanResults([]);
                        setBeanError(null);
                      }}
                    >
                      <span className="font-medium">{b.name}</span>
                      <span className="text-cream-dim/80"> — {b.roaster ?? b.origin ?? ""}</span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
            {beanSearch && beanResults.length === 0 && (
              <p className="mt-2 text-sm text-cream-dim/80">
                Nothing matches “{beanSearch}” —{" "}
                <Link href="/add-bean" className="font-semibold text-blush hover:underline">
                  add it to the library
                </Link>
                .
              </p>
            )}
            <p className="mt-2 text-sm text-cream-dim/80">
              or{" "}
              <Link href="/explore" className="font-semibold text-blush hover:underline">
                browse the library
              </Link>
            </p>
          </div>
        )}
      </section>

      {/* Step 2: equipment */}
      <section className="mb-6 rounded-xl bg-peri-deep/70 p-5">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-cream-dim/80">
          2 · Equipment
        </h2>
        <div className="flex flex-wrap gap-3">
          <select
            value={brewer}
            onChange={(e) => setBrewer(e.target.value)}
            aria-label="Brewer"
            className={inputClass}
          >
            {BREWERS.map((b) => (
              <option key={b.key} value={b.key}>
                {b.label}
              </option>
            ))}
          </select>
          <select
            value={grinder}
            onChange={(e) => setGrinder(e.target.value)}
            aria-label="Grinder"
            className={inputClass}
          >
            <option value="">Grinder (optional — defaults to C40 clicks)</option>
            {GRINDERS.map((g) => (
              <option key={g.key} value={g.key}>
                {g.label}
              </option>
            ))}
          </select>
          <button
            onClick={getRecommendation}
            disabled={!bean || recLoading}
            className="rounded-md bg-blush px-5 py-2 text-sm font-medium text-ink transition-colors hover:bg-blush-deep disabled:cursor-not-allowed disabled:opacity-40"
          >
            {recLoading ? "Computing…" : "Get recommendation"}
          </button>
        </div>
      </section>

      {error && (
        <p className="mb-6 rounded-md bg-blush/20 p-4 text-cream">
          {error}
        </p>
      )}

      {/* Step 3: recommendation */}
      {params && (
        <section className="mb-6 rounded-xl bg-blush p-5 text-ink">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-sm font-bold uppercase tracking-wide text-ink">
              3 · Your recipe
            </h2>
            {rec?.confidence_score != null && (
              <span className="text-xs text-ink/70">
                confidence {(rec.confidence_score * 100).toFixed(0)}%
              </span>
            )}
          </div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            <Stat
              label={`Grind (${params.grind_setting.grinder ?? "C40"})`}
              value={`${params.grind_setting.value} ${params.grind_setting.unit}`}
              accent
            />
            <Stat label="Dose" value={`${params.dose_g} g`} />
            <Stat label="Ratio" value={params.ratio} />
            <Stat label="Water" value={`${params.water_temp_c}°C`} />
            <Stat label="Yield" value={`${params.yield_g} g`} />
            <Stat label="Time" value={formatBrewTime(params.brew_time_seconds)} />
            {params.pressure_bar && <Stat label="Pressure" value={`${params.pressure_bar} bar`} />}
          </div>
          {params.notes.length > 0 && (
            <ul className="mt-3 space-y-1 text-sm text-ink/80">
              {params.notes.map((n) => (
                <li key={n}>• {n}</li>
              ))}
            </ul>
          )}
        </section>
      )}

      {/* Step 4: log the brew */}
      {bean && (
        <section className="rounded-xl bg-peri-deep/70 p-5">
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-cream-dim/80">
            {params ? "4" : "3"} · Log the brew
          </h2>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            {(
              [
                ["Grind setting", grindSetting, setGrindSetting, "grind_setting"],
                ["Dose (g)", dose, setDose, "dose_g"],
                ["Yield (g)", yieldG, setYieldG, "yield_g"],
                ["Water temp (°C)", temp, setTemp, "water_temp_c"],
                ["Brew time (s)", time, setTime, "brew_time_seconds"],
                ["TDS (%)", tds, setTds, "tds"],
              ] as const
            ).map(([label, value, setter, boundsKey]) => (
              <label key={label} className="flex flex-col gap-1 text-xs text-cream-dim/80">
                {label}
                <input
                  type="number"
                  step="any"
                  min={BREW_BOUNDS[boundsKey].min}
                  max={BREW_BOUNDS[boundsKey].max}
                  value={value}
                  onChange={(e) => touch(setter)(e.target.value)}
                  className={inputClass}
                />
              </label>
            ))}
          </div>
          <div className="mt-3 flex items-center gap-3">
            <span className="text-xs text-cream-dim/80">Rating</span>
            <RatingStars
              value={rating}
              onChange={(r) => {
                setRating(r);
                setLogged(false);
              }}
            />
          </div>
          <textarea
            value={notes}
            onChange={(e) => touch(setNotes)(e.target.value)}
            placeholder="Tasting notes, what you'd change…"
            aria-label="Brew notes"
            rows={2}
            className={`${inputClass} mt-3 w-full`}
          />
          <div className="mt-4 flex items-center gap-3">
            <button
              onClick={logBrew}
              disabled={logging || logged}
              className="rounded-md bg-blush px-5 py-2 text-sm font-medium text-ink transition-colors hover:bg-blush-deep disabled:opacity-40"
            >
              {logging ? "Saving…" : logged ? "Logged ✓" : "Log brew"}
            </button>
            {logged && (
              <span className="text-sm font-semibold text-blush">
                Logged ✓ —{" "}
                <Link href="/journal" className="underline">
                  view journal
                </Link>
              </span>
            )}
          </div>
        </section>
      )}
    </main>
  );
}

export default function DialInPage() {
  return (
    <Suspense>
      <DialInContent />
    </Suspense>
  );
}
