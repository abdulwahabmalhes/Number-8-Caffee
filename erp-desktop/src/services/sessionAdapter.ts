import { apiClient } from './apiClient';
import type { AuthenticatedUser, Permission } from '../types/erp';

export interface SessionResponse {
  user: {
    id: number | string;
    name: string;
    email: string;
  };
  tenant: {
    id: number | string;
    slug: string;
    name: string;
  };
  role: string;
  is_tenant_admin: boolean;
  assigned_branches: Array<{
    id: number;
    name: string;
    code: string;
    is_default: boolean;
  }>;
  active_branch: {
    id: number;
    name: string;
    code: string;
  } | null;
  permissions: Permission[];
}

export const DEMO_USER: AuthenticatedUser = {
  id: 'demo-manager',
  name: 'Mariam Al Mansoori',
  role: 'Branch Manager (Demo)',
  branchIds: ['dubai-flagship'],
  permissions: [
    'dashboard.view',
    'pos.use',
    'kitchen.view',
    'products.manage',
    'suppliers.manage',
    'customers.manage',
    'inventory.view',
    'accounting.view',
    'reports.view',
  ],
  isDemo: true,
  tenantSlug: 'demo-number-eight',
  tenantName: 'NUMBER EIGHT (Demo Environment)',
};

export interface SessionAdapter {
  fetchSession(): Promise<AuthenticatedUser>;
  isDemoMode(): boolean;
}

export const sessionAdapter: SessionAdapter = {
  isDemoMode(): boolean {
    const isExplicitDemo = import.meta.env.VITE_ERP_DEMO_MODE === 'true';
    const hasNoApiBase = !import.meta.env.VITE_ERP_API_BASE_URL;
    return isExplicitDemo || hasNoApiBase;
  },

  async fetchSession(): Promise<AuthenticatedUser> {
    if (this.isDemoMode()) {
      return DEMO_USER;
    }

    try {
      const data = await apiClient.request<SessionResponse>('session');
      return {
        id: String(data.user.id),
        name: data.user.name,
        role: data.role,
        branchIds: data.assigned_branches.map((b) => String(b.id)),
        permissions: data.permissions,
        isDemo: false,
        tenantSlug: data.tenant.slug,
        tenantName: data.tenant.name,
      };
    } catch (err) {
      console.warn('Could not reach ERP API, falling back to isolated demo mode:', err);
      return DEMO_USER;
    }
  },
};
