import { createContext, useContext, type PropsWithChildren } from 'react';
import type { AuthenticatedUser, Permission } from '../types/erp';

const demoUser: AuthenticatedUser = {
  id: 'demo-manager',
  name: 'Mariam Al Mansoori',
  role: 'Branch Manager',
  branchIds: ['dubai-flagship'],
  permissions: ['dashboard.view', 'pos.use', 'kitchen.view', 'inventory.view', 'accounting.view', 'reports.view'],
};

const AuthContext = createContext<AuthenticatedUser | null>(null);

export function AuthProvider({ children }: PropsWithChildren) {
  // Development-only identity. Production auth will use an HttpOnly Sanctum session and CSRF flow.
  return <AuthContext.Provider value={demoUser}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const user = useContext(AuthContext);
  if (!user) throw new Error('AuthProvider is required.');
  return user;
}

export function useCan(permission: Permission) {
  return useAuth().permissions.includes(permission);
}
