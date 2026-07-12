/**
 * Loading placeholders shaped like the real cards so content doesn't
 * pop in and shift the layout.
 */

function Bar({ className }: { className: string }) {
  return <div className={`animate-pulse rounded-md bg-ink/15 ${className}`} />;
}

export function BeanCardSkeleton() {
  return (
    <div aria-hidden className="brut-card flex flex-col gap-3 p-5">
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1 space-y-2">
          <Bar className="h-4 w-3/4" />
          <Bar className="h-3 w-1/2" />
        </div>
        <Bar className="h-6 w-12" />
      </div>
      <div className="flex gap-1.5">
        <Bar className="h-6 w-16 rounded-full" />
        <Bar className="h-6 w-20 rounded-full" />
        <Bar className="h-6 w-14 rounded-full" />
      </div>
      <Bar className="h-3 w-2/3" />
      <Bar className="mt-auto h-9 w-full rounded-xl" />
    </div>
  );
}

export function BrewCardSkeleton() {
  return (
    <div aria-hidden className="brut-card p-5">
      <div className="mb-3 flex items-start justify-between gap-2">
        <div className="flex-1 space-y-2">
          <Bar className="h-4 w-1/2" />
          <Bar className="h-3 w-1/3" />
        </div>
        <Bar className="h-4 w-20" />
      </div>
      <div className="flex gap-4">
        <Bar className="h-3 w-16" />
        <Bar className="h-3 w-12" />
        <Bar className="h-3 w-14" />
        <Bar className="h-3 w-12" />
      </div>
    </div>
  );
}
