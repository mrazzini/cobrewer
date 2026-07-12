import Link from "next/link";

const FEATURES = [
  {
    title: "Dial in any bean",
    body: "Origin, process and roast level turn into concrete grind clicks, dose, ratio and temperature — tuned to your grinder.",
    href: "/dial-in",
    cta: "Dial one in",
  },
  {
    title: "Log every brew",
    body: "Rate your cups and keep notes. Your journal becomes the dataset that sharpens tomorrow's recommendations.",
    href: "/journal",
    cta: "Open the journal",
  },
  {
    title: "Snap the bag",
    body: "Photograph a coffee bag and let AI extract the roaster, origin, variety and tasting notes for you.",
    href: "/add-bean",
    cta: "Add a bean",
  },
];

export default function Home() {
  return (
    <main className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-5xl flex-col px-6">
      <section className="flex flex-col items-center gap-6 py-24 text-center">
        <span className="brut-chip border-[3px] bg-olive px-4 py-1.5 shadow-[3px_3px_0_var(--color-ink)]">
          Zero bad cups
        </span>
        <h1 className="poster poster-shadow text-6xl sm:text-8xl">
          <span className="text-blush">Co</span>brewer
        </h1>
        <p className="max-w-xl text-lg font-medium text-cream-dim">
          Your coffee brewing co-pilot. Dial in your parameters, log your brews, and let the data
          guide your next cup.
        </p>
        <div className="flex gap-4">
          <Link href="/explore" className="brut-btn px-7 py-3 text-base">
            Explore beans
          </Link>
          <Link href="/dial-in" className="brut-btn brut-btn-ghost px-7 py-3 text-base">
            Dial in a brew
          </Link>
        </div>
      </section>

      <section className="grid gap-6 pb-24 sm:grid-cols-3">
        {FEATURES.map(({ title, body, href, cta }) => (
          <div key={title} className="brut-card flex flex-col p-6">
            <h2 className="poster mb-2 text-lg">{title}</h2>
            <p className="text-sm font-medium leading-relaxed text-ink-soft">{body}</p>
            <Link href={href} className="brut-btn mt-4 block text-[13px]">
              {cta}
            </Link>
          </div>
        ))}
      </section>
    </main>
  );
}
