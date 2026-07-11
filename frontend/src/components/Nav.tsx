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
    <header className="sticky top-0 z-50 border-b border-neutral-800 bg-neutral-950/90 backdrop-blur">
      <nav className="mx-auto flex max-w-5xl items-center gap-6 px-6 py-4">
        <Link href="/" className="text-lg font-bold tracking-tight">
          <span className="text-green-400">Co</span>brewer
        </Link>
        <div className="flex flex-1 items-center gap-1 text-sm">
          {LINKS.map(({ href, label }) => (
            <Link
              key={href}
              href={href}
              className={`rounded-md px-3 py-1.5 transition-colors ${
                pathname.startsWith(href)
                  ? "bg-green-400/10 text-green-400"
                  : "text-neutral-400 hover:text-white"
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
                <button className="rounded-md bg-green-500 px-4 py-1.5 text-sm font-medium text-neutral-950 transition-colors hover:bg-green-400">
                  Sign in
                </button>
              </SignInButton>
            </SignedOut>
            <SignedIn>
              <UserButton />
            </SignedIn>
          </>
        ) : (
          <span className="rounded-md border border-amber-500/40 px-2.5 py-1 text-xs text-amber-500">
            dev mode
          </span>
        )}
      </nav>
    </header>
  );
}
