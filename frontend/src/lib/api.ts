import { getAuthToken } from "./auth-token";
import type { ApiResponse } from "./types";

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8000";

async function request<T>(path: string, options?: RequestInit): Promise<ApiResponse<T>> {
  const token = await getAuthToken();
  // FormData bodies must set their own multipart boundary — no explicit Content-Type.
  const isForm = options?.body instanceof FormData;
  try {
    const res = await fetch(`${API_BASE}${path}`, {
      ...options,
      headers: {
        ...(isForm ? {} : { "Content-Type": "application/json" }),
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
        ...options?.headers,
      },
    });
    return (await res.json()) as ApiResponse<T>;
  } catch {
    return { data: null, error: "Could not reach the Cobrewer API", meta: null };
  }
}

export const api = {
  get: <T>(path: string, headers?: HeadersInit) => request<T>(path, { method: "GET", headers }),

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

  postForm: <T>(path: string, form: FormData, headers?: HeadersInit) =>
    request<T>(path, { method: "POST", body: form, headers }),
};
