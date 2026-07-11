"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

import RatingStars from "@/components/RatingStars";
import { api } from "@/lib/api";
import { formatBrewTime } from "@/lib/constants";
import type { Bean, BrewLog } from "@/lib/types";

export default function JournalPage() {
  const [brews, setBrews] = useState<BrewLog[]>([]);
  const [beans, setBeans] = useState<Record<string, Bean>>({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      const res = await api.get<BrewLog[]>("/api/v1/brews");
      if (res.error) {
        setError(res.error);
        setLoading(false);
        return;
      }
      const logs = res.data ?? [];
      setBrews(logs);
      const beanIds = [...new Set(logs.map((b) => b.bean_id))];
      const results = await Promise.all(
        beanIds.map((id) => api.get<Bean>(`/api/v1/beans/${id}`)),
      );
      const byId: Record<string, Bean> = {};
      for (const r of results) {
        if (r.data) byId[r.data.id] = r.data;
      }
      setBeans(byId);
      setLoading(false);
    })();
  }, []);

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="font-display mb-1 text-3xl tracking-tight">Brew Journal</h1>
      <p className="mb-8 text-cream-dim">
        {brews.length > 0
          ? `${brews.length} brew${brews.length === 1 ? "" : "s"} logged`
          : "Every cup you log makes the next recommendation smarter."}
      </p>

      {error && (
        <p className="rounded-md bg-blush/20 p-4 text-cream">
          {error}
        </p>
      )}
      {loading && !error && <p className="text-cream-dim/80">Pouring over your history…</p>}
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
        {brews.map((brew) => {
          const bean = beans[brew.bean_id];
          return (
            <li
              key={brew.id}
              className="rounded-xl bg-peri-deep/70 p-5"
            >
              <div className="mb-2 flex flex-wrap items-start justify-between gap-2">
                <div>
                  <p className="font-semibold">{bean?.name ?? "Unknown bean"}</p>
                  <p className="text-sm text-cream-dim">
                    {[bean?.roaster, brew.brewer.replace("_", " ")].filter(Boolean).join(" · ")}
                  </p>
                </div>
                <div className="flex flex-col items-end gap-1">
                  <RatingStars value={brew.rating} />
                  <p className="text-xs text-cream-dim/80">
                    {new Date(brew.timestamp).toLocaleDateString(undefined, {
                      day: "numeric",
                      month: "short",
                      year: "numeric",
                    })}
                  </p>
                </div>
              </div>
              <div className="flex flex-wrap gap-x-5 gap-y-1 text-sm text-cream-dim">
                {brew.grind_setting != null && <span>grind {brew.grind_setting}</span>}
                {brew.dose_g != null && <span>{brew.dose_g} g in</span>}
                {brew.yield_g != null && <span>{brew.yield_g} g out</span>}
                {brew.water_temp_c != null && <span>{brew.water_temp_c}°C</span>}
                {brew.brew_time_seconds != null && (
                  <span>{formatBrewTime({ min: brew.brew_time_seconds, max: brew.brew_time_seconds })}</span>
                )}
                {brew.tds != null && <span>TDS {brew.tds}%</span>}
                {brew.generated_by && (
                  <span className="text-cream-dim/60">via {brew.generated_by}</span>
                )}
              </div>
              {brew.notes && <p className="mt-2 text-sm italic text-cream">{brew.notes}</p>}
            </li>
          );
        })}
      </ul>
    </main>
  );
}
