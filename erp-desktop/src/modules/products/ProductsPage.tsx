import { useState, useEffect } from 'react';
import { Archive, Coffee, Layers, Plus, Search, Tag } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';
import { StatusPill } from '../../components/StatusPill';

interface ProductVariant {
  id?: number;
  name_en: string;
  name_ar: string;
  price_minor: number;
  is_default?: boolean;
}

interface RecipeLine {
  inventory_item_id: number;
  quantity: number;
  unit: string;
  item?: {
    name_en: string;
    name_ar: string;
  };
}

interface Product {
  id: number;
  sku: string;
  name_en: string;
  name_ar: string;
  category: string;
  station_code: string;
  is_active: boolean;
  variants: ProductVariant[];
  recipes?: Array<{
    active_version?: {
      lines: RecipeLine[];
    };
  }>;
}

const mockProducts: Product[] = [
  {
    id: 1,
    sku: 'LATTE-STD',
    name_en: 'Café Latte',
    name_ar: 'لاتيه كافيه',
    category: 'Hot Coffee',
    station_code: 'HOT_BAR',
    is_active: true,
    variants: [
      { id: 101, name_en: 'Regular 8oz', name_ar: 'عادي 8 أونصة', price_minor: 2000, is_default: true },
      { id: 102, name_en: 'Large 12oz', name_ar: 'كبير 12 أونصة', price_minor: 2400, is_default: false },
    ],
    recipes: [
      {
        active_version: {
          lines: [
            { inventory_item_id: 1, quantity: 0.018, unit: 'kg', item: { name_en: 'Espresso Beans', name_ar: 'بن قهوة' } },
            { inventory_item_id: 2, quantity: 0.2, unit: 'L', item: { name_en: 'Fresh Milk', name_ar: 'حليب طازج' } },
          ],
        },
      },
    ],
  },
  {
    id: 2,
    sku: 'SPAN-LATTE',
    name_en: 'Spanish Latte',
    name_ar: 'سبانش لاتيه',
    category: 'Hot Coffee',
    station_code: 'HOT_BAR',
    is_active: true,
    variants: [
      { id: 103, name_en: 'Single', name_ar: 'مفرد', price_minor: 2500, is_default: true },
    ],
  },
];

export function ProductsPage() {
  const { locale, t } = useI18n();
  const [products, setProducts] = useState<Product[]>(mockProducts);
  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [showAddModal, setShowAddModal] = useState(false);
  const [feedback, setFeedback] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // New product form state
  const [newSku, setNewSku] = useState('');
  const [newNameEn, setNewNameEn] = useState('');
  const [newNameAr, setNewNameAr] = useState('');
  const [newCategory, setNewCategory] = useState('Hot Coffee');
  const [newStation, setNewStation] = useState('HOT_BAR');
  const [newPriceAed, setNewPriceAed] = useState('22.00');
  const [newBeansGram, setNewBeansGram] = useState('18');
  const [newMilkMl, setNewMilkMl] = useState('200');

  useEffect(() => {
    if (!sessionAdapter.isDemoMode()) {
      apiClient
        .request<{ products: Product[] }>('products')
        .then((res) => {
          if (res?.products && res.products.length > 0) {
            setProducts(res.products);
          }
        })
        .catch(() => {
          // Keep mock in case of offline/demo
        });
    }
  }, []);

  const filteredProducts = products.filter((p) => {
    const matchesSearch =
      p.name_en.toLowerCase().includes(search.toLowerCase()) ||
      p.name_ar.includes(search) ||
      p.sku.toLowerCase().includes(search.toLowerCase());
    const matchesCat = categoryFilter === 'All' || p.category === categoryFilter;
    return matchesSearch && matchesCat;
  });

  const handleCreateProduct = async (e: React.FormEvent) => {
    e.preventDefault();
    setFeedback(null);

    const priceMinor = Math.round(parseFloat(newPriceAed || '0') * 100);
    const beansKg = parseFloat(newBeansGram || '0') / 1000;
    const milkL = parseFloat(newMilkMl || '0') / 1000;

    const payload = {
      sku: newSku.toUpperCase().trim(),
      name_en: newNameEn.trim(),
      name_ar: newNameAr.trim(),
      category: newCategory,
      station_code: newStation,
      variants: [
        {
          name_en: 'Standard',
          name_ar: 'قياسي',
          price_minor: priceMinor,
          is_default: true,
        },
      ],
      recipe_lines: [
        { inventory_item_id: 1, quantity: beansKg, unit: 'kg' },
        { inventory_item_id: 2, quantity: milkL, unit: 'L' },
      ],
    };

    if (sessionAdapter.isDemoMode()) {
      const created: Product = {
        id: Date.now(),
        sku: payload.sku,
        name_en: payload.name_en,
        name_ar: payload.name_ar,
        category: payload.category,
        station_code: payload.station_code,
        is_active: true,
        variants: payload.variants,
        recipes: [
          {
            active_version: {
              lines: [
                { inventory_item_id: 1, quantity: beansKg, unit: 'kg', item: { name_en: 'Espresso Beans', name_ar: 'بن قهوة' } },
                { inventory_item_id: 2, quantity: milkL, unit: 'L', item: { name_en: 'Fresh Milk', name_ar: 'حليب طازج' } },
              ],
            },
          },
        ],
      };
      setProducts([created, ...products]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم إنشاء المنتج بنجاح' : 'Product created successfully' });
      setShowAddModal(false);
      return;
    }

    try {
      const res = await apiClient.request<Product>('products', {
        method: 'POST',
        body: JSON.stringify(payload),
      });
      setProducts([res, ...products]);
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تم حفظ المنتج بالخادم' : 'Product saved on server' });
      setShowAddModal(false);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to save product';
      setFeedback({ type: 'error', message: msg });
    }
  };

  const handleArchive = async (id: number) => {
    if (sessionAdapter.isDemoMode()) {
      setProducts(products.filter((p) => p.id !== id));
      return;
    }
    try {
      await apiClient.request(`products/${id}/archive`, { method: 'POST' });
      setProducts(products.filter((p) => p.id !== id));
      setFeedback({ type: 'success', message: locale === 'ar' ? 'تمت أرشفة المنتج' : 'Product archived' });
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Failed to archive';
      setFeedback({ type: 'error', message: msg });
    }
  };

  return (
    <div className="products-page">
      <div className="page-heading">
        <div>
          <p className="eyebrow">{locale === 'ar' ? 'الكتالوج والوصفات · دبي وأبوظبي' : 'Catalog & Recipes · Multi-Branch'}</p>
          <h1>{locale === 'ar' ? 'إدارة المنتجات والوصفات' : 'Products & Recipe Management'}</h1>
          <p>{locale === 'ar' ? 'تعريف المنتجات والأحجام والأسعار وربطها بالمحطات والوصفات المعتمدة' : 'Configure menu items, variant pricing, station routing, and BOM recipe ingredients.'}</p>
        </div>
        <button className="primary-button" onClick={() => setShowAddModal(true)}>
          <Plus size={17} />
          {locale === 'ar' ? 'إضافة منتج جديد' : 'New Product'}
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

      <div className="panel">
        <div className="panel__header">
          <div className="filters">
            <div className="search" style={{ width: 280 }}>
              <Search size={16} />
              <input
                aria-label="Filter products"
                placeholder={locale === 'ar' ? 'ابحث بالاسم أو SKU...' : 'Search by name or SKU…'}
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <select
              aria-label="Filter category"
              value={categoryFilter}
              onChange={(e) => setCategoryFilter(e.target.value)}
            >
              <option value="All">{locale === 'ar' ? 'جميع الفئات' : 'All Categories'}</option>
              <option value="Hot Coffee">{locale === 'ar' ? 'قهوة ساخنة' : 'Hot Coffee'}</option>
              <option value="Cold Drinks">{locale === 'ar' ? 'مشروبات باردة' : 'Cold Drinks'}</option>
              <option value="Bakery">{locale === 'ar' ? 'مخبوزات' : 'Bakery'}</option>
            </select>
          </div>
          <span className="section-label">{filteredProducts.length} {locale === 'ar' ? 'منتج نشط' : 'active items'}</span>
        </div>

        <div className="table-wrap">
          <table>
            <thead>
              <tr>
                <th>SKU</th>
                <th>{locale === 'ar' ? 'الاسم' : 'Product Name'}</th>
                <th>{locale === 'ar' ? 'الفئة والمحطة' : 'Category / Station'}</th>
                <th>{locale === 'ar' ? 'الأحجام والأسعار' : 'Variants & Price'}</th>
                <th>{locale === 'ar' ? 'الوصفة المعتمدة' : 'BOM Recipe'}</th>
                <th>{locale === 'ar' ? 'الحالة' : 'Status'}</th>
                <th>{locale === 'ar' ? 'إجراء' : 'Actions'}</th>
              </tr>
            </thead>
            <tbody>
              {filteredProducts.map((p) => {
                const recipeLines = p.recipes?.[0]?.active_version?.lines ?? [];
                return (
                  <tr key={p.id}>
                    <td>
                      <code style={{ fontSize: 11, background: '#eeeae2', padding: '3px 6px', borderRadius: 4 }}>
                        {p.sku}
                      </code>
                    </td>
                    <td>
                      <strong>{locale === 'ar' ? p.name_ar : p.name_en}</strong>
                      <br />
                      <small style={{ color: '#777169' }}>{locale === 'ar' ? p.name_en : p.name_ar}</small>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                        <span>{p.category}</span>
                        <StatusPill tone="neutral">{p.station_code}</StatusPill>
                      </div>
                    </td>
                    <td>
                      {p.variants.map((v) => (
                        <div key={v.id ?? v.name_en} style={{ fontSize: 11 }}>
                          <span>{locale === 'ar' ? v.name_ar : v.name_en}: </span>
                          <b>AED {(v.price_minor / 100).toFixed(2)}</b>
                        </div>
                      ))}
                    </td>
                    <td>
                      {recipeLines.length > 0 ? (
                        <div style={{ fontSize: 11, color: '#554f48' }}>
                          {recipeLines.map((l, i) => (
                            <span key={i} style={{ display: 'block' }}>
                              • {l.quantity} {l.unit} {l.item ? (locale === 'ar' ? l.item.name_ar : l.item.name_en) : 'item'}
                            </span>
                          ))}
                        </div>
                      ) : (
                        <small style={{ color: '#918a81' }}>{locale === 'ar' ? 'لا توجد وصفة' : 'No recipe'}</small>
                      )}
                    </td>
                    <td>
                      <StatusPill tone="positive">{locale === 'ar' ? 'نشط' : 'Active'}</StatusPill>
                    </td>
                    <td>
                      <button
                        onClick={() => handleArchive(p.id)}
                        title={locale === 'ar' ? 'أرشفة' : 'Archive'}
                        style={{ border: 0, background: 'transparent', cursor: 'pointer', color: '#a02d28' }}
                      >
                        <Archive size={15} />
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {showAddModal && (
        <div style={{
          position: 'fixed',
          inset: 0,
          background: 'rgba(0,0,0,0.5)',
          display: 'grid',
          placeItems: 'center',
          zIndex: 99,
        }}>
          <div style={{
            background: 'white',
            borderRadius: 12,
            padding: 24,
            width: 'min(520px, 92vw)',
            boxShadow: '0 20px 40px rgba(0,0,0,0.2)',
          }}>
            <h2 style={{ margin: '0 0 16px' }}>{locale === 'ar' ? 'تعريف منتج ووصفة جديدة' : 'New Product & Recipe'}</h2>
            <form onSubmit={handleCreateProduct} style={{ display: 'grid', gap: 12 }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  SKU
                  <input
                    required
                    placeholder="e.g. LATTE-OAT"
                    value={newSku}
                    onChange={(e) => setNewSku(e.target.value)}
                  />
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'المحطة' : 'Station'}
                  <select value={newStation} onChange={(e) => setNewStation(e.target.value)}>
                    <option value="HOT_BAR">HOT_BAR (Hot Coffee)</option>
                    <option value="COLD_BAR">COLD_BAR (Cold Drinks)</option>
                    <option value="PASTRY">PASTRY (Bakery)</option>
                  </select>
                </label>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  English Name
                  <input
                    required
                    placeholder="e.g. Oat Milk Latte"
                    value={newNameEn}
                    onChange={(e) => setNewNameEn(e.target.value)}
                  />
                </label>
                <label className="field-label">
                  الاسم بالعربية
                  <input
                    required
                    placeholder="مثال: لاتيه حليب الشوفان"
                    value={newNameAr}
                    onChange={(e) => setNewNameAr(e.target.value)}
                  />
                </label>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                <label className="field-label">
                  {locale === 'ar' ? 'الفئة' : 'Category'}
                  <select value={newCategory} onChange={(e) => setNewCategory(e.target.value)}>
                    <option value="Hot Coffee">Hot Coffee</option>
                    <option value="Cold Drinks">Cold Drinks</option>
                    <option value="Bakery">Bakery</option>
                  </select>
                </label>
                <label className="field-label">
                  {locale === 'ar' ? 'السعر (AED)' : 'Price (AED)'}
                  <input
                    type="number"
                    step="0.5"
                    required
                    value={newPriceAed}
                    onChange={(e) => setNewPriceAed(e.target.value)}
                  />
                </label>
              </div>

              <div style={{ background: '#f8f6f0', padding: 12, borderRadius: 8, border: '1px solid #e5e0d5' }}>
                <strong style={{ fontSize: 12, display: 'block', marginBottom: 8 }}>
                  {locale === 'ar' ? 'الوصفة (خصم المخزون لكل كوب)' : 'Recipe BOM (Ingredients Per Cup)'}
                </strong>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  <label className="field-label">
                    {locale === 'ar' ? 'بن القهوة (جرام)' : 'Coffee Beans (g)'}
                    <input
                      type="number"
                      value={newBeansGram}
                      onChange={(e) => setNewBeansGram(e.target.value)}
                    />
                  </label>
                  <label className="field-label">
                    {locale === 'ar' ? 'الحليب (مل)' : 'Fresh Milk (ml)'}
                    <input
                      type="number"
                      value={newMilkMl}
                      onChange={(e) => setNewMilkMl(e.target.value)}
                    />
                  </label>
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: 8, marginTop: 12 }}>
                <button type="button" className="ghost-button" onClick={() => setShowAddModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="primary-button">
                  {locale === 'ar' ? 'حفظ المنتج والوصفة' : 'Save Product & Recipe'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
