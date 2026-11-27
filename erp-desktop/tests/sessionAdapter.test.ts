import { describe, it, expect, vi, beforeEach } from 'vitest';
import { DEMO_USER, sessionAdapter } from '../src/services/sessionAdapter';
import { apiClient } from '../src/services/apiClient';

describe('sessionAdapter', () => {
  beforeEach(() => {
    vi.restoreAllMocks();
  });

  it('provides a labeled demo identity when in demo mode', async () => {
    vi.spyOn(sessionAdapter, 'isDemoMode').mockReturnValue(true);

    const user = await sessionAdapter.fetchSession();

    expect(user.isDemo).toBe(true);
    expect(user.id).toBe(DEMO_USER.id);
    expect(user.name).toBe(DEMO_USER.name);
    expect(user.permissions).toContain('pos.use');
  });

  it('maps api response to authenticated user when live api succeeds', async () => {
    vi.spyOn(sessionAdapter, 'isDemoMode').mockReturnValue(false);
    vi.spyOn(apiClient, 'request').mockResolvedValueOnce({
      user: { id: 10, name: 'Live User', email: 'live@no8.ae' },
      tenant: { id: 1, slug: 'number-eight', name: 'NUMBER EIGHT' },
      role: 'Cashier',
      is_tenant_admin: false,
      assigned_branches: [{ id: 1, name: 'Dubai', code: 'DXB-01', is_default: true }],
      active_branch: { id: 1, name: 'Dubai', code: 'DXB-01' },
      permissions: ['pos.use'],
    });

    const user = await sessionAdapter.fetchSession();

    expect(user.isDemo).toBe(false);
    expect(user.id).toBe('10');
    expect(user.name).toBe('Live User');
    expect(user.role).toBe('Cashier');
    expect(user.branchIds).toEqual(['1']);
    expect(user.permissions).toEqual(['pos.use']);
  });

  it('falls back to demo user with warning if api call fails', async () => {
    vi.spyOn(sessionAdapter, 'isDemoMode').mockReturnValue(false);
    vi.spyOn(apiClient, 'request').mockRejectedValueOnce(new Error('Network error'));
    const warnSpy = vi.spyOn(console, 'warn').mockImplementation(() => {});

    const user = await sessionAdapter.fetchSession();

    expect(user.isDemo).toBe(true);
    expect(user.id).toBe(DEMO_USER.id);
    expect(warnSpy).toHaveBeenCalled();
  });
});
