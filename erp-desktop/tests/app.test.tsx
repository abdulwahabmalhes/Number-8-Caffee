import { render, screen } from '@testing-library/react';
import { createMemoryRouter, RouterProvider } from 'react-router-dom';
import { AuthProvider } from '../src/app/auth';
import { I18nProvider } from '../src/i18n/I18nProvider';
import { ErpShell } from '../src/layouts/ErpShell';
import { DashboardPage } from '../src/modules/dashboard/DashboardPage';

test('renders the permission-aware desktop shell with an explicit demo label', () => {
  const router = createMemoryRouter([{ path: '/', element: <ErpShell />, children: [{ index: true, element: <DashboardPage /> }] }]);
  render(<AuthProvider><I18nProvider><RouterProvider router={router} /></I18nProvider></AuthProvider>);
  expect(screen.getByText('NUMBER EIGHT')).toBeInTheDocument();
  expect(screen.getByText('DEMO DATA')).toBeInTheDocument();
  expect(screen.queryByText('Team')).not.toBeInTheDocument();
  expect(screen.getByRole('link', { name: /Point of Sale/i })).toBeInTheDocument();
});
