"use client";

import { useEffect, useState } from "react";

import { api } from "@/lib/api";
import type { Equipment, UserProfile } from "@/lib/types";

const inputClass =
  "rounded-md border border-transparent bg-peri-well px-3 py-2 text-sm text-cream placeholder:text-cream-dim/70 focus:border-cream/60 focus:outline-none";

const EMPTY_ROW: Equipment = { equipment_type: "grinder", brand: "", model: "", burr_type: "" };

export default function ProfilePage() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [equipment, setEquipment] = useState<Equipment[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    api.get<UserProfile>("/api/v1/users/me").then((res) => {
      if (res.error) {
        setError(res.error);
      } else if (res.data) {
        setProfile(res.data);
        setEquipment(res.data.equipment.length > 0 ? res.data.equipment : [{ ...EMPTY_ROW }]);
      }
    });
  }, []);

  function updateRow(index: number, patch: Partial<Equipment>) {
    setEquipment((rows) => rows.map((row, i) => (i === index ? { ...row, ...patch } : row)));
    setSaved(false);
  }

  async function save() {
    setSaving(true);
    setError(null);
    const payload = equipment.filter((e) => e.brand || e.model);
    const res = await api.put<{ equipment: Equipment[] }>("/api/v1/users/me/equipment", {
      equipment: payload.map((e) => ({
        ...e,
        brand: e.brand || null,
        model: e.model || null,
        burr_type: e.burr_type || null,
      })),
    });
    if (res.error) {
      setError(res.error);
    } else {
      setSaved(true);
      setEquipment(res.data?.equipment ?? []);
    }
    setSaving(false);
  }

  return (
    <main className="mx-auto min-h-screen max-w-3xl px-6 py-10">
      <h1 className="mb-1 text-3xl font-bold uppercase tracking-tight">Profile &amp; Equipment</h1>
      <p className="mb-8 text-cream-dim">
        Your gear feeds the recommendation engine — grind settings come back converted to your
        grinder.
      </p>

      {error && (
        <p className="mb-6 rounded-md bg-blush/20 p-4 text-cream">
          {error}
        </p>
      )}

      {profile && (
        <section className="mb-6 rounded-xl bg-peri-deep/70 p-5">
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-cream-dim/80">
            AI extraction credits
          </h2>
          <p className="text-sm text-cream">
            <span className="font-semibold text-blush">
              {profile.ai_credits.extractions_limit - profile.ai_credits.extractions_used}
            </span>{" "}
            of {profile.ai_credits.extractions_limit} free bag-photo extractions remaining
          </p>
        </section>
      )}

      <section className="rounded-xl bg-peri-deep/70 p-5">
        <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-cream-dim/80">
          Equipment
        </h2>
        <div className="space-y-3">
          {equipment.map((row, i) => (
            <div key={i} className="flex flex-wrap items-center gap-2">
              <select
                value={row.equipment_type}
                onChange={(e) => updateRow(i, { equipment_type: e.target.value })}
                className={inputClass}
              >
                <option value="grinder">Grinder</option>
                <option value="brewer">Brewer</option>
                <option value="kettle">Kettle</option>
                <option value="scale">Scale</option>
              </select>
              <input
                value={row.brand ?? ""}
                onChange={(e) => updateRow(i, { brand: e.target.value })}
                placeholder="Brand"
                className={`${inputClass} w-36`}
              />
              <input
                value={row.model ?? ""}
                onChange={(e) => updateRow(i, { model: e.target.value })}
                placeholder="Model"
                className={`${inputClass} w-36`}
              />
              {row.equipment_type === "grinder" && (
                <select
                  value={row.burr_type ?? ""}
                  onChange={(e) => updateRow(i, { burr_type: e.target.value })}
                  className={inputClass}
                >
                  <option value="">Burr type</option>
                  <option value="conical">Conical</option>
                  <option value="flat">Flat</option>
                </select>
              )}
              <button
                onClick={() => setEquipment((rows) => rows.filter((_, j) => j !== i))}
                aria-label="Remove"
                className="px-2 text-cream-dim/60 hover:text-blush"
              >
                ✕
              </button>
            </div>
          ))}
        </div>
        <div className="mt-4 flex items-center gap-3">
          <button
            onClick={() => setEquipment((rows) => [...rows, { ...EMPTY_ROW }])}
            className="rounded-md border border-cream/40 px-4 py-2 text-sm text-cream transition-colors hover:border-cream hover:bg-cream/10"
          >
            + Add equipment
          </button>
          <button
            onClick={save}
            disabled={saving}
            className="rounded-md bg-blush px-5 py-2 text-sm font-medium text-ink transition-colors hover:bg-blush-deep disabled:opacity-40"
          >
            {saving ? "Saving…" : "Save"}
          </button>
          {saved && <span className="text-sm font-semibold text-blush">Saved ✓</span>}
        </div>
      </section>
    </main>
  );
}
