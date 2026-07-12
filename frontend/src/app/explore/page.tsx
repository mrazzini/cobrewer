"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";

import BeanCard from "@/components/BeanCard";
import { BeanCardSkeleton } from "@/components/Skeleton";
import { api } from "@/lib/api";
import { PROCESSES, ROAST_LEVELS } from "@/lib/constants";
import type { Bean } from "@/lib/types";

const PAGE_SIZE = 50;

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

const selectClass = "brut-input";

export default function ExplorePage() {
  const [beans, setBeans] = useState<Bean[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [origin, setOrigin] = useState("");
  const [process, setProcess] = useState("");
  const [roastLevel, setRoastLevel] = useState("");

  const filtersActive = Boolean(search || origin || process || roastLevel);

  const buildParams = useCallback(
    (offset: number) => {
      const params = new URLSearchParams();
      if (search) params.set("search", search);
      if (origin) params.set("origin", origin);
      if (process) params.set("process", process);
      if (roastLevel) params.set("roast_level", roastLevel);
      params.set("limit", String(PAGE_SIZE));
      params.set("offset", String(offset));
      return params;
    },
    [search, origin, process, roastLevel],
  );

  const fetchBeans = useCallback(async () => {
    setLoading(true);
    const res = await api.get<Bean[]>(`/api/v1/beans?${buildParams(0)}`);
    if (res.error) {
      setError(res.error);
    } else {
      setError(null);
      setBeans(res.data ?? []);
      setTotal((res.meta?.total as number) ?? 0);
    }
    setLoading(false);
  }, [buildParams]);

  async function loadMore() {
    setLoadingMore(true);
    const res = await api.get<Bean[]>(`/api/v1/beans?${buildParams(beans.length)}`);
    if (res.error) {
      setError(res.error);
    } else {
      setBeans((prev) => [...prev, ...(res.data ?? [])]);
      setTotal((res.meta?.total as number) ?? total);
    }
    setLoadingMore(false);
  }

  useEffect(() => {
    const t = setTimeout(fetchBeans, search ? 300 : 0);
    return () => clearTimeout(t);
  }, [fetchBeans, search]);

  function clearFilters() {
    setSearch("");
    setOrigin("");
    setProcess("");
    setRoastLevel("");
  }

  return (
    <main className="mx-auto min-h-screen max-w-5xl px-6 py-10">
      <div className="mb-1 flex flex-wrap items-center justify-between gap-3">
        <h1 className="poster poster-shadow text-4xl">Explore Beans</h1>
        <Link href="/add-bean" className="brut-btn px-4 py-2 text-xs">
          Add a bean
        </Link>
      </div>
      <p className="mb-6 font-medium text-cream-dim">
        {total > 0
          ? filtersActive
            ? `${total} bean${total === 1 ? "" : "s"} match`
            : `${total} beans in the library`
          : "Find your next coffee"}
      </p>

      <div className="mb-8 flex flex-wrap gap-3">
        <input
          type="search"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search name, roaster, origin…"
          aria-label="Search beans"
          className={`${selectClass} min-w-64 flex-1`}
        />
        <select
          value={origin}
          onChange={(e) => setOrigin(e.target.value)}
          aria-label="Filter by origin"
          className={selectClass}
        >
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
          aria-label="Filter by process"
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
          aria-label="Filter by roast level"
          className={selectClass}
        >
          <option value="">All roasts</option>
          {ROAST_LEVELS.map((r) => (
            <option key={r.key} value={r.key}>
              {r.label}
            </option>
          ))}
        </select>
        {filtersActive && (
          <button onClick={clearFilters} className="brut-btn brut-btn-ghost px-3 py-2 text-xs">
            Clear all
          </button>
        )}
      </div>

      {error && (
        <p className="rounded-2xl border-[3px] border-ink bg-blush p-4 font-semibold text-ink shadow-[4px_4px_0_var(--color-ink)]">
          {error}
        </p>
      )}
      {!loading && !error && beans.length === 0 && (
        <p className="text-cream-dim/80">
          No beans match those filters —{" "}
          <Link href="/add-bean" className="font-semibold text-blush hover:underline">
            add one to the library
          </Link>
          .
        </p>
      )}

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {loading && !error
          ? Array.from({ length: 6 }, (_, i) => <BeanCardSkeleton key={i} />)
          : beans.map((bean) => <BeanCard key={bean.id} bean={bean} />)}
      </div>

      {!loading && !error && beans.length > 0 && (
        <div className="mt-8 flex flex-col items-center gap-3 pb-4">
          <p className="brut-label text-cream-dim">
            Showing {beans.length} of {total}
          </p>
          {beans.length < total && (
            <button onClick={loadMore} disabled={loadingMore} className="brut-btn px-6 py-2.5">
              {loadingMore ? "Loading…" : "Load more"}
            </button>
          )}
        </div>
      )}
    </main>
  );
}
