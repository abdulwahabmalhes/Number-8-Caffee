import { createBrowserRouter } from 'react-router-dom';
import { ErpShell } from '../layouts/ErpShell';
import { DashboardPage } from '../modules/dashboard/DashboardPage';
import { InventoryPage } from '../modules/inventory/InventoryPage';
import { PosPage } from '../modules/pos/PosPage';
import { ModulePlaceholder } from '../modules/shared/ModulePlaceholder';
import { LoginPage } from '../modules/auth/LoginPage';

export const router = createBrowserRouter([{ path: '/login', element: <LoginPage /> }, { path: '/', element: <ErpShell />, children: [
  { index: true, element: <DashboardPage /> },
  { path: 'pos', element: <PosPage /> },
  { path: 'inventory', element: <InventoryPage /> },
  { path: 'kitchen', element: <ModulePlaceholder title="Kitchen Display" description="Station routing, timers, priority and item availability are specified for the next implementation phase." /> },
  { path: 'accounting', element: <ModulePlaceholder title="Accounting" description="Balanced journals, period controls and source-document traceability are defined in the architecture." /> },
  { path: 'employees', element: <ModulePlaceholder title="Employees & permissions" description="Tenant and branch-aware role contracts are ready; production identity integration remains deliberately unconnected." /> },
  { path: 'reports', element: <ModulePlaceholder title="Management reports" description="KPI definitions and financial reconciliation rules are documented before live analytics are connected." /> },
]}]);
