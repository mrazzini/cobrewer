"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useState } from "react";

import RatingStars from "@/components/RatingStars";
import { api } from "@/lib/api";
import { BREWERS, GRINDERS, formatBrewTime, roastLabel } from "@/lib/constants";
import type { Bean, BrewLog, Recommendation } from "@/lib/types";

const inputClass =
  "rounded-md border border-neutral-800 bg-neutral-900 px-3 py-2 text-sm text-neutral-200 focus:border-green-400/60 focus:outline-none";

function Stat({ label, value, accent }: { label: string; value: string; accent?: boolean }) {
  return (
    <div className="rounded-lg border border-neutral-800 bg-neutral-950 p-3">
      <p className="text-xs uppercase tracking-wide text-neutral-500">{label}</p>
      <p className={`mt-1 text-lg font-semibold ${accent ? "text-green-400" : ""}`}>{value}</p>
    </div>
  );
}

function DialInContent() {
  const beanParam = useSearchParams().get("bean");

  const [bean, setBean] = useState<Bean | null>(null);
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
  const [rating, setRating] = useState<number | null>(null);
  const [notes, setNotes] = useState("");
  const [logged, setLogged] = useState(false);
  const [logging, setLogging] = useState(false);

  useEffect(() => {
    if (beanParam) {
      api.get<Bean>(`/api/v1/beans/${beanParam}`).then((res) => {
        if (res.data) setBean(res.data);
      });
    }
  }, [beanParam]);

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

  async function logBrew() {
    if (!bean) return;
    setLogging(true);
    setError(null);
    const res = await api.post<BrewLog>("/api/v1/brews", {
      bean_id: bean.id,
      brewer,
      grinder: grinder || null,
      grind_setting: grindSetting ? Number(grindSetting) : null,
      dose_g: dose ? Number(dose) : null,
      yield_g: yieldG ? Number(yieldG) : null,
      water_temp_c: temp ? Number(temp) : null,
      brew_time_seconds: time ? Number(time) : null,
      rating,
      notes: notes || null,
      generated_by: rec ? "rules" : "manual",
    });
    if (res.error) {
      setError(res.error);
    } else {
      setLogged(true);
    }
    setLogging(false);
  }

  const params = rec?.parameters ?? null;

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="mb-1 text-3xl font-bold">Dial In</h1>
      <p className="mb-8 text-neutral-400">
        Pick a bean and your gear — get parameters, brew, then log how it went.
      </p>

      {/* Step 1: bean */}
      <section className="mb-6 rounded-xl border border-neutral-800 bg-neutral-900/60 p-5">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-neutral-500">
          1 · Bean
        </h2>
        {bean ? (
          <div className="flex items-start justify-between gap-3">
            <div>
              <p className="font-semibold">{bean.name}</p>
              <p className="text-sm text-neutral-400">
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
              className="text-sm text-neutral-500 hover:text-white"
            >
              change
            </button>
          </div>
        ) : (
          <div className="relative">
            <input
              type="search"
              value={beanSearch}
              onChange={(e) => setBeanSearch(e.target.value)}
              placeholder="Search the bean library…"
              className={`${inputClass} w-full`}
            />
            {beanResults.length > 0 && (
              <ul className="absolute z-10 mt-1 w-full overflow-hidden rounded-md border border-neutral-800 bg-neutral-900 shadow-xl">
                {beanResults.map((b) => (
                  <li key={b.id}>
                    <button
                      className="w-full px-3 py-2 text-left text-sm hover:bg-green-400/10"
                      onClick={() => {
                        setBean(b);
                        setBeanSearch("");
                        setBeanResults([]);
                      }}
                    >
                      <span className="font-medium">{b.name}</span>
                      <span className="text-neutral-500"> — {b.roaster ?? b.origin ?? ""}</span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
            <p className="mt-2 text-sm text-neutral-500">
              or <Link href="/explore" className="text-green-400 hover:underline">browse the library</Link>
            </p>
          </div>
        )}
      </section>

      {/* Step 2: equipment */}
      <section className="mb-6 rounded-xl border border-neutral-800 bg-neutral-900/60 p-5">
        <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-neutral-500">
          2 · Equipment
        </h2>
        <div className="flex flex-wrap gap-3">
          <select value={brewer} onChange={(e) => setBrewer(e.target.value)} className={inputClass}>
            {BREWERS.map((b) => (
              <option key={b.key} value={b.key}>
                {b.label}
              </option>
            ))}
          </select>
          <select
            value={grinder}
            onChange={(e) => setGrinder(e.target.value)}
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
            className="rounded-md bg-green-500 px-5 py-2 text-sm font-medium text-neutral-950 transition-colors hover:bg-green-400 disabled:cursor-not-allowed disabled:opacity-40"
          >
            {recLoading ? "Computing…" : "Get recommendation"}
          </button>
        </div>
      </section>

      {error && (
        <p className="mb-6 rounded-md border border-amber-500/40 bg-amber-500/5 p-4 text-amber-500">
          {error}
        </p>
      )}

      {/* Step 3: recommendation */}
      {params && (
        <section className="mb-6 rounded-xl border border-green-400/30 bg-green-400/5 p-5">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="text-sm font-semibold uppercase tracking-wide text-green-400">
              3 · Your recipe
            </h2>
            {rec?.confidence_score != null && (
              <span className="text-xs text-neutral-400">
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
            <ul className="mt-3 space-y-1 text-sm text-neutral-400">
              {params.notes.map((n) => (
                <li key={n}>• {n}</li>
              ))}
            </ul>
          )}
        </section>
      )}

      {/* Step 4: log the brew */}
      {bean && (
        <section className="rounded-xl border border-neutral-800 bg-neutral-900/60 p-5">
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-neutral-500">
            {params ? "4" : "3"} · Log the brew
          </h2>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
            {(
              [
                ["Grind setting", grindSetting, setGrindSetting],
                ["Dose (g)", dose, setDose],
                ["Yield (g)", yieldG, setYieldG],
                ["Water temp (°C)", temp, setTemp],
                ["Brew time (s)", time, setTime],
              ] as const
            ).map(([label, value, setter]) => (
              <label key={label} className="flex flex-col gap-1 text-xs text-neutral-500">
                {label}
                <input
                  type="number"
                  step="any"
                  value={value}
                  onChange={(e) => setter(e.target.value)}
                  className={inputClass}
                />
              </label>
            ))}
            <label className="flex flex-col gap-1 text-xs text-neutral-500">
              Rating
              <RatingStars value={rating} onChange={setRating} />
            </label>
          </div>
          <textarea
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Tasting notes, what you'd change…"
            rows={2}
            className={`${inputClass} mt-3 w-full`}
          />
          <div className="mt-4 flex items-center gap-3">
            <button
              onClick={logBrew}
              disabled={logging}
              className="rounded-md bg-green-500 px-5 py-2 text-sm font-medium text-neutral-950 transition-colors hover:bg-green-400 disabled:opacity-40"
            >
              {logging ? "Saving…" : "Log brew"}
            </button>
            {logged && (
              <span className="text-sm text-green-400">
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
