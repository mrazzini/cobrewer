import Link from "next/link";

const FEATURES = [
  {
    title: "Dial in any bean",
    body: "Origin, process and roast level turn into concrete grind clicks, dose, ratio and temperature — tuned to your grinder.",
    href: "/dial-in",
    cta: "Dial one in →",
  },
  {
    title: "Log every brew",
    body: "Rate your cups and keep notes. Your journal becomes the dataset that sharpens tomorrow's recommendations.",
    href: "/journal",
    cta: "Open the journal →",
  },
  {
    title: "Snap the bag",
    body: "Photograph a coffee bag and let AI extract the roaster, origin, variety and tasting notes for you.",
    href: "/add-bean",
    cta: "Add a bean →",
  },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-5xl flex-col px-6">
      <section className="flex flex-col items-center gap-6 py-24 text-center">
        <span className="rounded-full bg-blush px-4 py-1 text-xs font-semibold uppercase tracking-widest text-ink">
          Anywhere, really
        </span>
        <h1 className="font-display text-5xl tracking-tight sm:text-7xl">
          <span className="text-blush">Co</span>brewer
        </h1>
        <p className="max-w-xl text-lg text-cream-dim">
          Your coffee brewing co-pilot. Dial in your parameters, log your brews, and let the data
          guide your next cup.
        </p>
        <div className="flex gap-3">
          <Link
            href="/explore"
            className="rounded-lg bg-blush px-6 py-3 font-medium text-ink transition-colors hover:bg-blush-deep"
          >
            Explore beans
          </Link>
          <Link
            href="/dial-in"
            className="rounded-lg border border-cream/40 px-6 py-3 font-medium text-cream transition-colors hover:border-cream hover:bg-cream/10"
          >
            Dial in a brew
          </Link>
        </div>
      </section>

      <section className="grid gap-4 pb-24 sm:grid-cols-3">
        {FEATURES.map(({ title, body, href, cta }) => (
          <div
            key={title}
            className="flex flex-col rounded-xl bg-peri-deep/70 p-6"
          >
            <h2 className="mb-2 font-semibold uppercase tracking-wide text-blush">{title}</h2>
            <p className="text-sm leading-relaxed text-cream-dim">{body}</p>
            <Link
              href={href}
              className="mt-3 text-sm font-semibold text-blush hover:underline"
            >
              {cta}
            </Link>
          </div>
        ))}
      </section>
    </main>
  );
}
