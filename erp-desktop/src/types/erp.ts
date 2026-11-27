export type Permission =
  | 'dashboard.view'
  | 'pos.use'
  | 'kitchen.view'
  | 'inventory.view'
  | 'products.manage'
  | 'purchasing.manage'
  | 'suppliers.manage'
  | 'customers.manage'
  | 'accounting.view'
  | 'employees.manage'
  | 'reports.view';

export interface AuthenticatedUser {
  id: string;
  name: string;
  role: string;
  branchIds: string[];
  permissions: Permission[];
  isDemo?: boolean;
  tenantSlug?: string;
  tenantName?: string;
}

export interface Product {
  id: string;
  sku: string;
  name: { en: string; ar: string };
  category: string;
  priceMinor: number;
  available: boolean;
}

export interface InventoryItem {
  id: string;
  name: string;
  quantity: number;
  unit: string;
  reorderAt: number;
  valueMinor: number;
}

export interface ApiErrorShape {
  message: string;
  status?: number;
  requestId?: string;
}
