import Link from "next/link";

const FEATURES = [
  {
    title: "Dial in any bean",
    body: "Origin, process and roast level turn into concrete grind clicks, dose, ratio and temperature — tuned to your grinder.",
  },
  {
    title: "Log every brew",
    body: "Rate your cups and keep notes. Your journal becomes the dataset that sharpens tomorrow's recommendations.",
  },
  {
    title: "Snap the bag",
    body: "Photograph a coffee bag and let AI extract the roaster, origin, variety and tasting notes for you.",
  },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-5xl flex-col px-6">
      <section className="flex flex-col items-center gap-6 py-24 text-center">
        <span className="rounded-full border border-green-400/30 bg-green-400/5 px-4 py-1 text-xs uppercase tracking-widest text-green-400">
          Strike with precision
        </span>
        <h1 className="text-6xl font-bold tracking-tight">
          <span className="text-green-400">Co</span>brewer
        </h1>
        <p className="max-w-xl text-lg text-neutral-400">
          Your coffee brewing co-pilot. Dial in your parameters, log your brews, and let the data
          guide your next cup.
        </p>
        <div className="flex gap-3">
          <Link
            href="/explore"
            className="rounded-lg bg-green-500 px-6 py-3 font-medium text-neutral-950 transition-colors hover:bg-green-400"
          >
            Explore beans
          </Link>
          <Link
            href="/dial-in"
            className="rounded-lg border border-neutral-700 px-6 py-3 font-medium text-neutral-200 transition-colors hover:border-green-400/50 hover:text-green-400"
          >
            Dial in a brew
          </Link>
        </div>
      </section>

      <section className="grid gap-4 pb-24 sm:grid-cols-3">
        {FEATURES.map(({ title, body }) => (
          <div
            key={title}
            className="rounded-xl border border-neutral-800 bg-neutral-900/60 p-6"
          >
            <h2 className="mb-2 font-semibold text-green-400">{title}</h2>
            <p className="text-sm leading-relaxed text-neutral-400">{body}</p>
          </div>
        ))}
      </section>
    </main>
  );
}
