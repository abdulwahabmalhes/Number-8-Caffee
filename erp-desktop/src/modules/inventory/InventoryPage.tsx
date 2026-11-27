import { useState, useEffect } from 'react';
import { ArrowDownToLine, ArrowUpRight, AlertTriangle, PackagePlus, RefreshCw, Trash2 } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';
import { StatusPill } from '../../components/StatusPill';

interface InventoryItemApi {
  id: number;
  sku: string;
  name_en: string;
  name_ar: string;
  unit: string;
  unit_cost_minor: number;
  current_quantity: number;
  reorder_threshold: number;
  is_active: boolean;
}

interface StockMovementApi {
  id: number;
  inventory_item_id: number;
  item_name_en?: string;
  item_name_ar?: string;
  movement_type: 'in' | 'out' | 'adjustment' | 'waste';
  quantity_change: number;
  balance_after: number;
  unit_cost_minor: number;
  reference_type?: string;
  reference_id?: string;
  notes?: string;
  created_at: string;
}

const mockItems: InventoryItemApi[] = [
  {
    id: 1,
    sku: 'COF-BEANS',
    name_en: 'Specialty Espresso Coffee Beans',
    name_ar: 'بن قهوة إسبريسو مختصة',
    unit: 'kg',
    unit_cost_minor: 8000,
    current_quantity: 49.946,
    reorder_threshold: 10,
    is_active: true,
  },
  {
    id: 2,
    sku: 'MILK-FRESH',
    name_en: 'Fresh Barista Milk',
    name_ar: 'حليب طازج للباريستا',
    unit: 'L',
    unit_cost_minor: 600,
    current_quantity: 99.4,
    reorder_threshold: 20,
    is_active: true,
  },
];

const mockMovements: StockMovementApi[] = [
  {
    id: 1,
    inventory_item_id: 1,
    item_name_en: 'Specialty Espresso Coffee Beans',
    item_name_ar: 'بن قهوة إسبريسو مختصة',
    movement_type: 'out',
    quantity_change: -0.054,
    balance_after: 49.946,
    unit_cost_minor: 8000,
    reference_type: 'order',
    reference_id: '#NE1042',
    notes: 'POS sale recipe deduction (3 cups latte)',
    created_at: '2026-11-27 16:35',
  },
  {
    id: 2,
    inventory_item_id: 2,
    item_name_en: 'Fresh Barista Milk',
    item_name_ar: 'حليب طازج للباريستا',
    movement_type: 'out',
    quantity_change: -0.6,
    balance_after: 99.4,
    unit_cost_minor: 600,
    reference_type: 'order',
    reference_id: '#NE1042',
    notes: 'POS sale recipe deduction (3 cups latte)',
    created_at: '2026-11-27 16:35',
  },
  {
    id: 3,
    inventory_item_id: 1,
    item_name_en: 'Specialty Espresso Coffee Beans',
    item_name_ar: 'بن قهوة إسبريسو مختصة',
    movement_type: 'in',
    quantity_change: 50.0,
    balance_after: 50.0,
    unit_cost_minor: 8000,
    reference_type: 'purchase_order',
    reference_id: 'PO-20261126-7841',
    notes: 'Goods receipt from Al Ameed Coffee',
    created_at: '2026-11-27 10:15',
  },
  {
    id: 4,
    inventory_item_id: 2,
    item_name_en: 'Fresh Barista Milk',
    item_name_ar: 'حليب طازج للباريستا',
    movement_type: 'in',
    quantity_change: 100.0,
    balance_after: 100.0,
    unit_cost_minor: 600,
    reference_type: 'purchase_order',
    reference_id: 'PO-20261126-7841',
    notes: 'Goods receipt from Emirates Fresh Dairy',
    created_at: '2026-11-27 10:15',
  },
];

export function InventoryPage() {
  const { locale } = useI18n();
  const [items, setItems] = useState<InventoryItemApi[]>(mockItems);
  const [movements, setMovements] = useState<StockMovementApi[]>(mockMovements);
  const [search, setSearch] = useState('');
  const [activeTab, setActiveTab] = useState<'balances' | 'movements'>('balances');
  const [loading, setLoading] = useState(false);
  const [showWasteModal, setShowWasteModal] = useState(false);
  const [wasteItemId, setWasteItemId] = useState<number>(1);
  const [wasteQty, setWasteQty] = useState('1');
  const [wasteReason, setWasteReason] = useState('Milk expiry / Spoilage');
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const loadData = async () => {
    if (sessionAdapter.isDemoMode()) return;
    setLoading(true);
    try {
      const itemsRes = await apiClient.request<{ items: InventoryItemApi[] }>('inventory/items');
      if (itemsRes?.items) {
        setItems(itemsRes.items);
      }
      const movRes = await apiClient.request<{ movements: any[] }>('inventory/movements');
      if (movRes?.movements) {
        setMovements(
          movRes.movements.map((m: any) => ({
            id: m.id,
            inventory_item_id: m.inventory_item_id,
            item_name_en: m.item?.name_en ?? 'Item',
            item_name_ar: m.item?.name_ar ?? 'صنف',
            movement_type: m.movement_type,
            quantity_change: parseFloat(m.quantity_change),
            balance_after: parseFloat(m.balance_after),
            unit_cost_minor: m.unit_cost_minor ?? 0,
            reference_type: m.reference_type,
            reference_id: m.reference_id,
            notes: m.notes,
            created_at: m.created_at ? new Date(m.created_at).toLocaleString() : '',
          }))
        );
      }
    } catch {
      // Keep existing data gracefully
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleRecordWaste = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);

    const payload = {
      inventory_item_id: wasteItemId,
      quantity: parseFloat(wasteQty || '0'),
      reason: wasteReason,
    };

    if (sessionAdapter.isDemoMode()) {
      setItems((prev) =>
        prev.map((it) => (it.id === wasteItemId ? { ...it, current_quantity: Math.max(0, it.current_quantity - payload.quantity) } : it))
      );
      setFeedback({
        type: 'success',
        message: locale === 'ar' ? 'تم تسجيل إتلاف المخزون وترحيل قيد الهدر' : 'Inventory waste recorded and expense journal posted.',
      });
      setShowWasteModal(false);
      return;
    }

    try {
      await apiClient.request('inventory/waste', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      setFeedback({
        type: 'success',
        message: locale === 'ar' ? 'تم تسجيل الهدر في الخادم وتحديث رصيد الفرع' : 'Waste recorded and branch stock balance updated.',
      });
      setShowWasteModal(false);
      loadData();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Waste record failed';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const filteredItems = items.filter(
    (i) =>
      i.name_en.toLowerCase().includes(search.toLowerCase()) ||
      i.name_ar.includes(search) ||
      i.sku.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="inventory-page" style={{ padding: '24px 32px' }}>
      <div className="page-heading" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 24 }}>
        <div>
          <p className="eyebrow" style={{ fontSize: 12, color: '#777169', textTransform: 'uppercase', margin: 0 }}>
            {locale === 'ar' ? 'المستودع والمخزون · فرع دبي الرئيسي' : 'Warehouse & Inventory · Dubai Flagship'}
          </p>
          <h1 style={{ margin: '4px 0 8px', fontSize: 26, fontWeight: 700 }}>
            {locale === 'ar' ? 'إدارة المخزون والأرصدة الفرعية' : 'Branch Inventory & Stock Ledger'}
          </h1>
          <p style={{ margin: 0, color: '#777169', fontSize: 14 }}>
            {locale === 'ar'
              ? 'تتبع حركات الوارد (أوامر الشراء)، المنصرف (خصم الوصفات بالـ POS)، والهدر بسجلات ذرية دقيقة'
              : 'Real-time branch balances, automated recipe deductions, goods receipts, and waste tracking.'}
          </p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button className="ghost-button" onClick={loadData} title="Refresh">
            <RefreshCw size={15} className={loading ? 'spin' : ''} style={{ marginInlineEnd: 4 }} />
            {locale === 'ar' ? 'تحديث الأرصدة' : 'Refresh'}
          </button>
          <button className="primary-button" onClick={() => setShowWasteModal(true)}>
            <Trash2 size={16} style={{ marginInlineEnd: 6 }} />
            {locale === 'ar' ? 'تسجيل إتلاف / هدر' : 'Record Waste'}
          </button>
        </div>
      </div>

      {feedback && (
        <div
          style={{
            padding: '12px 16px',
            borderRadius: 8,
            marginBottom: 20,
            background: feedback.type === 'success' ? '#f0f9f4' : '#fff0f0',
            color: feedback.type === 'success' ? '#1f6f43' : '#c5221f',
            border: `1px solid ${feedback.type === 'success' ? '#a6d9be' : '#f5c2c7'}`,
          }}
        >
          {feedback.message}
        </div>
      )}

      {/* Tabs */}
      <div style={{ display: 'flex', gap: 12, borderBottom: '1px solid #e5e0d5', marginBottom: 20 }}>
        <button
          onClick={() => setActiveTab('balances')}
          style={{
            padding: '8px 16px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'balances' ? '2px solid #b8860b' : 'none',
            fontWeight: activeTab === 'balances' ? 700 : 400,
            color: activeTab === 'balances' ? '#111' : '#777169',
            cursor: 'pointer',
          }}
        >
          {locale === 'ar' ? 'الأرصدة الحالية للفرع' : 'Current Branch Balances'}
        </button>
        <button
          onClick={() => setActiveTab('movements')}
          style={{
            padding: '8px 16px',
            background: 'none',
            border: 'none',
            borderBottom: activeTab === 'movements' ? '2px solid #b8860b' : 'none',
            fontWeight: activeTab === 'movements' ? 700 : 400,
            color: activeTab === 'movements' ? '#111' : '#777169',
            cursor: 'pointer',
          }}
        >
          {locale === 'ar' ? 'دفتر حركات المخزون (Ledger)' : 'Stock Movement Ledger'}
        </button>
      </div>

      {activeTab === 'balances' ? (
        <div className="panel" style={{ background: 'white', borderRadius: 12, border: '1px solid #e5e0d5', padding: 20 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <span style={{ fontSize: 13, color: '#777169' }}>
              {locale === 'ar' ? `المواد المسجلة: ${filteredItems.length}` : `Active Items: ${filteredItems.length}`}
            </span>
            <input
              type="text"
              placeholder={locale === 'ar' ? 'بحث بالاسم أو الرمز SKU...' : 'Search by name or SKU...'}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{ width: 260, padding: '6px 12px', borderRadius: 8, border: '1px solid #d5cfc4' }}
            />
          </div>

          <div className="table-wrap">
            <table style={{ width: '100%', textAlign: 'start', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #e5e0d5', color: '#777169', fontSize: 12 }}>
                  <th style={{ padding: '8px 12px' }}>SKU</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'اسم المادة' : 'Item Name'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'الرصيد الفعلي' : 'On-Hand Stock'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'حد إعادة الطلب' : 'Reorder Level'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'تكلفة الوحدة' : 'Unit Cost'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'قيمة الرصيد' : 'Total Value'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'الحالة' : 'State'}</th>
                </tr>
              </thead>
              <tbody>
                {filteredItems.map((it) => {
                  const isLow = it.current_quantity <= it.reorder_threshold;
                  const totalVal = ((it.current_quantity * it.unit_cost_minor) / 100).toFixed(2);
                  return (
                    <tr key={it.id} style={{ borderBottom: '1px solid #f0ede6', fontSize: 13 }}>
                      <td style={{ padding: '12px' }}>
                        <code>{it.sku}</code>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <strong>{locale === 'ar' ? it.name_ar : it.name_en}</strong>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <b style={{ color: isLow ? '#c5221f' : '#111' }}>
                          {it.current_quantity.toFixed(3)} {it.unit}
                        </b>
                      </td>
                      <td style={{ padding: '12px', color: '#777169' }}>
                        {it.reorder_threshold} {it.unit}
                      </td>
                      <td style={{ padding: '12px' }}>AED {(it.unit_cost_minor / 100).toFixed(2)}</td>
                      <td style={{ padding: '12px' }}>
                        <b>AED {totalVal}</b>
                      </td>
                      <td style={{ padding: '12px' }}>
                        <StatusPill tone={isLow ? 'warning' : 'positive'}>
                          {isLow ? (locale === 'ar' ? 'تحت الحد' : 'LOW') : (locale === 'ar' ? 'سليم' : 'HEALTHY')}
                        </StatusPill>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        <div className="panel" style={{ background: 'white', borderRadius: 12, border: '1px solid #e5e0d5', padding: 20 }}>
          <h3 style={{ margin: '0 0 16px', fontSize: 16 }}>
            {locale === 'ar' ? 'سجل الحركات المخزنية الموثقة' : 'Traceable Stock Movements'}
          </h3>
          <div className="table-wrap">
            <table style={{ width: '100%', textAlign: 'start', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid #e5e0d5', color: '#777169', fontSize: 12 }}>
                  <th style={{ padding: '8px 12px' }}>ID</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'التوقيت' : 'Time'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'المادة' : 'Item'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'نوع الحركة' : 'Type'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'التغيير' : 'Delta'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'الرصيد بعدها' : 'Balance After'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'مرجع المستند' : 'Document Ref'}</th>
                  <th style={{ padding: '8px 12px' }}>{locale === 'ar' ? 'البيان' : 'Notes'}</th>
                </tr>
              </thead>
              <tbody>
                {movements.map((m) => {
                  const isPositive = m.quantity_change > 0;
                  return (
                    <tr key={m.id} style={{ borderBottom: '1px solid #f0ede6', fontSize: 12 }}>
                      <td style={{ padding: '10px 12px' }}>#{m.id}</td>
                      <td style={{ padding: '10px 12px', color: '#777169' }}>{m.created_at}</td>
                      <td style={{ padding: '10px 12px' }}>
                        <strong>{locale === 'ar' ? m.item_name_ar : m.item_name_en}</strong>
                      </td>
                      <td style={{ padding: '10px 12px' }}>
                        <span
                          style={{
                            padding: '2px 8px',
                            borderRadius: 6,
                            fontSize: 11,
                            fontWeight: 600,
                            background: m.movement_type === 'in' ? '#eaf5ee' : m.movement_type === 'waste' ? '#fff0f0' : '#f0f4ff',
                            color: m.movement_type === 'in' ? '#24633c' : m.movement_type === 'waste' ? '#c5221f' : '#2b5ea7',
                          }}
                        >
                          {m.movement_type.toUpperCase()}
                        </span>
                      </td>
                      <td style={{ padding: '10px 12px' }}>
                        <b style={{ color: isPositive ? '#24633c' : '#c5221f' }}>
                          {isPositive ? `+${m.quantity_change}` : m.quantity_change}
                        </b>
                      </td>
                      <td style={{ padding: '10px 12px' }}>
                        <b>{m.balance_after.toFixed(3)}</b>
                      </td>
                      <td style={{ padding: '10px 12px' }}>
                        <code>{m.reference_id || m.reference_type || '-'}</code>
                      </td>
                      <td style={{ padding: '10px 12px', color: '#555' }}>{m.notes || '-'}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Waste Modal */}
      {showWasteModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(480px, 92vw)' }}>
            <h2 style={{ margin: '0 0 8px' }}>{locale === 'ar' ? 'تسجيل إتلاف / هدر مخزون' : 'Record Inventory Waste'}</h2>
            <p style={{ margin: '0 0 16px', color: '#777169', fontSize: 13 }}>
              {locale === 'ar'
                ? 'خصم كمية تالفة مع ترحيل قيد محاسبي تلقائي (مدين مصاريف هدر 5030 / دائن مخزون 1050)'
                : 'Deduct damaged stock and post an automated loss journal (Debit Waste 5030 / Credit Inventory 1050).'}
            </p>
            <form onSubmit={handleRecordWaste} style={{ display: 'grid', gap: 12 }}>
              <label className="field-label">
                {locale === 'ar' ? 'المادة المراد إتلافها' : 'Inventory Item'}
                <select value={wasteItemId} onChange={(e) => setWasteItemId(parseInt(e.target.value, 10))}>
                  {items.map((it) => (
                    <option key={it.id} value={it.id}>
                      {locale === 'ar' ? it.name_ar : it.name_en} ({it.current_quantity.toFixed(2)} {it.unit})
                    </option>
                  ))}
                </select>
              </label>
              <label className="field-label">
                {locale === 'ar' ? 'الكمية المراد إتلافها' : 'Quantity to Discard'}
                <input type="number" step="0.01" required value={wasteQty} onChange={(e) => setWasteQty(e.target.value)} />
              </label>
              <label className="field-label">
                {locale === 'ar' ? 'سبب الإتلاف' : 'Waste Reason'}
                <input type="text" required value={wasteReason} onChange={(e) => setWasteReason(e.target.value)} />
              </label>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowWasteModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button" style={{ background: '#c5221f' }}>
                  {locale === 'ar' ? 'تأكيد وترحيل الإتلاف' : 'Confirm Waste & Post'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
