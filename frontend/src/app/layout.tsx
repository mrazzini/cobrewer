import type { Metadata } from "next";
import { ClerkProvider } from "@clerk/nextjs";
import "./globals.css";

import AuthBridge from "@/components/AuthBridge";
import Nav from "@/components/Nav";

export const metadata: Metadata = {
  title: "Cobrewer — The Coffee Brewing Co-pilot",
  description: "Dial in your brew parameters with precision.",
};

const clerkEnabled = Boolean(process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY);

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const shell = (
    <html lang="en">
      <body>
        <Nav clerkEnabled={clerkEnabled} />
        {children}
      </body>
    </html>
  );

  // Without a Clerk key (local dev, CI builds) render bare: the backend's
  // DEBUG mode resolves a local dev identity, so the app stays fully usable.
  if (!clerkEnabled) {
    return shell;
  }

  return (
    <ClerkProvider>
      <AuthBridge />
      {shell}
    </ClerkProvider>
  );
}
