"use client";

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
            className={`text-xl transition-colors ${
              value != null && star <= value ? "text-blush" : "text-ink/40"
            } hover:text-blush-deep`}
          >
            ★
          </button>
        ) : (
          <span
            key={star}
            className={`text-sm ${
              value != null && star <= value ? "text-blush" : "text-ink/40"
            }`}
          >
            ★
          </span>
        ),
      )}
    </div>
  );
}
