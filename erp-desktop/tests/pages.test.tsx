import { render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router-dom';
import { AuthProvider } from '../src/app/auth';
import { I18nProvider } from '../src/i18n/I18nProvider';
import { ErpShell } from '../src/layouts/ErpShell';
import { KitchenPage } from '../src/modules/kitchen/KitchenPage';
import { AccountingPage } from '../src/modules/accounting/AccountingPage';
import { EmployeesPage } from '../src/modules/employees/EmployeesPage';
import { ReportsPage } from '../src/modules/reports/ReportsPage';
import { ProductsPage } from '../src/modules/products/ProductsPage';
import { SuppliersPage } from '../src/modules/suppliers/SuppliersPage';
import { CustomersPage } from '../src/modules/customers/CustomersPage';
import { it, expect } from 'vitest';

it('renders Kitchen Display page with active tickets', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <KitchenPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Kitchen Display System/i)).toBeInTheDocument();
  expect(screen.getByText('#K-101')).toBeInTheDocument();
});

it('renders Products & Recipes page', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <ProductsPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Products & Recipe Management/i)).toBeInTheDocument();
  expect(screen.getByText('LATTE-STD')).toBeInTheDocument();
});

it('renders Suppliers & Purchasing page', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <SuppliersPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Suppliers & Purchasing Orders/i)).toBeInTheDocument();
  expect(screen.getAllByText('Al Ameed Coffee Trading').length).toBeGreaterThan(0);
});

it('renders Customers & Loyalty page', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <CustomersPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Customers Directory/i)).toBeInTheDocument();
  expect(screen.getByText('Sultan Al Qasimi')).toBeInTheDocument();
});

it('renders Accounting page with balanced journals', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <AccountingPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/General Ledger & Accounting/i)).toBeInTheDocument();
  expect(screen.getByText('JRN-2026-0891')).toBeInTheDocument();
});

it('renders Employees page with RBAC access list', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <EmployeesPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Team & Branch Permissions/i)).toBeInTheDocument();
  expect(screen.getByText('Zaid Al Hashimi')).toBeInTheDocument();
});

it('renders Reports page with sales reconciliation', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <ReportsPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText(/Executive Reports/i)).toBeInTheDocument();
  expect(screen.getByText('Spanish Iced Latte')).toBeInTheDocument();
});
