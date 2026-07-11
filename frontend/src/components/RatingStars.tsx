"use client";

export default function RatingStars({
  value,
  onChange,
}: {
  value: number | null;
  onChange?: (rating: number) => void;
}) {
  return (
    <div className="flex gap-0.5">
      {[1, 2, 3, 4, 5].map((star) =>
        onChange ? (
          <button
            key={star}
            type="button"
            onClick={() => onChange(star)}
            aria-label={`Rate ${star} of 5`}
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
