import Link from "next/link";

import { roastLabel } from "@/lib/constants";
import type { Bean } from "@/lib/types";

// Tag colors encode category: blush = roast level, olive = process,
// white = everything else (design/DESIGN.md).
export default function BeanCard({ bean }: { bean: Bean }) {
  return (
    <div className="brut-card flex flex-col gap-3 p-5 transition-transform duration-200 ease-out hover:-translate-y-0.5">
      <div className="flex items-start justify-between gap-2">
        <div>
          <h3 className="poster text-lg leading-tight">{bean.name}</h3>
          <p className="text-sm font-semibold text-ink-soft">
            {bean.roaster ?? "Unknown roaster"}
          </p>
        </div>
        {bean.cupping_score != null && (
          <span className="poster shrink-0 rounded-lg border-2 border-ink bg-olive px-2 py-0.5 text-sm">
            {bean.cupping_score.toFixed(2)}
          </span>
        )}
      </div>
      <div className="flex flex-wrap gap-1.5">
        {bean.roast_level && (
          <span className="brut-chip bg-blush">{roastLabel(bean.roast_level)}</span>
        )}
        {bean.process && (
          <span className="brut-chip bg-olive">{bean.process.replace("_", " ")}</span>
        )}
        {bean.origin && <span className="brut-chip">{bean.origin}</span>}
        {!bean.is_verified && (
          <span
            className="brut-chip border-dashed text-ink-soft"
            title="User-submitted — not yet verified"
          >
            community
          </span>
        )}
      </div>
      {bean.tasting_notes && bean.tasting_notes.length > 0 && (
        <p className="text-sm font-medium italic text-ink-soft">
          {bean.tasting_notes.join(" · ")}
        </p>
      )}
      <Link href={`/dial-in?bean=${bean.id}`} className="brut-btn mt-auto block text-[13px]">
        Dial this in
      </Link>
    </div>
  );
}
