import { createContext, useContext, useEffect, useState, type PropsWithChildren } from 'react';
import type { AuthenticatedUser, Permission } from '../types/erp';
import { DEMO_USER, sessionAdapter } from '../services/sessionAdapter';

interface AuthContextValue {
  user: AuthenticatedUser;
  isDemo: boolean;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: PropsWithChildren) {
  const [user, setUser] = useState<AuthenticatedUser>(DEMO_USER);
  const [isLoading, setIsLoading] = useState(!sessionAdapter.isDemoMode());

  useEffect(() => {
    if (!sessionAdapter.isDemoMode()) {
      sessionAdapter
        .fetchSession()
        .then((fetchedUser) => {
          setUser(fetchedUser);
        })
        .finally(() => {
          setIsLoading(false);
        });
    }
  }, []);

  return (
    <AuthContext.Provider value={{ user, isDemo: !!user.isDemo, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthenticatedUser {
  const context = useContext(AuthContext);
  if (!context) throw new Error('AuthProvider is required.');
  return context.user;
}

export function useAuthContext(): AuthContextValue {
  const context = useContext(AuthContext);
  if (!context) throw new Error('AuthProvider is required.');
  return context;
}

export function useCan(permission: Permission): boolean {
  return useAuth().permissions.includes(permission);
}
