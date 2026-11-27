import type { ApiErrorShape } from '../types/erp';

const baseUrl = (import.meta.env.VITE_ERP_API_BASE_URL ?? 'http://localhost:8000/api/erp/v1').replace(/\/$/, '');

export class ApiError extends Error implements ApiErrorShape {
  constructor(message: string, public status?: number, public requestId?: string) {
    super(message);
    this.name = 'ApiError';
  }
}

export interface ApiClient {
  request<T>(path: string, init?: RequestInit): Promise<T>;
}

export const apiClient: ApiClient = {
  async request<T>(path: string, init: RequestInit = {}): Promise<T> {
    const response = await fetch(`${baseUrl}/${path.replace(/^\//, '')}`, {
      ...init,
      credentials: 'include',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        ...(init.headers ?? {}),
      },
    });

    const requestId = response.headers.get('x-request-id') ?? undefined;
    if (!response.ok) {
      const body = await response.json().catch(() => null) as { message?: string } | null;
      throw new ApiError(body?.message ?? 'The ERP service could not complete this request.', response.status, requestId);
    }

    return response.json() as Promise<T>;
  },
};
