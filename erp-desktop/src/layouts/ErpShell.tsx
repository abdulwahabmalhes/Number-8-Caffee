import { BarChart3, Boxes, ChefHat, CircleDollarSign, Coffee, LayoutDashboard, MonitorDot, Search, Settings, Truck, UserCheck, Users } from 'lucide-react';
import { NavLink, Outlet } from 'react-router-dom';
import { useAuth } from '../app/auth';
import { useI18n } from '../i18n/I18nProvider';
import type { Permission } from '../types/erp';

interface NavItem {
  to: string;
  key: 'dashboard' | 'pos' | 'kitchen' | 'products' | 'suppliers' | 'customers' | 'inventory' | 'accounting' | 'employees' | 'reports';
  icon: typeof LayoutDashboard;
  permission: Permission;
}

const items: NavItem[] = [
  { to: '/', key: 'dashboard', icon: LayoutDashboard, permission: 'dashboard.view' },
  { to: '/pos', key: 'pos', icon: MonitorDot, permission: 'pos.use' },
  { to: '/kitchen', key: 'kitchen', icon: ChefHat, permission: 'kitchen.view' },
  { to: '/products', key: 'products', icon: Coffee, permission: 'products.manage' },
  { to: '/suppliers', key: 'suppliers', icon: Truck, permission: 'suppliers.manage' },
  { to: '/customers', key: 'customers', icon: UserCheck, permission: 'customers.manage' },
  { to: '/inventory', key: 'inventory', icon: Boxes, permission: 'inventory.view' },
  { to: '/accounting', key: 'accounting', icon: CircleDollarSign, permission: 'accounting.view' },
  { to: '/employees', key: 'employees', icon: Users, permission: 'employees.manage' },
  { to: '/reports', key: 'reports', icon: BarChart3, permission: 'reports.view' },
];

export function ErpShell() {
  const user = useAuth();
  const { locale, setLocale, t } = useI18n();
  return (
    <div className="erp-shell">
      <aside className="sidebar">
        <div className="brand">
          <img src="/assets/number-eight-logo.png" alt="NUMBER EIGHT" />
          <div>
            <strong>NUMBER EIGHT</strong>
            <span>{locale === 'ar' ? 'نظام إدارة المطاعم' : 'Restaurant ERP'}</span>
          </div>
        </div>
        <nav aria-label="Primary navigation">
          {items.filter((item) => user.permissions.includes(item.permission)).map(({ to, key, icon: Icon }) => (
            <NavLink key={to} to={to} end={to === '/'}>
              <Icon size={19} aria-hidden="true" />
              <span>{t(key)}</span>
            </NavLink>
          ))}
        </nav>
        <div className="sidebar__footer">
          <Settings size={18} />
          <div>
            <strong>{user.name}</strong>
            <span>{user.role}</span>
          </div>
        </div>
      </aside>
      <main className="main-area">
        <header className="topbar">
          <div className="search">
            <Search size={18} aria-hidden="true" />
            <input aria-label="Global search" placeholder={locale === 'ar' ? 'البحث عن طلبات، منتجات، موردين...' : 'Search orders, products, suppliers…'} />
            <kbd>⌘ K</kbd>
          </div>
          <div className="topbar__actions">
            <span className="demo-badge">{t('demo')}</span>
            <button className="branch-switcher">{t('branch')}</button>
            <button className="locale-switch" onClick={() => setLocale(locale === 'en' ? 'ar' : 'en')}>
              {locale === 'en' ? 'العربية' : 'English'}
            </button>
          </div>
        </header>
        <div className="page"><Outlet /></div>
      </main>
    </div>
  );
}
