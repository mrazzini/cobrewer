// Module-level bridge so lib/api.ts can attach the Clerk session token without
// every caller threading hooks through. AuthBridge registers the getter when
// Clerk is configured; otherwise requests go out bare and the backend's dev
// mode (DEBUG=true, no Clerk key) resolves a local dev identity.

type TokenGetter = () => Promise<string | null>;

let tokenGetter: TokenGetter | null = null;

export function registerTokenGetter(getter: TokenGetter | null): void {
  tokenGetter = getter;
}

export async function getAuthToken(): Promise<string | null> {
  return tokenGetter ? tokenGetter() : null;
}
