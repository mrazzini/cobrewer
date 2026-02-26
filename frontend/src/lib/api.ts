import type { ApiResponse } from "./types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function request<T>(
  path: string,
  options?: RequestInit,
): Promise<ApiResponse<T>> {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...options?.headers,
    },
    ...options,
  });
  return res.json() as Promise<ApiResponse<T>>;
}

export const api = {
  get: <T>(path: string, headers?: HeadersInit) =>
    request<T>(path, { method: "GET", headers }),

  post: <T>(path: string, body: unknown, headers?: HeadersInit) =>
    request<T>(path, {
      method: "POST",
      body: JSON.stringify(body),
      headers,
    }),

  put: <T>(path: string, body: unknown, headers?: HeadersInit) =>
    request<T>(path, {
      method: "PUT",
      body: JSON.stringify(body),
      headers,
    }),
};
