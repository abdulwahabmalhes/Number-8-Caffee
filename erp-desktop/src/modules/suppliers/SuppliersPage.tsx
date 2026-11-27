import { useState, useEffect } from 'react';
import { ArrowDownToLine, Building2, FileCheck, FileText, Plus, Search, Truck } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';
import { StatusPill } from '../../components/StatusPill';

interface Supplier {
  id: number;
  name: string;
  contact_name?: string;
  phone?: string;
  email?: string;
  tax_number?: string;
  address?: string;
  purchase_orders_count?: number;
}

interface PurchaseOrder {
  id: number;
  po_number: string;
  supplier_id: number;
  supplier?: { name: string };
  branch_id: number;
  status: string;
  total_minor: number;
  currency: string;
  lines: Array<{
    id: number;
    inventory_item_id: number;
    ordered_quantity: number;
    received_quantity: number;
    unit_cost_minor: number;
    item?: { name_en: string; unit: string };
  }>;
  goodsReceipts?: Array<{
    id: number;
    receipt_number: string;
  }>;
  invoices?: Array<{
    id: number;
    invoice_number: string;
  }>;
}

const mockSuppliers: Supplier[] = [
  {
    id: 1,
    name: 'Al Ameed Coffee Trading',
    contact_name: 'Rashid Al Nuaimi',
    phone: '+971501234567',
    email: 'orders@alameedcoffee.ae',
    tax_number: 'TRN-100234567800003',
    address: 'Al Quoz Industrial 3, Dubai',
    purchase_orders_count: 2,
  },
  {
    id: 2,
    name: 'Emirates Fresh Dairy & Beverage',
    contact_name: 'Omar Al Zaabi',
    phone: '+971509876543',
    email: 'supply@emiratesfresh.ae',
    tax_number: 'TRN-100987654300001',
    address: 'Al Ain Agricultural Zone',
    purchase_orders_count: 1,
  },
];

const mockOrders: PurchaseOrder[] = [
  {
    id: 101,
    po_number: 'PO-20261126-7841',
    supplier_id: 1,
    supplier: { name: 'Al Ameed Coffee Trading' },
    branch_id: 1,
    status: 'submitted',
    total_minor: 460000,
    currency: 'AED',
    lines: [
      { id: 201, inventory_item_id: 1, ordered_quantity: 50, received_quantity: 20, unit_cost_minor: 8000, item: { name_en: 'Espresso Beans', unit: 'kg' } },
      { id: 202, inventory_item_id: 2, ordered_quantity: 100, received_quantity: 40, unit_cost_minor: 600, item: { name_en: 'Fresh Milk', unit: 'L' } },
    ],
  },
];

export function SuppliersPage() {
  const { locale } = useI18n();
  const [suppliers, setSuppliers] = useState<Supplier[]>(mockSuppliers);
  const [purchaseOrders, setPurchaseOrders] = useState<PurchaseOrder[]>(mockOrders);
  const [search, setSearch] = useState('');
  const [showSupplierModal, setShowSupplierModal] = useState(false);
  const [showPoModal, setShowPoModal] = useState(false);
  const [showReceiveModal, setShowReceiveModal] = useState(false);
  const [showInvoiceModal, setShowInvoiceModal] = useState(false);
  const [selectedPo, setSelectedPo] = useState<PurchaseOrder | null>(null);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const [receiptIdempotencyKey, setReceiptIdempotencyKey] = useState<string>(
    () => 'gr-' + Date.now() + '-' + Math.random().toString(36).substring(2, 8)
  );
  const generateNewReceiptKey = () => {
    setReceiptIdempotencyKey('gr-' + Date.now() + '-' + Math.random().toString(36).substring(2, 8));
  };

  // Invoice Form
  const [invoiceNumber, setInvoiceNumber] = useState('');
  const [invoiceDate, setInvoiceDate] = useState(() => new Date().toISOString().slice(0, 10));
  const [invoiceTaxMinor, setInvoiceTaxMinor] = useState('0');

  // New Supplier Form
  const [supName, setSupName] = useState('');
  const [supContact, setSupContact] = useState('');
  const [supPhone, setSupPhone] = useState('');
  const [supEmail, setSupEmail] = useState('');
  const [supTrn, setSupTrn] = useState('');
  const [supAddress, setSupAddress] = useState('');

  // New PO Form
  const [selectedSupplierId, setSelectedSupplierId] = useState<number>(1);
  const [poBeansQty, setPoBeansQty] = useState('50');
  const [poMilkQty, setPoMilkQty] = useState('100');

  // Receive Form
  const [receiveBeansQty, setReceiveBeansQty] = useState('30');
  const [receiveMilkQty, setReceiveMilkQty] = useState('60');

  const loadSupplierOrders = async (supplierId: number) => {
    if (sessionAdapter.isDemoMode()) return;
    try {
      const res = await apiClient.request<any>(`suppliers/${supplierId}`);
      if (res && res.purchase_orders) {
        setPurchaseOrders(
          res.purchase_orders.map((po: any) => ({
            ...po,
            supplier: { name: res.name },
            goodsReceipts: po.goods_receipts || [],
            invoices: po.invoices || [],
          }))
        );
      }
    } catch {}
  };

  useEffect(() => {
    if (!sessionAdapter.isDemoMode()) {
      apiClient
        .request<{ suppliers: Supplier[] }>('suppliers')
        .then((res) => {
          if (res?.suppliers && res.suppliers.length > 0) {
            setSuppliers(res.suppliers);
            loadSupplierOrders(res.suppliers[0].id);
          }
        })
        .catch(() => {});
    }
  }, []);

  const handleCreateSupplier = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);

    const payload = {
      name: supName.trim(),
      contact_name: supContact.trim(),
      phone: supPhone.trim(),
      email: supEmail.trim(),
      tax_number: supTrn.trim(),
      address: supAddress.trim(),
    };

    if (sessionAdapter.isDemoMode()) {
      const created: Supplier = {
        id: Date.now(),
        ...payload,
        purchase_orders_count: 0,
      };
      setSuppliers([created, ...suppliers]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تمت إضافة المورد' : 'Supplier added successfully' });
      setShowSupplierModal(false);
      return;
    }

    try {
      const res = await apiClient.request<Supplier>('suppliers', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      setSuppliers([res, ...suppliers]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم حفظ المورد بالخادم' : 'Supplier saved' });
      setShowSupplierModal(false);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to save supplier';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const handleCreatePo = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);

    const payload = {
      supplier_id: selectedSupplierId,
      branch_id: 1,
      lines: [
        { inventory_item_id: 1, ordered_quantity: parseFloat(poBeansQty || '0'), unit_cost_minor: 8000 },
        { inventory_item_id: 2, ordered_quantity: parseFloat(poMilkQty || '0'), unit_cost_minor: 600 },
      ],
      notes: 'Replenishment order from desktop ERP',
    };

    if (sessionAdapter.isDemoMode()) {
      const createdPo: PurchaseOrder = {
        id: Date.now(),
        po_number: `PO-20261126-${Math.floor(1000 + Math.random() * 9000)}`,
        supplier_id: selectedSupplierId,
        supplier: { name: suppliers.find((s) => s.id === selectedSupplierId)?.name ?? 'Supplier' },
        branch_id: 1,
        status: 'submitted',
        total_minor: 460000,
        currency: 'AED',
        lines: [
          { id: Date.now() + 1, inventory_item_id: 1, ordered_quantity: parseFloat(poBeansQty), received_quantity: 0, unit_cost_minor: 8000, item: { name_en: 'Espresso Beans', unit: 'kg' } },
          { id: Date.now() + 2, inventory_item_id: 2, ordered_quantity: parseFloat(poMilkQty), received_quantity: 0, unit_cost_minor: 600, item: { name_en: 'Fresh Milk', unit: 'L' } },
        ],
      };
      setPurchaseOrders([createdPo, ...purchaseOrders]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم إنشاء أمر الشراء' : 'Purchase order created' });
      setShowPoModal(false);
      return;
    }

    try {
      const res = await apiClient.request<PurchaseOrder>('purchasing/orders', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      setPurchaseOrders([res, ...purchaseOrders]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم تسجيل أمر الشراء' : 'PO registered on server' });
      setShowPoModal(false);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to create PO';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const handleReceiveGoods = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPo) return;
    setFeedback(null);

    const bLine = selectedPo.lines.find((l) => l.inventory_item_id === 1) ?? selectedPo.lines[0];
    const mLine = selectedPo.lines.find((l) => l.inventory_item_id === 2) ?? selectedPo.lines[1];

    const rBeans = parseFloat(receiveBeansQty || '0');
    const rMilk = parseFloat(receiveMilkQty || '0');

    // Over-receive prevention check
    if (bLine && bLine.received_quantity + rBeans > bLine.ordered_quantity) {
      setFeedback({
        type: 'error',
        message: locale === 'ar'
          ? `لا يمكن استلام كمية تفوق المطلوب! المتبقي للبن: ${bLine.ordered_quantity - bLine.received_quantity} كجم`
          : `Over-receiving rejected! Max remaining beans: ${bLine.ordered_quantity - bLine.received_quantity} kg`,
      });
      return;
    }

    const payload = {
      received_by: 'Mariam Al Mansoori',
      notes: 'Desktop ERP Goods Receipt',
      lines: [
        { po_line_id: bLine?.id ?? 1, quantity_received: rBeans },
        { po_line_id: mLine?.id ?? 2, quantity_received: rMilk },
      ],
    };

    if (sessionAdapter.isDemoMode()) {
      // Update PO status
      setPurchaseOrders(
        purchaseOrders.map((po) => {
          if (po.id === selectedPo.id) {
            return {
              ...po,
              status: 'received',
              lines: po.lines.map((l) => ({
                ...l,
                received_quantity: l.ordered_quantity,
              })),
            };
          }
          return po;
        })
      );
      setFeedback({
        type: 'success',
        message: locale === 'ar'
          ? 'تم اعتماد استلام المواد وتحديث المخزون وترحيل قيد اليومية المتوازن (دائن ذمم / مدين مخزون)'
          : 'Goods receipt verified, stock ledger updated, and balanced journal posted.',
      });
      setShowReceiveModal(false);
      generateNewReceiptKey();
      return;
    }

    try {
      await apiClient.request(`purchasing/orders/${selectedPo.id}/receive`, {
        method: 'POST',
        headers: { 'Idempotency-Key': receiptIdempotencyKey },
        body: JSON.stringify(payload),
      });
      setFeedback({
        type: 'success',
        message: locale === 'ar' ? 'تم استلام المواد بنجاح في الخادم' : 'Goods received successfully',
      });
      setShowReceiveModal(false);
      generateNewReceiptKey();
      if (suppliers.length > 0) {
        loadSupplierOrders(suppliers[0].id);
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Receipt failed';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const handleCreateInvoice = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedPo) return;
    setFeedback(null);

    const grId = selectedPo.goodsReceipts?.[0]?.id ?? 1;

    if (sessionAdapter.isDemoMode()) {
      setPurchaseOrders(
        purchaseOrders.map((po) => {
          if (po.id === selectedPo.id) {
            return {
              ...po,
              invoices: [{ id: Date.now(), invoice_number: invoiceNumber || 'INV-DEMO-01' }],
            };
          }
          return po;
        })
      );
      setFeedback({
        type: 'success',
        message: locale === 'ar'
          ? 'تم ترحيل فاتورة المورد وقيد اليومية المحاسبي بنجاح (مدين مخزون 1050 / دائن ذمم دائنة 2010).'
          : 'Supplier invoice certified and balanced AP journal entry posted.',
      });
      setShowInvoiceModal(false);
      return;
    }

    try {
      await apiClient.request(`purchasing/orders/${selectedPo.id}/invoice`, {
        method: 'POST',
        body: JSON.stringify({
          goods_receipt_id: grId,
          invoice_number: invoiceNumber || `INV-${Date.now().toString().slice(-6)}`,
          invoice_date: invoiceDate,
          tax_minor: parseInt(invoiceTaxMinor, 10) || 0,
        }),
      });
      setFeedback({
        type: 'success',
        message: locale === 'ar'
          ? 'تم ترحيل فاتورة المورد في الخادم وترحيل القيد المحاسبي المتوازن.'
          : 'Supplier invoice created and balanced journal posted on server.',
      });
      setShowInvoiceModal(false);
      if (suppliers.length > 0) {
        loadSupplierOrders(suppliers[0].id);
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Invoice posting failed';
      setFeedback({ type: 'error', message: msg });
    }
  };

  return (
    <div className="suppliers-page">
      <div className="page-heading">
        <div>
          <p className="eyebrow">{locale === 'ar' ? 'سلسلة التوريد والمشتريات' : 'Procurement & Three-Way Match'}</p>
          <h1>{locale === 'ar' ? 'إدارة الموردين وأوامر الشراء' : 'Suppliers & Purchasing Orders'}</h1>
          <p>{locale === 'ar' ? 'إدارة الموردين المعتمدين، أوامر الشراء، استلام البضائع ومنع الاستلام الزائد' : 'Manage vetted vendors, issue POs, record goods receipts, and post balanced AP journals.'}</p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button className="ghost-button" onClick={() => setShowPoModal(true)}>
            <FileText size={16} />
            {locale === 'ar' ? 'أمر شراء جديد' : 'New Purchase Order'}
          </button>
          <button className="primary-button" onClick={() => setShowSupplierModal(true)}>
            <Plus size={16} />
            {locale === 'ar' ? 'إضافة مورد' : 'New Supplier'}
          </button>
        </div>
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

      {/* Purchase Orders Section */}
      <div className="panel" style={{ marginBottom: 20 }}>
        <div className="panel__header">
          <div>
            <span className="section-label">{locale === 'ar' ? 'أوامر الشراء والاستلام' : 'Active Purchase Orders'}</span>
            <h2>{locale === 'ar' ? 'سجل الأوامر والاستلامات المخزنية' : 'Purchase Orders & Stock Receipts'}</h2>
          </div>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>PO Number</th>
                <th>{locale === 'ar' ? 'المورد' : 'Supplier'}</th>
                <th>{locale === 'ar' ? 'المواد المطلوبة والمستلمة' : 'Items & Progress'}</th>
                <th>{locale === 'ar' ? 'الإجمالي' : 'Total'}</th>
                <th>{locale === 'ar' ? 'الحالة' : 'Status'}</th>
                <th>{locale === 'ar' ? 'الإجراء' : 'Actions'}</th>
              </tr>
            </thead>
            <tbody>
              {purchaseOrders.map((po) => (
                <tr key={po.id}>
                  <td>
                    <code>{po.po_number}</code>
                  </td>
                  <td>
                    <strong>{po.supplier?.name}</strong>
                  </td>
                  <td>
                    {po.lines.map((l) => (
                      <div key={l.id} style={{ fontSize: 11 }}>
                        <span>{l.item?.name_en ?? 'Item'}: </span>
                        <b>{l.received_quantity} / {l.ordered_quantity} {l.item?.unit}</b>
                      </div>
                    ))}
                  </td>
                  <td>
                    <b>AED {(po.total_minor / 100).toFixed(2)}</b>
                  </td>
                  <td>
                    <StatusPill tone={po.status === 'received' ? 'positive' : 'warning'}>
                      {po.status.toUpperCase()}
                    </StatusPill>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                      {po.status !== 'received' && (
                        <button
                          className="ghost-button"
                          style={{ padding: '4px 8px', fontSize: 11 }}
                          onClick={() => {
                            setSelectedPo(po);
                            setShowReceiveModal(true);
                          }}
                        >
                          <ArrowDownToLine size={13} style={{ marginInlineEnd: 4 }} />
                          {locale === 'ar' ? 'استلام بضاعة' : 'Receive Goods'}
                        </button>
                      )}
                      {(po.status === 'received' || po.status === 'partially_received') && (!po.invoices || po.invoices.length === 0) && (
                        <button
                          className="primary-button"
                          style={{ padding: '4px 8px', fontSize: 11 }}
                          onClick={() => {
                            setSelectedPo(po);
                            setInvoiceNumber(`INV-${Date.now().toString().slice(-6)}`);
                            setShowInvoiceModal(true);
                          }}
                        >
                          <FileCheck size={13} style={{ marginInlineEnd: 4 }} />
                          {locale === 'ar' ? 'ترحيل الفاتورة' : 'Post Invoice'}
                        </button>
                      )}
                      {po.invoices && po.invoices.length > 0 && (
                        <span style={{ fontSize: 11, color: '#24633c', display: 'flex', alignItems: 'center', gap: 4 }}>
                          <FileCheck size={14} /> {locale === 'ar' ? 'مفوتر بالكامل' : 'Invoiced'}
                        </span>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Suppliers Directory Section */}
      <div className="panel">
        <div className="panel__header">
          <div className="filters">
            <div className="search" style={{ width: 280 }}>
              <Search size={16} />
              <input
                aria-label="Filter suppliers"
                placeholder={locale === 'ar' ? 'البحث عن مورد أو هاتف أو TRN...' : 'Search supplier name, phone, TRN…'}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>
          <span className="section-label">{suppliers.length} {locale === 'ar' ? 'مورد معتمد' : 'Vetted Suppliers'}</span>
        </div>
        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>{locale === 'ar' ? 'اسم المورد' : 'Supplier Name'}</th>
                <th>{locale === 'ar' ? 'مسؤول الاتصال' : 'Contact Person'}</th>
                <th>{locale === 'ar' ? 'الهاتف والبريد' : 'Contact Info'}</th>
                <th>{locale === 'ar' ? 'الرقم الضريبي (TRN)' : 'Tax Number (TRN)'}</th>
                <th>{locale === 'ar' ? 'العنوان' : 'Address'}</th>
                <th>{locale === 'ar' ? 'أوامر الشراء' : 'Orders'}</th>
              </tr>
            </thead>
            <tbody>
              {suppliers
                .filter((s) => s.name.toLowerCase().includes(search.toLowerCase()) || s.phone?.includes(search))
                .map((s) => (
                  <tr key={s.id}>
                    <td>
                      <strong>{s.name}</strong>
                    </td>
                    <td>{s.contact_name || '—'}</td>
                    <td>
                      <div>{s.phone}</div>
                      <small style={{ color: '#777169' }}>{s.email}</small>
                    </td>
                    <td>
                      <code style={{ fontSize: 11 }}>{s.tax_number || 'N/A'}</code>
                    </td>
                    <td>{s.address || '—'}</td>
                    <td>
                      <span className="metric-tag">{s.purchase_orders_count ?? 1} POs</span>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal: New Supplier */}
      {showSupplierModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(500px, 92vw)' }}>
            <h2 style={{ margin: '0 0 16px' }}>{locale === 'ar' ? 'إضافة مورد جديد' : 'New Supplier'}</h2>
            <form onSubmit={handleCreateSupplier} style={{ display: 'grid', gap: 12 }}>
              <label className="field-label">
                {locale === 'ar' ? 'اسم الشركة / المورد' : 'Company / Supplier Name'}
                <input required value={supName} onChange={(e) => setSupName(e.target.value)} placeholder="e.g. Al Ameed Coffee Trading" />
              </label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  {locale === 'ar' ? 'اسم مسؤول الاتصال' : 'Contact Name'}
                  <input value={supContact} onChange={(e) => setSupContact(e.target.value)} placeholder="e.g. Rashid Al Nuaimi" />
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'رقم الهاتف' : 'Phone'}
                  <input value={supPhone} onChange={(e) => setSupPhone(e.target.value)} placeholder="+971501234567" />
                </label>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  {locale === 'ar' ? 'البريد الإلكتروني' : 'Email'}
                  <input type="email" value={supEmail} onChange={(e) => setSupEmail(e.target.value)} placeholder="orders@supplier.ae" />
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'الرقم الضريبي (TRN)' : 'Tax Number (TRN)'}
                  <input value={supTrn} onChange={(e) => setSupTrn(e.target.value)} placeholder="TRN-100234567800003" />
                </label>
              </div>
              <label className="field-label">
                {locale === 'ar' ? 'العنوان والموقع' : 'Address'}
                <input value={supAddress} onChange={(e) => setSupAddress(e.target.value)} placeholder="Al Quoz Industrial Area, Dubai" />
              </label>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowSupplierModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'حفظ المورد' : 'Save Supplier'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: New Purchase Order */}
      {showPoModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(520px, 92vw)' }}>
            <h2 style={{ margin: '0 0 16px' }}>{locale === 'ar' ? 'إنشاء أمر شراء (PO)' : 'New Purchase Order'}</h2>
            <form onSubmit={handleCreatePo} style={{ display: 'grid', gap: 12 }}>
              <label className="field-label">
                {locale === 'ar' ? 'اختر المورد' : 'Select Supplier'}
                <select value={selectedSupplierId} onChange={(e) => setSelectedSupplierId(Number(e.target.value))}>
                  {suppliers.map((s) => (
                    <option key={s.id} value={s.id}>{s.name}</option>
                  ))}
                </select>
              </label>
              <div style={{ background: '#f8f6f0', padding: 12, borderRadius: 8, border: '1px solid #e5e0d5' }}>
                <strong style={{ fontSize: 12, display: 'block', marginBottom: 8 }}>
                  {locale === 'ar' ? 'بنود التوريد المطلوبة' : 'Order Line Quantities'}
                </strong>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  <label className="field-label">
                    {locale === 'ar' ? 'بن القهوة (كجم @ 80 درهم)' : 'Coffee Beans (kg @ 80 AED)'}
                    <input type="number" value={poBeansQty} onChange={(e) => setPoBeansQty(e.target.value)} />
                  </label>
                  <label className="field-label">
                    {locale === 'ar' ? 'حليب طازج (لتر @ 6 دراهم)' : 'Fresh Milk (L @ 6 AED)'}
                    <input type="number" value={poMilkQty} onChange={(e) => setPoMilkQty(e.target.value)} />
                  </label>
                </div>
              </div>
              <p style={{ margin: 0, fontSize: 12, color: '#777169' }}>
                {locale === 'ar'
                  ? 'ملاحظة: أمر الشراء لا يغير رصيد المخزون حتى يتم اعتماد الاستلام الفعلي لمنع التكرار.'
                  : 'Note: PO submission does not alter stock balances until goods receipt is certified.'}
              </p>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowPoModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'إصدار أمر الشراء' : 'Issue Purchase Order'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Receive Goods */}
      {showReceiveModal && selectedPo && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(500px, 92vw)' }}>
            <h2 style={{ margin: '0 0 8px' }}>{locale === 'ar' ? 'اعتماد استلام بضاعة' : 'Goods Receipt Certification'}</h2>
            <p style={{ margin: '0 0 16px', color: '#777169', fontSize: 13 }}>
              PO: <code>{selectedPo.po_number}</code> · {selectedPo.supplier?.name}
            </p>
            <form onSubmit={handleReceiveGoods} style={{ display: 'grid', gap: 12 }}>
              <div style={{ background: '#f8f6f0', padding: 12, borderRadius: 8, border: '1px solid #e5e0d5' }}>
                <strong style={{ fontSize: 12, display: 'block', marginBottom: 8 }}>
                  {locale === 'ar' ? 'الكميات المستلمة في هذه الشحنة' : 'Quantities Received In This Shipment'}
                </strong>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  <label className="field-label">
                    {locale === 'ar' ? 'بن القهوة المستلم (كجم)' : 'Beans Received (kg)'}
                    <input type="number" value={receiveBeansQty} onChange={(e) => setReceiveBeansQty(e.target.value)} />
                  </label>
                  <label className="field-label">
                    {locale === 'ar' ? 'الحليب المستلم (لتر)' : 'Milk Received (L)'}
                    <input type="number" value={receiveMilkQty} onChange={(e) => setReceiveMilkQty(e.target.value)} />
                  </label>
                </div>
              </div>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowReceiveModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'اعتماد استلام البضاعة' : 'Certify Receipt'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Modal: Post Supplier Invoice */}
      {showInvoiceModal && selectedPo && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'grid', placeItems: 'center', zIndex: 99 }}>
          <div style={{ background: 'white', borderRadius: 12, padding: 24, width: 'min(500px, 92vw)' }}>
            <h2 style={{ margin: '0 0 8px' }}>{locale === 'ar' ? 'ترحيل فاتورة المورد' : 'Post Supplier Invoice'}</h2>
            <p style={{ margin: '0 0 16px', color: '#777169', fontSize: 13 }}>
              PO: <code>{selectedPo.po_number}</code> · {selectedPo.supplier?.name}
            </p>
            <form onSubmit={handleCreateInvoice} style={{ display: 'grid', gap: 12 }}>
              <label className="field-label">
                {locale === 'ar' ? 'رقم فاتورة المورد' : 'Supplier Invoice Number'}
                <input
                  type="text"
                  required
                  value={invoiceNumber}
                  onChange={(e) => setInvoiceNumber(e.target.value)}
                  placeholder="e.g. INV-98412"
                />
              </label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  {locale === 'ar' ? 'تاريخ الفاتورة' : 'Invoice Date'}
                  <input
                    type="date"
                    required
                    value={invoiceDate}
                    onChange={(e) => setInvoiceDate(e.target.value)}
                  />
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'قيمة الضريبة (بالفلس)' : 'Tax Amount (Minor Fils)'}
                  <input
                    type="number"
                    value={invoiceTaxMinor}
                    onChange={(e) => setInvoiceTaxMinor(e.target.value)}
                  />
                </label>
              </div>
              <p style={{ margin: 0, fontSize: 12, color: '#777169' }}>
                {locale === 'ar'
                  ? 'سيتم ربط الفاتورة بسند الاستلام وترحيل قيد اليومية (مدين 1050 مخزون / دائن 2010 ذمم دائنة).'
                  : 'Invoice will match goods receipt and post a balanced AP journal (Debit 1050 / Credit 2010).'}
              </p>
              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowInvoiceModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'ترحيل الفاتورة والقيد' : 'Post Invoice & Journal'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
