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
    <header className="sticky top-0 z-50 border-b border-peri-well/50 bg-peri/90 backdrop-blur">
      <nav className="mx-auto flex max-w-5xl items-center gap-2 px-3 py-3 sm:gap-6 sm:px-6 sm:py-4">
        <Link href="/" className="font-display text-lg tracking-wide sm:text-xl">
          <span className="text-blush">Co</span>brewer
        </Link>
        <div className="flex flex-1 items-center gap-0.5 text-[13px] sm:gap-1 sm:text-sm">
          {LINKS.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`whitespace-nowrap rounded-md px-2 py-1.5 transition-colors sm:px-3 ${
                pathname.startsWith(href)
                  ? "bg-blush font-semibold text-ink"
                  : "text-cream-dim hover:text-cream"
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
                <button className="rounded-md bg-blush px-4 py-1.5 text-sm font-medium text-ink transition-colors hover:bg-blush-deep">
                  Sign in
                </button>
              </SignInButton>
            </SignedOut>
            <SignedIn>
              <UserButton />
            </SignedIn>
          </>
        ) : (
          <span className="hidden rounded-md border border-cream/40 px-2.5 py-1 text-xs uppercase tracking-wide text-cream/80 sm:inline-block">
            dev mode
          </span>
        )}
      </nav>
    </header>
  );
}
