import { useState, useEffect } from 'react';
import { Award, Mail, Phone, Plus, Search, ShoppingBag, UserCheck, Users } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';
import { StatusPill } from '../../components/StatusPill';

interface Customer {
  id: number;
  name: string;
  phone?: string;
  email?: string;
  notes?: string;
  loyalty_points: number;
  orders_count?: number;
  is_active: boolean;
  created_at?: string;
}

const mockCustomers: Customer[] = [
  {
    id: 1,
    name: 'Sultan Al Qasimi',
    phone: '+971501112233',
    email: 'sultan@example.ae',
    notes: 'Prefers oat milk when available',
    loyalty_points: 120,
    orders_count: 5,
    is_active: true,
    created_at: '2026-11-20',
  },
  {
    id: 2,
    name: 'Fatima Al Marzouqi',
    phone: '+971504445566',
    email: 'fatima@example.ae',
    notes: 'Cortado regular customer',
    loyalty_points: 85,
    orders_count: 3,
    is_active: true,
    created_at: '2026-11-22',
  },
  {
    id: 3,
    name: 'Tariq Mansoor',
    phone: '+971558889900',
    email: 'tariq@example.ae',
    notes: 'Prefers takeaway packaging',
    loyalty_points: 40,
    orders_count: 2,
    is_active: true,
    created_at: '2026-11-24',
  },
];

export function CustomersPage() {
  const { locale } = useI18n();
  const [customers, setCustomers] = useState<Customer[]>(mockCustomers);
  const [search, setSearch] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // New Customer Form
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [notes, setNotes] = useState('');

  useEffect(() => {
    if (!sessionAdapter.isDemoMode()) {
      apiClient
        .request<{ customers: Customer[] }>('customers')
        .then((res) => {
          if (res?.customers && res.customers.length > 0) {
            setCustomers(res.customers);
          }
        })
        .catch(() => {});
    }
  }, []);

  const handleCreateCustomer = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);

    const payload = {
      name: name.trim(),
      phone: phone.trim() || undefined,
      email: email.trim() || undefined,
      notes: notes.trim() || undefined,
    };

    if (sessionAdapter.isDemoMode()) {
      const created: Customer = {
        id: Date.now(),
        name: payload.name,
        phone: payload.phone,
        email: payload.email,
        notes: payload.notes,
        loyalty_points: 0,
        orders_count: 0,
        is_active: true,
        created_at: new Date().toISOString().split('T')[0],
      };
      setCustomers([created, ...customers]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تمت إضافة العميل بنجاح' : 'Customer added successfully' });
      setShowAddModal(false);
      setName('');
      setPhone('');
      setEmail('');
      setNotes('');
      return;
    }

    try {
      const res = await apiClient.request<Customer>('customers', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      setCustomers([res, ...customers]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم حفظ العميل بالخادم' : 'Customer registered' });
      setShowAddModal(false);
      setName('');
      setPhone('');
      setEmail('');
      setNotes('');
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to register customer';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const filteredCustomers = customers.filter(
    (c) =>
      c.name.toLowerCase().includes(search.toLowerCase()) ||
      c.phone?.includes(search) ||
      c.email?.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="customers-page">
      <div className="page-heading">
        <div>
          <p className="eyebrow">{locale === 'ar' ? 'إدارة علاقات العملاء والولاء' : 'Customer Relationship & Loyalty'}</p>
          <h1>{locale === 'ar' ? 'سجل العملاء والمشتريات' : 'Customers Directory & Purchase History'}</h1>
          <p>
            {locale === 'ar'
              ? 'سجل عملاء ERP المنفصل تماماً عن حسابات تطبيق الموبايل، مع دعم نقاط الولاء والبيع لضيف'
              : 'Isolated ERP customer directory separate from Flutter mobile accounts, tracking in-store loyalty and guest sales.'}
          </p>
        </div>
        <button className="primary-button" onClick={() => setShowAddModal(true)}>
          <Plus size={16} />
          {locale === 'ar' ? 'إضافة عميل جديد' : 'New Customer'}
        </button>
      </div>

      {feedback && (
        <div style={{
          padding: '12px 16px',
          borderRadius: 8,
          marginBottom: 16,
          backgroundColor: feedback.type === 'success' ? '#e4f4e9' : '#fbe8e6',
          color: feedback.type === 'success' ? '#24633c' : '#a02d28',
          fontWeight: 600,
          fontSize: 13,
        }}>
          {feedback.message}
        </div>
      )}

      {/* Metrics Row */}
      <div className="metrics-grid" style={{ marginBottom: 20 }}>
        <div className="metric-card">
          <div className="metric-card__top">
            <span>{locale === 'ar' ? 'إجمالي العملاء' : 'Total Customers'}</span>
            <Users size={18} />
          </div>
          <strong>{customers.length}</strong>
          <small>{locale === 'ar' ? 'سجلات معزولة في ERP' : 'Isolated ERP Profiles'}</small>
        </div>
        <div className="metric-card">
          <div className="metric-card__top">
            <span>{locale === 'ar' ? 'إجمالي نقاط الولاء' : 'Loyalty Points'}</span>
            <Award size={18} />
          </div>
          <strong>{customers.reduce((acc, c) => acc + (c.loyalty_points || 0), 0)} pts</strong>
          <small>{locale === 'ar' ? 'ممنوحة مع المبيعات' : 'Earned on POS Cash Sales'}</small>
        </div>
        <div className="metric-card">
          <div className="metric-card__top">
            <span>{locale === 'ar' ? 'مبيعات الضيوف' : 'Guest Checkouts'}</span>
            <ShoppingBag size={18} />
          </div>
          <strong>100%</strong>
          <small>{locale === 'ar' ? 'مدعوم بدون تسجيل' : 'Guest sales supported'}</small>
        </div>
        <div className="metric-card">
          <div className="metric-card__top">
            <span>{locale === 'ar' ? 'عزل البيانات' : 'Privacy Isolation'}</span>
            <UserCheck size={18} />
          </div>
          <strong>{locale === 'ar' ? 'مفصول' : 'Isolated'}</strong>
          <small>{locale === 'ar' ? 'مفصول عن Flutter DB' : 'Separated from Flutter DB'}</small>
        </div>
      </div>

      {/* Main Customers Table */}
      <div className="panel">
        <div className="panel__header">
          <div className="filters">
            <div className="search" style={{ width: 320 }}>
              <Search size={16} />
              <input
                aria-label="Filter customers"
                placeholder={locale === 'ar' ? 'البحث بالاسم أو الهاتف أو البريد...' : 'Search by name, phone, or email…'}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
          <span className="section-label">{filteredCustomers.length} {locale === 'ar' ? 'عميل' : 'Registered Profiles'}</span>
        </div>

        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>{locale === 'ar' ? 'الاسم' : 'Customer Name'}</th>
                <th>{locale === 'ar' ? 'بيانات الاتصال' : 'Contact Details'}</th>
                <th>{locale === 'ar' ? 'نقاط الولاء' : 'Loyalty Points'}</th>
                <th>{locale === 'ar' ? 'عدد الطلبات' : 'Orders Count'}</th>
                <th>{locale === 'ar' ? 'الملاحظات والتفضيلات' : 'Preferences & Notes'}</th>
                <th>{locale === 'ar' ? 'الحالة' : 'Status'}</th>
                <th>{locale === 'ar' ? 'الإجراء' : 'Actions'}</th>
              </tr>
            </thead>
            <tbody>
              {filteredCustomers.map((c) => (
                <tr key={c.id}>
                  <td>
                    <strong>{c.name}</strong>
                  </td>
                  <td>
                    <div>
                      {c.phone && (
                        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                          <Phone size={12} /> {c.phone}
                        </span>
                      )}
                    </div>
                    {c.email && (
                      <small style={{ color: '#777169', display: 'inline-flex', alignItems: 'center', gap: 4 }}>
                        <Mail size={11} /> {c.email}
                      </small>
                    )}
                  </td>
                  <td>
                    <span style={{ fontWeight: 800, color: '#8a4b0f', background: '#fff0d5', padding: '4px 8px', borderRadius: 12, fontSize: 11 }}>
                      ⭐ {c.loyalty_points} pts
                    </span>
                  </td>
                  <td>
                    <b>{c.orders_count ?? 1}</b> {locale === 'ar' ? 'طلبات' : 'orders'}
                  </td>
                  <td>
                    <span style={{ fontSize: 12, color: '#554f48' }}>{c.notes || '—'}</span>
                  </td>
                  <td>
                    <StatusPill tone="positive">{locale === 'ar' ? 'نشط' : 'Active'}</StatusPill>
                  </td>
                  <td>
                    <button
                      className="ghost-button"
                      style={{ padding: '4px 8px', fontSize: 11 }}
                      onClick={() => setSelectedCustomer(c)}
                    >
                      {locale === 'ar' ? 'سجل المشتريات' : 'History'}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: New Customer */}
      {showAddModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(480px, 92vw)' }}>
            <h2 style={{ margin: '0 0 16px' }}>{locale === 'ar' ? 'تسجيل عميل جديد' : 'New Customer Profile'}</h2>
            <form onSubmit={handleCreateCustomer} style={{ display: 'grid', gap: 12 }}>
              <label className="field-label">
                {locale === 'ar' ? 'الاسم الكامل' : 'Full Name'}
                <input required value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. Sultan Al Qasimi" />
              </label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  {locale === 'ar' ? 'رقم الهاتف' : 'Phone'}
                  <input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="+971501112233" />
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'البريد الإلكتروني' : 'Email'}
                  <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="sultan@example.ae" />
                </label>
              </div>
              <label className="field-label">
                {locale === 'ar' ? 'تفضيلات أو ملاحظات المشروبات' : 'Preferences / Notes'}
                <input value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="e.g. Prefers oat milk, extra hot" />
              </label>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowAddModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'حفظ العميل' : 'Save Customer'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Customer Profile / History View */}
      {selectedCustomer && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(500px, 92vw)' }}>
            <h2 style={{ margin: '0 0 6px' }}>{selectedCustomer.name}</h2>
            <p style={{ margin: '0 0 16px', color: '#777169', fontSize: 13 }}>
              {selectedCustomer.phone} · {selectedCustomer.email || 'No email'}
            </p>
            <div style={{ background: '#f8f6f0', padding: 14, borderRadius: 8, marginBottom: 16 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span>{locale === 'ar' ? 'رصيد نقاط الولاء:' : 'Loyalty Points:'}</span>
                <b>{selectedCustomer.loyalty_points} pts</b>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span>{locale === 'ar' ? 'التفضيلات المسجلة:' : 'Preferences:'}</span>
                <span>{selectedCustomer.notes || '—'}</span>
              </div>
            </div>
            <strong style={{ fontSize: 13, display: 'block', marginBottom: 8 }}>
              {locale === 'ar' ? 'سجل مشتريات نقطة البيع (ERP POS)' : 'Recent POS Purchases'}
            </strong>
            <div style={{ display: 'grid', gap: 8, fontSize: 12 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 12px', background: '#faf9f6', borderRadius: 6 }}>
                <span>#NE1042 · 1x Café Latte (Oat Milk)</span>
                <b>AED 21.00</b>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 12px', background: '#faf9f6', borderRadius: 6 }}>
                <span>#NE1038 · 2x Spanish Latte</span>
                <b>AED 54.00</b>
              </div>
            </div>
            <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 20 }}>
              <button className="primary-button" onClick={() => setSelectedCustomer(null)}>
                {locale === 'ar' ? 'إغلاق' : 'Close'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
