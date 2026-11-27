import { useState } from 'react';
import { ArrowUpRight, BarChart2, Calendar, CheckCheck, CircleDollarSign, Download, Percent, PieChart, Printer, Receipt, TrendingUp } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { MetricCard } from '../../components/MetricCard';

interface TopProduct {
  nameEn: string;
  nameAr: string;
  category: string;
  unitsSold: number;
  totalRevenueAed: number;
}

const topProducts: TopProduct[] = [
  { nameEn: 'Spanish Iced Latte', nameAr: 'سبانش لاتيه بارد', category: 'Cold Coffee', unitsSold: 184, totalRevenueAed: 4600.00 },
  { nameEn: 'Flat White', nameAr: 'فلات وايت', category: 'Hot Coffee', unitsSold: 142, totalRevenueAed: 3124.00 },
  { nameEn: 'V60 Drip (Ethiopia Guji)', nameAr: 'قهوة مقطرة V60', category: 'Specialty Drip', unitsSold: 98, totalRevenueAed: 2744.00 },
  { nameEn: 'Pistachio Basque Cheesecake', nameAr: 'تشيز كيك فستق', category: 'Pastry & Dessert', unitsSold: 76, totalRevenueAed: 2432.00 },
  { nameEn: 'Signature Chemex', nameAr: 'كيمكس توقيع', category: 'Specialty Drip', unitsSold: 54, totalRevenueAed: 1890.00 },
];

export function ReportsPage() {
  const { locale } = useI18n();
  const [dateRange, setDateRange] = useState<'today' | '7d' | '30d'>('today');

  const exportCsv = () => {
    alert(locale === 'ar' ? 'تم تنزيل تقرير التسوية المالية بصيغة CSV' : 'Financial reconciliation report CSV downloaded');
  };

  return (
    <div className="reports-page">
      <div className="page-header">
        <div>
          <h2>{locale === 'ar' ? 'التقارير التحليلية والتسويات المالية' : 'Executive Reports & Financial Reconciliation'}</h2>
          <p className="page-subtitle">
            {locale === 'ar'
              ? 'تحليل الإيرادات، مطابقة قنوات الدفع، وأداء المبيعات استناداً للقيود المرحلة'
              : 'Audited revenue metrics, tender reconciliation, and product sales provenance'}
          </p>
        </div>
        <div className="header-actions">
          <button className="btn-secondary" onClick={() => window.print()}>
            <Printer size={16} />
            <span>{locale === 'ar' ? 'طباعة' : 'Print'}</span>
          </button>
          <button className="btn-primary" onClick={exportCsv}>
            <Download size={16} />
            <span>{locale === 'ar' ? 'تصدير CSV' : 'Export CSV'}</span>
          </button>
        </div>
      </div>

      <div className="reports-controls-bar">
        <div className="date-filter-group">
          <Calendar size={16} className="text-muted" />
          <button
            className={`date-pill ${dateRange === 'today' ? 'active' : ''}`}
            onClick={() => setDateRange('today')}
          >
            {locale === 'ar' ? 'اليوم (23 نوفمبر)' : 'Today (Nov 23)'}
          </button>
          <button
            className={`date-pill ${dateRange === '7d' ? 'active' : ''}`}
            onClick={() => setDateRange('7d')}
          >
            {locale === 'ar' ? 'آخر 7 أيام' : 'Last 7 Days'}
          </button>
          <button
            className={`date-pill ${dateRange === '30d' ? 'active' : ''}`}
            onClick={() => setDateRange('30d')}
          >
            {locale === 'ar' ? 'الشهر الحالي (نوفمبر)' : 'This Month (Nov 2026)'}
          </button>
        </div>

        <div className="provenance-tag">
          <CheckCheck size={14} className="text-success" />
          <span>
            {locale === 'ar'
              ? 'البيانات مرحلة ومطابقة مع القيود المحاسبية بنسبة 100%'
              : '100% Reconciled with General Ledger Journals'}
          </span>
        </div>
      </div>

      <div className="metrics-grid">
        <MetricCard
          icon={CircleDollarSign}
          label={locale === 'ar' ? 'إجمالي المبيعات الإجمالية' : 'Gross Sales'}
          value="16,840.00 AED"
          trend={locale === 'ar' ? '+18% مقارنة بالأسبوع الماضي' : '+18% vs last week'}
        />
        <MetricCard
          icon={Percent}
          label={locale === 'ar' ? 'الخصومات والعروض الترويجية' : 'Discounts & Offers'}
          value="-570.00 AED"
          trend={locale === 'ar' ? '3.3% من إجمالي المبيعات' : '3.3% discount rate'}
        />
        <MetricCard
          icon={TrendingUp}
          label={locale === 'ar' ? 'صافي الإيرادات الخاضعة للضريبة' : 'Net Taxable Sales'}
          value="15,495.24 AED"
          trend={locale === 'ar' ? 'أساس احتساب ضريبة الـ 5%' : 'Base for 5% VAT'}
        />
        <MetricCard
          icon={Receipt}
          label={locale === 'ar' ? 'ضريبة القيمة المضافة المحصلة' : 'VAT Collected (5%)'}
          value="774.76 AED"
          trend={locale === 'ar' ? 'مطابقة للتقرير الضريبي' : 'Matches tax ledger'}
        />
      </div>

      <div className="reports-charts-row">
        <div className="report-card">
          <div className="card-header">
            <div className="card-title">
              <PieChart size={18} />
              <h3>{locale === 'ar' ? 'تسوية قنوات وطرق الدفع' : 'Tender Mix & Reconciliation'}</h3>
            </div>
            <span className="reconciled-pill">16,270.00 AED</span>
          </div>

          <div className="tender-bars-list">
            <div className="tender-bar-item">
              <div className="bar-label-row">
                <span>💳 {locale === 'ar' ? 'بطاقات الائتمان ومحافظ الهاتف (Visa, Apple Pay)' : 'Card & Apple Pay'}</span>
                <strong>11,420.00 AED (70.2%)</strong>
              </div>
              <div className="progress-track">
                <div className="progress-fill fill-card" style={{ width: '70.2%' }}></div>
              </div>
            </div>

            <div className="tender-bar-item">
              <div className="bar-label-row">
                <span>💵 {locale === 'ar' ? 'النقد في الصندوق (تسوية الوردية)' : 'Cash Drawer Tenders'}</span>
                <strong>4,850.00 AED (29.8%)</strong>
              </div>
              <div className="progress-track">
                <div className="progress-fill fill-cash" style={{ width: '29.8%' }}></div>
              </div>
            </div>
          </div>
        </div>

        <div className="report-card">
          <div className="card-header">
            <div className="card-title">
              <TrendingUp size={18} />
              <h3>{locale === 'ar' ? 'قنوات الطلب (Channel Mix)' : 'Order Channel Breakdown'}</h3>
            </div>
            <span className="reconciled-pill">{locale === 'ar' ? '548 طلباً' : '548 orders'}</span>
          </div>

          <div className="channel-distribution">
            <div className="channel-stat">
              <span className="channel-icon">☕</span>
              <strong>52%</strong>
              <span>{locale === 'ar' ? 'تناول بالصالة' : 'Dine-In'}</span>
            </div>
            <div className="channel-stat">
              <span className="channel-icon">🛍️</span>
              <strong>28%</strong>
              <span>{locale === 'ar' ? 'استلام سفري' : 'Takeaway'}</span>
            </div>
            <div className="channel-stat">
              <span className="channel-icon">🚗</span>
              <strong>20%</strong>
              <span>{locale === 'ar' ? 'طلب بالسيارة' : 'Car Pickup'}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="report-card mt-4">
        <div className="card-header">
          <div className="card-title">
            <BarChart2 size={18} />
            <h3>{locale === 'ar' ? 'أعلى الأصناف مبيعاً ومساهمة في الإيراد' : 'Top Selling Products by Revenue'}</h3>
          </div>
          <span className="text-muted text-sm">{locale === 'ar' ? 'مرتبة تنازلياً حسب الإيراد' : 'Sorted by total revenue'}</span>
        </div>

        <table className="data-table">
          <thead>
            <tr>
              <th>#</th>
              <th>{locale === 'ar' ? 'اسم المنتج' : 'Product Name'}</th>
              <th>{locale === 'ar' ? 'التصنيف' : 'Category'}</th>
              <th className="num-col">{locale === 'ar' ? 'الكمية المباعة' : 'Units Sold'}</th>
              <th className="num-col">{locale === 'ar' ? 'إجمالي المبيعات' : 'Total Revenue'}</th>
              <th className="num-col">{locale === 'ar' ? 'الاتجاه' : 'Trend'}</th>
            </tr>
          </thead>
          <tbody>
            {topProducts.map((p, idx) => (
              <tr key={idx}>
                <td>{idx + 1}</td>
                <td><strong>{locale === 'ar' ? p.nameAr : p.nameEn}</strong></td>
                <td><span className="cat-tag">{p.category}</span></td>
                <td className="num-col">{p.unitsSold}</td>
                <td className="num-col font-mono font-bold">{p.totalRevenueAed.toFixed(2)} AED</td>
                <td className="num-col"><span className="text-success inline-flex items-center"><ArrowUpRight size={14} /> +{(12 - idx * 2)}%</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
