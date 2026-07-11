"use client";

import { useCallback, useEffect, useState } from "react";

import BeanCard from "@/components/BeanCard";
import { api } from "@/lib/api";
import { PROCESSES, ROAST_LEVELS } from "@/lib/constants";
import type { Bean } from "@/lib/types";

const ORIGINS = [
  "Ethiopia",
  "Kenya",
  "Colombia",
  "Guatemala",
  "Brazil",
  "Costa Rica",
  "Panama",
  "El Salvador",
  "Peru",
  "Rwanda",
  "Burundi",
  "Indonesia",
  "Honduras",
  "Ecuador",
];

const selectClass =
  "rounded-md border border-transparent bg-peri-well px-3 py-2 text-sm text-cream placeholder:text-cream-dim/70 focus:border-cream/60 focus:outline-none";

export default function ExplorePage() {
  const [beans, setBeans] = useState<Bean[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [origin, setOrigin] = useState("");
  const [process, setProcess] = useState("");
  const [roastLevel, setRoastLevel] = useState("");

  const fetchBeans = useCallback(async () => {
    setLoading(true);
    const params = new URLSearchParams();
    if (search) params.set("search", search);
    if (origin) params.set("origin", origin);
    if (process) params.set("process", process);
    if (roastLevel) params.set("roast_level", roastLevel);
    const res = await api.get<Bean[]>(`/api/v1/beans?${params}`);
    if (res.error) {
      setError(res.error);
    } else {
      setError(null);
      setBeans(res.data ?? []);
      setTotal((res.meta?.total as number) ?? 0);
    }
    setLoading(false);
  }, [search, origin, process, roastLevel]);

  useEffect(() => {
    const t = setTimeout(fetchBeans, search ? 300 : 0);
    return () => clearTimeout(t);
  }, [fetchBeans, search]);

  return (
    <main className="mx-auto min-h-screen max-w-5xl px-6 py-10">
      <h1 className="font-display mb-1 text-3xl tracking-tight">Explore Beans</h1>
      <p className="mb-6 text-cream-dim">
        {total > 0 ? `${total} beans in the library` : "Find your next coffee"}
      </p>

      <div className="mb-8 flex flex-wrap gap-3">
        <input
          type="search"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search name, roaster, origin…"
          className={`${selectClass} min-w-64 flex-1`}
        />
        <select value={origin} onChange={(e) => setOrigin(e.target.value)} className={selectClass}>
          <option value="">All origins</option>
          {ORIGINS.map((o) => (
            <option key={o} value={o}>
              {o}
            </option>
          ))}
        </select>
        <select
          value={process}
          onChange={(e) => setProcess(e.target.value)}
          className={selectClass}
        >
          <option value="">All processes</option>
          {PROCESSES.map((p) => (
            <option key={p} value={p} className="capitalize">
              {p.replace("_", " ")}
            </option>
          ))}
        </select>
        <select
          value={roastLevel}
          onChange={(e) => setRoastLevel(e.target.value)}
          className={selectClass}
        >
          <option value="">All roasts</option>
          {ROAST_LEVELS.map((r) => (
            <option key={r.key} value={r.key}>
              {r.label}
            </option>
          ))}
        </select>
      </div>

      {error && (
        <p className="rounded-md bg-blush/20 p-4 text-cream">
          {error}
        </p>
      )}
      {loading && !error && <p className="text-cream-dim/80">Brewing up results…</p>}
      {!loading && !error && beans.length === 0 && (
        <p className="text-cream-dim/80">No beans match those filters.</p>
      )}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {beans.map((bean) => (
          <BeanCard key={bean.id} bean={bean} />
        ))}
      </div>
    </main>
  );
}
