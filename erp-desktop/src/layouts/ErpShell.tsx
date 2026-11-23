import { BarChart3, Boxes, ChefHat, CircleDollarSign, LayoutDashboard, MonitorDot, Search, Settings, Users } from 'lucide-react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../app/auth';
import { useI18n } from '../i18n/I18nProvider';
import type { Permission } from '../types/erp';

const items: Array<{ to: string; label: string; icon: typeof LayoutDashboard; permission: Permission }> = [
  { to: '/', label: 'Overview', icon: LayoutDashboard, permission: 'dashboard.view' },
  { to: '/pos', label: 'Point of Sale', icon: MonitorDot, permission: 'pos.use' },
  { to: '/kitchen', label: 'Kitchen Display', icon: ChefHat, permission: 'kitchen.view' },
  { to: '/inventory', label: 'Inventory', icon: Boxes, permission: 'inventory.view' },
  { to: '/accounting', label: 'Accounting', icon: CircleDollarSign, permission: 'accounting.view' },
  { to: '/employees', label: 'Team', icon: Users, permission: 'employees.manage' },
  { to: '/reports', label: 'Reports', icon: BarChart3, permission: 'reports.view' },
];

export function ErpShell() {
  const user = useAuth();
  const { locale, setLocale, t } = useI18n();
  return (
    <div className="erp-shell">
      <aside className="sidebar">
        <div className="brand"><img src="/assets/number-eight-logo.png" alt="NUMBER EIGHT" /><div><strong>NUMBER EIGHT</strong><span>Restaurant ERP</span></div></div>
        <nav aria-label="Primary navigation">
          {items.filter((item) => user.permissions.includes(item.permission)).map(({ to, label, icon: Icon }) => (
            <NavLink key={to} to={to} end={to === '/'}><Icon size={19} aria-hidden="true" /><span>{label}</span></NavLink>
          ))}
        </nav>
        <div className="sidebar__footer"><Settings size={18} /><div><strong>{user.name}</strong><span>{user.role}</span></div></div>
      </aside>
      <main className="main-area">
        <header className="topbar">
          <div className="search"><Search size={18} aria-hidden="true" /><input aria-label="Global search" placeholder="Search orders, products, suppliers…" /><kbd>⌘ K</kbd></div>
          <div className="topbar__actions"><span className="demo-badge">{t('demo')}</span><button className="branch-switcher">{t('branch')}</button><button className="locale-switch" onClick={() => setLocale(locale === 'en' ? 'ar' : 'en')}>{locale === 'en' ? 'العربية' : 'English'}</button></div>
        </header>
        <div className="page"><Outlet /></div>
      </main>
    </div>
  );
}
