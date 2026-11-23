export type Permission =
  | 'dashboard.view'
  | 'pos.use'
  | 'kitchen.view'
  | 'inventory.view'
  | 'accounting.view'
  | 'employees.manage'
  | 'reports.view';

export interface AuthenticatedUser {
  id: string;
  name: string;
  role: string;
  branchIds: string[];
  permissions: Permission[];
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
