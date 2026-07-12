import type { Metadata } from "next";
import { ClerkProvider } from "@clerk/nextjs";
import localFont from "next/font/local";
import "./globals.css";

const rubik = localFont({
  src: [
    { path: "../fonts/Rubik-Regular.ttf", weight: "400" },
    { path: "../fonts/Rubik-Medium.ttf", weight: "500" },
    { path: "../fonts/Rubik-SemiBold.ttf", weight: "600" },
    { path: "../fonts/Rubik-Bold.ttf", weight: "700" },
    { path: "../fonts/Rubik-ExtraBold.ttf", weight: "800" },
  ],
  variable: "--font-rubik",
});

const anton = localFont({
  src: "../fonts/Anton-Regular.ttf",
  variable: "--font-anton",
});

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
    <html lang="en" className={`${rubik.variable} ${anton.variable}`}>
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
