import Link from "next/link";

import { roastLabel } from "@/lib/constants";
import type { Bean } from "@/lib/types";

export default function BeanCard({ bean }: { bean: Bean }) {
  return (
    <div className="flex flex-col gap-3 rounded-xl bg-peri-deep/70 p-5 transition-colors hover:bg-peri-deep">
      <div className="flex items-start justify-between gap-2">
        <div>
          <h3 className="font-semibold leading-tight">{bean.name}</h3>
          <p className="text-sm text-cream-dim">{bean.roaster ?? "Unknown roaster"}</p>
        </div>
        {bean.cupping_score != null && (
          <span className="shrink-0 rounded-md bg-cream/15 px-2 py-0.5 text-sm font-semibold text-cream">
            {bean.cupping_score.toFixed(2)}
          </span>
        )}
      </div>
      <div className="flex flex-wrap gap-1.5 text-xs">
        {bean.origin && (
          <span className="rounded-full bg-peri-well px-2.5 py-1 text-cream">
            {bean.origin}
          </span>
        )}
        {bean.process && (
          <span className="rounded-full bg-peri-well px-2.5 py-1 capitalize text-cream">
            {bean.process.replace("_", " ")}
          </span>
        )}
        {bean.roast_level && (
          <span className="rounded-full bg-peri-well px-2.5 py-1 text-cream">
            {roastLabel(bean.roast_level)}
          </span>
        )}
      </div>
      {bean.tasting_notes && bean.tasting_notes.length > 0 && (
        <p className="text-sm italic text-cream/80">{bean.tasting_notes.join(" · ")}</p>
      )}
      <Link
        href={`/dial-in?bean=${bean.id}`}
        className="mt-auto inline-block rounded-md bg-blush px-3 py-1.5 text-center text-sm font-semibold text-ink transition-colors hover:bg-blush-deep"
      >
        Dial this in →
      </Link>
    </div>
  );
}
