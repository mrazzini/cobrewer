"use client";

import { useEffect, useState } from "react";

import { api } from "@/lib/api";
import type { Equipment, UserProfile } from "@/lib/types";

const inputClass =
  "rounded-md border border-neutral-800 bg-neutral-900 px-3 py-2 text-sm text-neutral-200 focus:border-green-400/60 focus:outline-none";

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
      <h1 className="mb-1 text-3xl font-bold">Profile &amp; Equipment</h1>
      <p className="mb-8 text-neutral-400">
        Your gear feeds the recommendation engine — grind settings come back converted to your
        grinder.
      </p>

      {error && (
        <p className="mb-6 rounded-md border border-amber-500/40 bg-amber-500/5 p-4 text-amber-500">
          {error}
        </p>
      )}

      {profile && (
        <section className="mb-6 rounded-xl border border-neutral-800 bg-neutral-900/60 p-5">
          <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-neutral-500">
            AI extraction credits
          </h2>
          <p className="text-sm text-neutral-300">
            <span className="font-semibold text-amber-500">
              {profile.ai_credits.extractions_limit - profile.ai_credits.extractions_used}
            </span>{" "}
            of {profile.ai_credits.extractions_limit} free bag-photo extractions remaining
          </p>
        </section>
      )}

      <section className="rounded-xl border border-neutral-800 bg-neutral-900/60 p-5">
        <h2 className="mb-4 text-sm font-semibold uppercase tracking-wide text-neutral-500">
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
                className="px-2 text-neutral-600 hover:text-amber-500"
              >
                ✕
              </button>
            </div>
          ))}
        </div>
        <div className="mt-4 flex items-center gap-3">
          <button
            onClick={() => setEquipment((rows) => [...rows, { ...EMPTY_ROW }])}
            className="rounded-md border border-neutral-700 px-4 py-2 text-sm text-neutral-300 transition-colors hover:border-green-400/50 hover:text-green-400"
          >
            + Add equipment
          </button>
          <button
            onClick={save}
            disabled={saving}
            className="rounded-md bg-green-500 px-5 py-2 text-sm font-medium text-neutral-950 transition-colors hover:bg-green-400 disabled:opacity-40"
          >
            {saving ? "Saving…" : "Save"}
          </button>
          {saved && <span className="text-sm text-green-400">Saved ✓</span>}
        </div>
      </section>
    </main>
  );
}
