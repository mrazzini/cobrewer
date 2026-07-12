"use client";

import Link from "next/link";
import { useEffect, useRef, useState } from "react";

import { api } from "@/lib/api";
import { PROCESSES, ROAST_LEVELS } from "@/lib/constants";
import type { Bean, ExtractionResult, UserProfile } from "@/lib/types";

const inputClass = "brut-input";

export default function AddBeanPage() {
  const fileInput = useRef<HTMLInputElement>(null);
  const [file, setFile] = useState<File | null>(null);
  const [extracting, setExtracting] = useState(false);
  const [credits, setCredits] = useState<{ used: number; limit: number } | null>(null);

  const [name, setName] = useState("");
  const [roaster, setRoaster] = useState("");
  const [origin, setOrigin] = useState("");
  const [variety, setVariety] = useState("");
  const [process, setProcess] = useState("");
  const [roastLevel, setRoastLevel] = useState("");
  const [tastingNotes, setTastingNotes] = useState("");
  const [cuppingScore, setCuppingScore] = useState("");
  const [sourceUrl, setSourceUrl] = useState("");

  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [created, setCreated] = useState<Bean | null>(null);

  useEffect(() => {
    api.get<UserProfile>("/api/v1/users/me").then((res) => {
      if (res.data) {
        setCredits({
          used: res.data.ai_credits.extractions_used,
          limit: res.data.ai_credits.extractions_limit,
        });
      }
    });
  }, []);

  async function extract() {
    if (!file) return;
    setExtracting(true);
    setError(null);
    const form = new FormData();
    form.append("file", file);
    const res = await api.postForm<ExtractionResult>("/api/v1/extract/bag-photo", form);
    if (res.error || !res.data) {
      setError(res.error ?? "Extraction returned nothing — fill the details in by hand.");
    } else {
      const d = res.data;
      if (d.name) setName(d.name);
      if (d.roaster) setRoaster(d.roaster);
      if (d.origin) setOrigin(d.origin);
      if (d.variety) setVariety(d.variety);
      if (d.process) setProcess(d.process);
      if (d.roast_level) setRoastLevel(d.roast_level);
      if (d.tasting_notes?.length) setTastingNotes(d.tasting_notes.join(", "));
      const used = res.meta?.extractions_used as number | undefined;
      const limit = res.meta?.extractions_limit as number | undefined;
      if (used != null && limit != null) setCredits({ used, limit });
    }
    setExtracting(false);
  }

  async function submit() {
    if (!name.trim()) {
      setError("The bean needs a name.");
      return;
    }
    const score = cuppingScore.trim() ? Number(cuppingScore.replace(",", ".")) : null;
    if (score != null && (Number.isNaN(score) || score < 0 || score > 100)) {
      setError("Cupping score must be a number between 0 and 100.");
      return;
    }
    setSubmitting(true);
    setError(null);
    const notes = tastingNotes
      .split(",")
      .map((n) => n.trim())
      .filter(Boolean);
    const res = await api.post<Bean>("/api/v1/beans", {
      name: name.trim(),
      roaster: roaster.trim() || null,
      origin: origin.trim() || null,
      variety: variety.trim() || null,
      process: process || null,
      roast_level: roastLevel || null,
      tasting_notes: notes.length > 0 ? notes : null,
      cupping_score: score,
      source_url: sourceUrl.trim() || null,
    });
    if (res.error || !res.data) {
      setError(res.error ?? "Could not save the bean.");
    } else {
      setCreated(res.data);
    }
    setSubmitting(false);
  }

  const creditsLeft = credits ? credits.limit - credits.used : null;

  if (created) {
    return (
      <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
        <h1 className="poster poster-shadow mb-1 text-4xl">Bean Added</h1>
        <section className="brut-card mt-6 bg-blush p-6">
          <p className="poster text-xl">{created.name}</p>
          <p className="text-sm font-semibold text-ink/80">
            {[created.roaster, created.origin].filter(Boolean).join(" · ")}
          </p>
          <p className="mt-2 text-sm font-medium text-ink/80">
            It joins the library as a community bean — searchable by everyone right away.
          </p>
          <div className="mt-4 flex flex-wrap gap-3">
            <Link
              href={`/dial-in?bean=${created.id}`}
              className="rounded-xl border-[3px] border-ink bg-ink px-4 py-2 text-sm font-bold text-cream transition-opacity hover:opacity-85"
            >
              Dial it in
            </Link>
            <Link href="/explore" className="brut-btn brut-btn-ghost px-4 py-2 shadow-[3px_3px_0_var(--color-ink)]">
              Back to Explore
            </Link>
          </div>
        </section>
      </main>
    );
  }

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="poster poster-shadow mb-1 text-4xl">Add a Bean</h1>
      <p className="mb-8 font-medium text-cream-dim">
        Coffee not in the library? Snap the bag and let AI fill in the details, or type them
        yourself.
      </p>

      {/* Step 1: photo extraction */}
      <section className="brut-card mb-6 p-5">
        <h2 className="poster mb-3 text-[15px] tracking-wide">
          1 · Snap the bag <span className="font-sans text-xs font-bold text-ink-soft">(optional)</span>
        </h2>
        <div className="flex flex-wrap items-center gap-3">
          <input
            ref={fileInput}
            type="file"
            accept="image/jpeg,image/png,image/webp,image/heic"
            aria-label="Bag photo"
            onChange={(e) => setFile(e.target.files?.[0] ?? null)}
            className="text-sm font-medium text-ink-soft file:mr-3 file:cursor-pointer file:rounded-full file:border-0 file:bg-ink file:px-4 file:py-2 file:text-sm file:font-bold file:text-cream"
          />
          <button
            onClick={extract}
            disabled={!file || extracting || creditsLeft === 0}
            className="brut-btn px-5 py-2"
          >
            {extracting ? "Reading the bag…" : "Extract details"}
          </button>
        </div>
        {creditsLeft != null && (
          <p className="mt-3 text-xs font-semibold text-ink-soft">
            {creditsLeft === 0
              ? "You've used all your free extractions — the form below still works."
              : `${creditsLeft} of ${credits!.limit} free extractions left · each photo costs 1`}
          </p>
        )}
      </section>

      {/* Step 2: details */}
      <section className="brut-card p-5">
        <h2 className="poster mb-4 text-[15px] tracking-wide">2 · Bean details</h2>
        <div className="grid gap-3 sm:grid-cols-2">
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Name *
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="e.g. Chelbesa Lot 5"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Roaster
            <input
              value={roaster}
              onChange={(e) => setRoaster(e.target.value)}
              placeholder="e.g. The Barn"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Origin
            <input
              value={origin}
              onChange={(e) => setOrigin(e.target.value)}
              placeholder="e.g. Ethiopia, Yirgacheffe"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Variety
            <input
              value={variety}
              onChange={(e) => setVariety(e.target.value)}
              placeholder="e.g. Heirloom"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Process
            <select
              value={process}
              onChange={(e) => setProcess(e.target.value)}
              className={inputClass}
            >
              <option value="">Unknown</option>
              {PROCESSES.map((p) => (
                <option key={p} value={p} className="capitalize">
                  {p.replace("_", " ")}
                </option>
              ))}
            </select>
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Roast level
            <select
              value={roastLevel}
              onChange={(e) => setRoastLevel(e.target.value)}
              className={inputClass}
            >
              <option value="">Unknown</option>
              {ROAST_LEVELS.map((r) => (
                <option key={r.key} value={r.key}>
                  {r.label}
                </option>
              ))}
            </select>
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft sm:col-span-2">
            Tasting notes <span className="normal-case tracking-normal">(comma-separated)</span>
            <input
              value={tastingNotes}
              onChange={(e) => setTastingNotes(e.target.value)}
              placeholder="jasmine, peach, black tea"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Cupping score
            <input
              type="number"
              step="any"
              min={0}
              max={100}
              value={cuppingScore}
              onChange={(e) => setCuppingScore(e.target.value)}
              placeholder="e.g. 87.5"
              className={inputClass}
            />
          </label>
          <label className="brut-label flex flex-col gap-1 text-ink-soft">
            Source URL
            <input
              type="url"
              value={sourceUrl}
              onChange={(e) => setSourceUrl(e.target.value)}
              placeholder="https://…"
              className={inputClass}
            />
          </label>
        </div>

        {error && (
          <p className="mt-4 rounded-xl border-[2.5px] border-ink bg-blush p-3 text-sm font-semibold text-ink">{error}</p>
        )}

        <button onClick={submit} disabled={submitting} className="brut-btn mt-4 px-6 py-2.5">
          {submitting ? "Saving…" : "Add to library"}
        </button>
      </section>
    </main>
  );
}
