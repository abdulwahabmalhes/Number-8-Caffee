import { createBrowserRouter } from 'react-router-dom';
import { ErpShell } from '../layouts/ErpShell';
import { DashboardPage } from '../modules/dashboard/DashboardPage';
import { InventoryPage } from '../modules/inventory/InventoryPage';
import { PosPage } from '../modules/pos/PosPage';
import { KitchenPage } from '../modules/kitchen/KitchenPage';
import { ProductsPage } from '../modules/products/ProductsPage';
import { SuppliersPage } from '../modules/suppliers/SuppliersPage';
import { CustomersPage } from '../modules/customers/CustomersPage';
import { AccountingPage } from '../modules/accounting/AccountingPage';
import { EmployeesPage } from '../modules/employees/EmployeesPage';
import { ReportsPage } from '../modules/reports/ReportsPage';
import { LoginPage } from '../modules/auth/LoginPage';

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  {
    path: '/',
    element: <ErpShell />,
    children: [
      { index: true, element: <DashboardPage /> },
      { path: 'pos', element: <PosPage /> },
      { path: 'kitchen', element: <KitchenPage /> },
      { path: 'products', element: <ProductsPage /> },
      { path: 'suppliers', element: <SuppliersPage /> },
      { path: 'customers', element: <CustomersPage /> },
      { path: 'inventory', element: <InventoryPage /> },
      { path: 'accounting', element: <AccountingPage /> },
      { path: 'employees', element: <EmployeesPage /> },
      { path: 'reports', element: <ReportsPage /> },
    ],
  },
]);
