"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { SignedIn, SignedOut, SignInButton, UserButton } from "@clerk/nextjs";

const LINKS = [
  { href: "/explore", label: "Explore" },
  { href: "/dial-in", label: "Dial In" },
  { href: "/journal", label: "Journal" },
  { href: "/profile", label: "Profile" },
];

export default function Nav({ clerkEnabled }: { clerkEnabled: boolean }) {
  const pathname = usePathname();

  return (
    <header className="sticky top-0 z-50 border-b-[3px] border-ink bg-cream text-ink">
      <nav className="mx-auto flex max-w-5xl items-center gap-2 px-3 py-3 sm:gap-6 sm:px-6">
        <Link href="/" className="poster text-lg sm:text-xl">
          <span className="text-blush-deep">Co</span>brewer
        </Link>
        <div className="flex flex-1 items-center gap-0.5 text-[11px] font-bold uppercase tracking-tight sm:gap-1.5 sm:text-[13px] sm:tracking-wide">
          {LINKS.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`whitespace-nowrap rounded-full px-1.5 py-1.5 transition-colors sm:px-3.5 ${
                pathname.startsWith(href)
                  ? "bg-ink text-olive"
                  : "text-ink hover:bg-ink/10"
              }`}
            >
              {label}
            </Link>
          ))}
        </div>
        {clerkEnabled ? (
          <>
            <SignedOut>
              <SignInButton mode="modal">
                <button className="brut-btn px-4 py-1.5 text-xs shadow-[3px_3px_0_var(--color-ink)]">
                  Sign in
                </button>
              </SignInButton>
            </SignedOut>
            <SignedIn>
              <UserButton />
            </SignedIn>
          </>
        ) : (
          <span className="brut-chip hidden bg-olive sm:inline-block">dev mode</span>
        )}
      </nav>
    </header>
  );
}
