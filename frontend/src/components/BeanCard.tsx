import Link from "next/link";

import { roastLabel } from "@/lib/constants";
import type { Bean } from "@/lib/types";

export default function BeanCard({ bean }: { bean: Bean }) {
  return (
    <div className="flex flex-col gap-3 rounded-xl border border-neutral-800 bg-neutral-900/60 p-5 transition-colors hover:border-green-400/40">
      <div className="flex items-start justify-between gap-2">
        <div>
          <h3 className="font-semibold leading-tight">{bean.name}</h3>
          <p className="text-sm text-neutral-400">{bean.roaster ?? "Unknown roaster"}</p>
        </div>
        {bean.cupping_score != null && (
          <span className="shrink-0 rounded-md bg-amber-500/10 px-2 py-0.5 text-sm font-medium text-amber-500">
            {bean.cupping_score.toFixed(2)}
          </span>
        )}
      </div>
      <div className="flex flex-wrap gap-1.5 text-xs">
        {bean.origin && (
          <span className="rounded-full bg-neutral-800 px-2.5 py-1 text-neutral-300">
            {bean.origin}
          </span>
        )}
        {bean.process && (
          <span className="rounded-full bg-neutral-800 px-2.5 py-1 capitalize text-neutral-300">
            {bean.process.replace("_", " ")}
          </span>
        )}
        {bean.roast_level && (
          <span className="rounded-full bg-neutral-800 px-2.5 py-1 text-neutral-300">
            {roastLabel(bean.roast_level)}
          </span>
        )}
      </div>
      {bean.tasting_notes && bean.tasting_notes.length > 0 && (
        <p className="text-sm italic text-green-400/80">{bean.tasting_notes.join(" · ")}</p>
      )}
      <Link
        href={`/dial-in?bean=${bean.id}`}
        className="mt-auto inline-block rounded-md bg-green-500/10 px-3 py-1.5 text-center text-sm font-medium text-green-400 transition-colors hover:bg-green-500/20"
      >
        Dial this in →
      </Link>
    </div>
  );
}
