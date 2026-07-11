"use client";

import { useAuth } from "@clerk/nextjs";
import { useEffect } from "react";

import { registerTokenGetter } from "@/lib/auth-token";

// Rendered inside ClerkProvider only; hands the session token getter to lib/api.
export default function AuthBridge() {
  const { getToken } = useAuth();

  useEffect(() => {
    registerTokenGetter(() => getToken());
    return () => registerTokenGetter(null);
  }, [getToken]);

  return null;
}
