import { useState, useEffect } from 'react';
import { CheckCircle2, Minus, Plus, Search, ShoppingCart, User, XCircle } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';
import type { Product } from '../../types/erp';

interface CartItem {
  productId: string;
  variantId?: number;
  sku: string;
  nameEn: string;
  nameAr: string;
  priceMinor: number;
  quantity: number;
}

const defaultProducts: Product[] = [
  { id: '1', sku: 'COF-001', name: { en: 'Café Latte', ar: 'لاتيه كافيه' }, category: 'Coffee', priceMinor: 2000, available: true },
  { id: '2', sku: 'COF-002', name: { en: 'Spanish Latte', ar: 'سبانش لاتيه' }, category: 'Coffee', priceMinor: 2400, available: true },
  { id: '3', sku: 'COF-003', name: { en: 'Flat White', ar: 'فلات وايت' }, category: 'Coffee', priceMinor: 2100, available: true },
  { id: '4', sku: 'FIL-001', name: { en: 'V60 Ethiopia', ar: 'في 60 إثيوبيا' }, category: 'Filter', priceMinor: 2800, available: true },
  { id: '5', sku: 'BAK-001', name: { en: 'Pistachio Croissant', ar: 'كرواسون فستق' }, category: 'Bakery', priceMinor: 2600, available: true },
  { id: '6', sku: 'CLD-001', name: { en: 'Cold Brew', ar: 'كولد برو' }, category: 'Cold', priceMinor: 2200, available: true },
  { id: '7', sku: 'DES-001', name: { en: 'Tiramisu', ar: 'تيراميسو' }, category: 'Dessert', priceMinor: 3200, available: false },
];

export function PosPage() {
  const { locale } = useI18n();
  const [products, setProducts] = useState<Product[]>(defaultProducts);
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [search, setSearch] = useState('');
  const [orderType, setOrderType] = useState<'dine_in' | 'takeaway' | 'car_pickup'>('dine_in');
  const [cart, setCart] = useState<CartItem[]>([
    { productId: '1', sku: 'COF-001', nameEn: 'Café Latte', nameAr: 'لاتيه كافيه', priceMinor: 2000, quantity: 1 },
  ]);
  const [isGuest, setIsGuest] = useState(true);
  const [customerId, setCustomerId] = useState<number | undefined>(undefined);
  const [guestName, setGuestName] = useState('Walk-in Guest');
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string; details?: string } | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (!sessionAdapter.isDemoMode()) {
      apiClient
        .request<{ catalog: any[] }>('pos/catalog')
        .then((res) => {
          if (res?.catalog && res.catalog.length > 0) {
            const mapped: Product[] = res.catalog.map((c) => ({
              id: String(c.id),
              sku: c.sku,
              name: { en: c.name_en, ar: c.name_ar },
              category: c.category,
              priceMinor: c.variants?.[0]?.price_minor ?? 2000,
              available: c.variants?.[0]?.is_available ?? true,
            }));
            setProducts(mapped);
          }
        })
        .catch(() => {});
    }
  }, []);

  const [activeIdempotencyKey, setActiveIdempotencyKey] = useState<string>(
    () => 'pos-' + Date.now() + '-' + Math.random().toString(36).substring(2, 8)
  );

  const generateNewKey = () => {
    setActiveIdempotencyKey('pos-' + Date.now() + '-' + Math.random().toString(36).substring(2, 8));
  };

  const addToCart = (product: Product) => {
    setCart((prev) => {
      const existing = prev.find((item) => item.productId === product.id);
      if (existing) {
        return prev.map((item) =>
          item.productId === product.id ? { ...item, quantity: item.quantity + 1 } : item
        );
      }
      return [
        ...prev,
        {
          productId: product.id,
          sku: product.sku,
          nameEn: product.name.en,
          nameAr: product.name.ar,
          priceMinor: product.priceMinor,
          quantity: 1,
        },
      ];
    });
  };

  const updateQuantity = (productId: string, delta: number) => {
    setCart((prev) =>
      prev
        .map((item) => (item.productId === productId ? { ...item, quantity: item.quantity + delta } : item))
        .filter((item) => item.quantity > 0)
    );
  };

  const subtotalMinor = cart.reduce((sum, item) => sum + item.priceMinor * item.quantity, 0);
  const vatMinor = Math.round(subtotalMinor * 0.05);
  const totalMinor = subtotalMinor + vatMinor;

  const handleCheckout = async () => {
    if (cart.length === 0) return;
    setIsSubmitting(true);
    setFeedback(null);

    const idempotencyKey = activeIdempotencyKey;
    const payload = {
      customer_id: isGuest ? null : (customerId ?? 1),
      guest_name: isGuest ? guestName : undefined,
      order_type: orderType,
      items: cart.map((item) => ({
        product_id: parseInt(item.productId, 10),
        quantity: item.quantity,
      })),
    };

    if (sessionAdapter.isDemoMode()) {
      setTimeout(() => {
        setIsSubmitting(false);
        const orderNum = '#NE' + Math.floor(1000 + Math.random() * 9000);
        setFeedback({
          type: 'success',
          message: locale === 'ar' ? `تم اعتماد البيع النقدي للطلب ${orderNum}` : `Cash sale completed for order ${orderNum}`,
          details:
            locale === 'ar'
              ? 'تم خصم الوصفة من المخزون، إرسال تذكرة لمحطة البار الساخن، وترحيل قيد اليومية المتوازن (نقدية / إيراد / ضريبة).'
              : 'Recipe stock deducted, KDS ticket dispatched to HOT_BAR, and balanced journal posted (Cash 1010 / Revenue 4010 / VAT 2020).',
        });
        setCart([]);
        generateNewKey();
      }, 350);
      return;
    }

    try {
      const res = await apiClient.request<any>('pos/checkout', {
        method: 'POST',
        headers: { 'Idempotency-Key': idempotencyKey },
        body: JSON.stringify(payload),
      });
      setIsSubmitting(false);
      setFeedback({
        type: 'success',
        message: locale === 'ar' ? `تم تسجيل البيع بنجاح: ${res.order_number}` : `Order recorded: ${res.order_number}`,
        details:
          locale === 'ar'
            ? 'تم ترحيل الأثر المالي والمخزني وإشعار شاشة المطبخ.'
            : 'Inventory deducted and journal posted successfully on server.',
      });
      setCart([]);
      generateNewKey();
    } catch (err: unknown) {
      setIsSubmitting(false);
      const msg = err instanceof Error ? err.message : 'Checkout failed';
      setFeedback({
        type: 'error',
        message: locale === 'ar' ? 'فشل إتمام البيع (يمكنك إعادة المحاولة بأمان)' : 'Sale transaction failed (retry will safely reuse key)',
        details: msg,
      });
    }
  };

  const filteredProducts = products.filter((p) => {
    const matchesCat = selectedCategory === 'All' || p.category === selectedCategory;
    const matchesSearch =
      p.name.en.toLowerCase().includes(search.toLowerCase()) ||
      p.name.ar.includes(search) ||
      p.sku.toLowerCase().includes(search.toLowerCase());
    return matchesCat && matchesSearch;
  });

  return (
    <div className="pos-layout">
      <section className="pos-catalog">
        <div className="page-heading compact">
          <div>
            <p className="eyebrow">Shift #S-0042 · Register 1 · Dubai Flagship</p>
            <h1>{locale === 'ar' ? 'نقطة البيع والكاشير' : 'Point of Sale'}</h1>
          </div>
          <button className="ghost-button">
            {locale === 'ar' ? 'تسعير الفلس الإماراتي · ضريبة 5%' : 'UAE Fils Pricing · 5% VAT'}
          </button>
        </div>

        {feedback && (
          <div
            style={{
              padding: '14px 18px',
              borderRadius: 10,
              marginBottom: 16,
              backgroundColor: feedback.type === 'success' ? '#e4f4e9' : '#fbe8e6',
              color: feedback.type === 'success' ? '#24633c' : '#a02d28',
              border: `1px solid ${feedback.type === 'success' ? '#bce5c9' : '#f5c6c2'}`,
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontWeight: 700 }}>
              {feedback.type === 'success' ? <CheckCircle2 size={18} /> : <XCircle size={18} />}
              <span>{feedback.message}</span>
            </div>
            {feedback.details && (
              <small style={{ display: 'block', marginTop: 4, opacity: 0.9 }}>{feedback.details}</small>
            )}
          </div>
        )}

        <div className="pos-search">
          <Search size={20} />
          <input
            aria-label="Find products"
            placeholder={locale === 'ar' ? 'ابحث عن منتج أو كود SKU...' : 'Search products or scan SKU…'}
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        <div className="category-tabs" aria-label="Product categories">
          {['All', 'Coffee', 'Filter', 'Cold', 'Bakery', 'Dessert'].map((cat) => (
            <button
              key={cat}
              className={selectedCategory === cat ? 'active' : ''}
              onClick={() => setSelectedCategory(cat)}
            >
              {cat}
            </button>
          ))}
        </div>

        <div className="product-grid">
          {filteredProducts.map((product) => (
            <button
              className="product-card"
              key={product.id}
              disabled={!product.available}
              onClick={() => addToCart(product)}
            >
              <span className="product-card__visual">{product.name.en.slice(0, 1)}</span>
              <span>
                <strong>{locale === 'ar' ? product.name.ar : product.name.en}</strong>
                <small>{locale === 'ar' ? product.name.en : product.name.ar}</small>
              </span>
              <b>AED {(product.priceMinor / 100).toFixed(2)}</b>
              {!product.available ? <em>Unavailable</em> : null}
            </button>
          ))}
        </div>
      </section>

      <aside className="cart-panel">
        <div className="cart-panel__header">
          <span>
            <ShoppingCart size={20} />
            {locale === 'ar' ? 'الطلب الحالي' : 'Current Order'}
          </span>
          <span style={{ fontSize: 11, color: '#777169' }}>
            {cart.reduce((n, i) => n + i.quantity, 0)} {locale === 'ar' ? 'عناصر' : 'items'}
          </span>
        </div>

        <div className="order-type" aria-label="Order type">
          <button className={orderType === 'dine_in' ? 'active' : ''} onClick={() => setOrderType('dine_in')}>
            {locale === 'ar' ? 'محلي' : 'Dine-in'}
          </button>
          <button className={orderType === 'takeaway' ? 'active' : ''} onClick={() => setOrderType('takeaway')}>
            {locale === 'ar' ? 'سفري' : 'Takeaway'}
          </button>
          <button className={orderType === 'car_pickup' ? 'active' : ''} onClick={() => setOrderType('car_pickup')}>
            {locale === 'ar' ? 'سيارة' : 'Car'}
          </button>
        </div>

        {/* Customer / Guest Selector */}
        <div style={{ background: '#f8f6f0', padding: 10, borderRadius: 8, marginBottom: 12, border: '1px solid #e8e3da' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
            <span style={{ fontSize: 11, fontWeight: 700, color: '#6e675f', display: 'flex', alignItems: 'center', gap: 4 }}>
              <User size={13} /> {locale === 'ar' ? 'نوع العميل:' : 'Customer Type:'}
            </span>
            <div style={{ display: 'flex', gap: 4 }}>
              <button
                type="button"
                style={{
                  fontSize: 10,
                  fontWeight: 700,
                  padding: '3px 7px',
                  borderRadius: 4,
                  border: '1px solid #d3ccc2',
                  background: isGuest ? '#191714' : 'white',
                  color: isGuest ? 'white' : '#191714',
                }}
                onClick={() => setIsGuest(true)}
              >
                {locale === 'ar' ? 'ضيف' : 'Guest'}
              </button>
              <button
                type="button"
                style={{
                  fontSize: 10,
                  fontWeight: 700,
                  padding: '3px 7px',
                  borderRadius: 4,
                  border: '1px solid #d3ccc2',
                  background: !isGuest ? '#191714' : 'white',
                  color: !isGuest ? 'white' : '#191714',
                }}
                onClick={() => {
                  setIsGuest(false);
                  setCustomerId(1);
                }}
              >
                {locale === 'ar' ? 'عميل مسجل' : 'Registered'}
              </button>
            </div>
          </div>
          {isGuest ? (
            <input
              style={{ width: '100%', height: 32, fontSize: 11, border: '1px solid #dedad1', borderRadius: 6, padding: '0 8px' }}
              value={guestName}
              onChange={(e) => setGuestName(e.target.value)}
              placeholder="Guest Name (e.g. Walk-in Guest)"
            />
          ) : (
            <select
              style={{ width: '100%', height: 32, fontSize: 11, border: '1px solid #dedad1', borderRadius: 6, padding: '0 6px' }}
              value={customerId}
              onChange={(e) => setCustomerId(Number(e.target.value))}
            >
              <option value={1}>Sultan Al Qasimi (+971501112233) · 120 pts</option>
              <option value={2}>Fatima Al Marzouqi (+971504445566) · 85 pts</option>
              <option value={3}>Tariq Mansoor (+971558889900) · 40 pts</option>
            </select>
          )}
        </div>

        <div className="cart-lines">
          {cart.length === 0 ? (
            <p style={{ textAlign: 'center', color: '#918a81', padding: '30px 0', fontSize: 12 }}>
              {locale === 'ar' ? 'السلة فارغة. انقر على منتج لإضافته.' : 'Cart is empty. Select products from catalog.'}
            </p>
          ) : (
            cart.map((item) => (
              <div className="cart-line" key={item.productId}>
                <div>
                  <strong>{locale === 'ar' ? item.nameAr : item.nameEn}</strong>
                  <small>{item.sku} · AED {(item.priceMinor / 100).toFixed(2)}</small>
                </div>
                <div className="quantity">
                  <button aria-label="Decrease quantity" onClick={() => updateQuantity(item.productId, -1)}>
                    <Minus size={14} />
                  </button>
                  <span>{item.quantity}</span>
                  <button aria-label="Increase quantity" onClick={() => updateQuantity(item.productId, 1)}>
                    <Plus size={14} />
                  </button>
                </div>
                <b>AED {((item.priceMinor * item.quantity) / 100).toFixed(2)}</b>
              </div>
            ))
          )}
        </div>

        <div className="totals">
          <div>
            <span>{locale === 'ar' ? 'المجموع الفرعي' : 'Subtotal'}</span>
            <b>AED {(subtotalMinor / 100).toFixed(2)}</b>
          </div>
          <div>
            <span>{locale === 'ar' ? 'ضريبة القيمة المضافة (5%)' : 'VAT (5%)'}</span>
            <b>AED {(vatMinor / 100).toFixed(2)}</b>
          </div>
          <div className="grand">
            <span>{locale === 'ar' ? 'الإجمالي الصافي' : 'Total (AED)'}</span>
            <strong>AED {(totalMinor / 100).toFixed(2)}</strong>
          </div>
        </div>

        <button
          className="pay-button"
          disabled={cart.length === 0 || isSubmitting}
          onClick={handleCheckout}
          style={{ opacity: cart.length === 0 || isSubmitting ? 0.6 : 1 }}
        >
          {isSubmitting
            ? locale === 'ar' ? 'جارٍ الترحيل...' : 'Processing…'
            : locale === 'ar'
            ? `دفع نقدي AED ${(totalMinor / 100).toFixed(2)}`
            : `Cash Checkout AED ${(totalMinor / 100).toFixed(2)}`}
        </button>
        <small className="demo-note">
          {locale === 'ar'
            ? 'ترتيب الخصم الذري وترحيل القيود المحاسبية مع مفتاح Idempotency.'
            : 'Atomic recipe deduction & double-entry journal posting with Idempotency protection.'}
        </small>
      </aside>
    </div>
  );
}
