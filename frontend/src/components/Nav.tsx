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
      <nav className="mx-auto flex max-w-5xl items-center gap-6 px-6 py-4">
        <Link href="/" className="font-display text-xl tracking-wide">
          <span className="text-blush">Co</span>brewer
        </Link>
        <div className="flex flex-1 items-center gap-1 text-sm">
          {LINKS.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`rounded-md px-3 py-1.5 transition-colors ${
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
          <span className="rounded-md border border-cream/40 px-2.5 py-1 text-xs uppercase tracking-wide text-cream/80">
            dev mode
          </span>
        )}
      </nav>
    </header>
  );
}
