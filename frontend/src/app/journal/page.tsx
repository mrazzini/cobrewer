"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import RatingStars from "@/components/RatingStars";
import { BrewCardSkeleton } from "@/components/Skeleton";
import { api } from "@/lib/api";
import { brewerLabel, formatBrewTime, grinderLabel } from "@/lib/constants";
import type { BrewLog } from "@/lib/types";

export default function JournalPage() {
  const [brews, setBrews] = useState<BrewLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const res = await api.get<BrewLog[]>("/api/v1/brews");
      if (res.error) {
        setError(res.error);
      } else {
        setBrews(res.data ?? []);
      }
      setLoading(false);
    })();
  }, []);

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="poster poster-shadow mb-1 text-4xl">Brew Journal</h1>
      <p className="mb-8 font-medium text-cream-dim">
        {brews.length > 0
          ? `${brews.length} brew${brews.length === 1 ? "" : "s"} logged`
          : "Every cup you log makes the next recommendation smarter."}
      </p>

      {error && (
        <p className="rounded-2xl border-[3px] border-ink bg-blush p-4 font-semibold text-ink shadow-[4px_4px_0_var(--color-ink)]">
          {error}
        </p>
      )}
      {loading && !error && (
        <div className="space-y-4">
          {Array.from({ length: 3 }, (_, i) => (
            <BrewCardSkeleton key={i} />
          ))}
        </div>
      )}
      {!loading && !error && brews.length === 0 && (
        <p className="text-cream-dim/80">
          No brews yet —{" "}
          <Link href="/dial-in" className="font-semibold text-blush hover:underline">
            dial one in
          </Link>
          .
        </p>
      )}

      <ul className="space-y-4">
        {brews.map((brew) => (
          <li key={brew.id} className="brut-card p-5">
            <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
              <div>
                <p className="poster text-lg">{brew.bean?.name ?? "Unknown bean"}</p>
                <p className="text-sm font-semibold text-ink-soft">
                  {[brew.bean?.roaster, brewerLabel(brew.brewer)].filter(Boolean).join(" · ")}
                </p>
              </div>
              <div className="flex flex-col items-end gap-1">
                {brew.rating != null ? (
                  <RatingStars value={brew.rating} />
                ) : (
                  <span className="brut-label text-ink-soft/70">unrated</span>
                )}
                <p className="text-xs font-semibold text-ink-soft">
                  {new Date(brew.timestamp).toLocaleDateString(undefined, {
                    day: "numeric",
                    month: "short",
                    year: "numeric",
                  })}
                </p>
              </div>
            </div>
            <div className="flex flex-wrap gap-x-5 gap-y-1 text-sm font-medium text-ink-soft">
              {brew.grind_setting != null && (
                <span>
                  grind {brew.grind_setting}
                  {brew.grinder ? ` (${grinderLabel(brew.grinder)})` : ""}
                </span>
              )}
              {brew.dose_g != null && <span>{brew.dose_g} g in</span>}
              {brew.yield_g != null && <span>{brew.yield_g} g out</span>}
              {brew.water_temp_c != null && <span>{brew.water_temp_c}°C</span>}
              {brew.brew_time_seconds != null && (
                <span>{formatBrewTime({ min: brew.brew_time_seconds, max: brew.brew_time_seconds })}</span>
              )}
              {brew.tds != null && <span>TDS {brew.tds}%</span>}
              {brew.generated_by && (
                <span className="brut-label text-ink-soft/70">
                  {brew.generated_by === "rules" ? "from recipe" : "logged manually"}
                </span>
              )}
            </div>
            {brew.notes && <p className="mt-2 text-sm font-medium italic text-ink">{brew.notes}</p>}
          </li>
        ))}
      </ul>
    </main>
  );
}
