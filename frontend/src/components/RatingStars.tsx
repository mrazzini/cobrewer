"use client";

// Drawn star (no text glyphs — design/DESIGN.md): blush fill + ink stroke
// when set, dim outline when unset.
function Star({ filled, size = 22 }: { filled: boolean; size?: number }) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill={filled ? "var(--color-blush)" : "none"}
      stroke={filled ? "var(--color-ink)" : "var(--color-ink-soft)"}
      strokeWidth="1.6"
      aria-hidden
    >
      <path d="M12 2.6l2.9 6 6.6.9-4.8 4.6 1.2 6.5L12 17.5l-5.9 3.1 1.2-6.5-4.8-4.6 6.6-.9z" />
    </svg>
  );
}

export default function RatingStars({
  value,
  onChange,
}: {
  value: number | null;
  onChange?: (rating: number | null) => void;
}) {
  return (
    <div className="flex gap-0.5">
      {[1, 2, 3, 4, 5].map((star) =>
        onChange ? (
          <button
            key={star}
            type="button"
            // Clicking the current rating again clears it back to unrated.
            onClick={() => onChange(star === value ? null : star)}
            aria-label={star === value ? `Clear ${star}-star rating` : `Rate ${star} of 5`}
            aria-pressed={value != null && star <= value}
            className="-my-1 px-1 py-1"
          >
            <Star filled={value != null && star <= value} />
          </button>
        ) : (
          <span key={star}>
            <Star filled={value != null && star <= value} size={16} />
          </span>
        ),
      )}
    </div>
  );
}
