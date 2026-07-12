"use client";

import { useEffect, useState } from "react";

import { api } from "@/lib/api";
import type { Equipment, UserProfile } from "@/lib/types";

const inputClass = "brut-input";

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
      <h1 className="poster poster-shadow mb-1 text-4xl">Profile &amp; Equipment</h1>
      <p className="mb-8 font-medium text-cream-dim">
        Your gear feeds the recommendation engine — grind settings come back converted to your
        grinder.
      </p>

      {error && (
        <p className="mb-6 rounded-2xl border-[3px] border-ink bg-blush p-4 font-semibold text-ink shadow-[4px_4px_0_var(--color-ink)]">
          {error}
        </p>
      )}

      {profile && (
        <section className="brut-card mb-6 p-5">
          <h2 className="poster mb-3 text-[15px] tracking-wide">AI extraction credits</h2>
          <p className="text-sm font-medium text-ink-soft">
            <span className="brut-chip mr-1 bg-olive">
              {profile.ai_credits.extractions_limit - profile.ai_credits.extractions_used} of{" "}
              {profile.ai_credits.extractions_limit} left
            </span>{" "}
            free bag-photo extractions remaining
          </p>
        </section>
      )}

      <section className="brut-card p-5">
        <h2 className="poster mb-4 text-[15px] tracking-wide">Equipment</h2>
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
                className="px-2 text-ink-soft hover:text-blush-deep"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" aria-hidden>
                  <line x1="5" y1="5" x2="19" y2="19" />
                  <line x1="19" y1="5" x2="5" y2="19" />
                </svg>
              </button>
            </div>
          ))}
        </div>
        <div className="mt-4 flex items-center gap-3">
          <button
            onClick={() => setEquipment((rows) => [...rows, { ...EMPTY_ROW }])}
            className="brut-btn brut-btn-ghost px-4 py-2"
          >
            Add equipment
          </button>
          <button onClick={save} disabled={saving} className="brut-btn px-6 py-2">
            {saving ? "Saving…" : "Save"}
          </button>
          {saved && <span className="brut-label text-ink">Saved</span>}
        </div>
      </section>
    </main>
  );
}
