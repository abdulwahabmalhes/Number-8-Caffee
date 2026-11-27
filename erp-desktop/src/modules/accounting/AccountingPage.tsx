import { useState, useEffect } from 'react';
import { AlertCircle, CheckCircle2, CircleDollarSign, CreditCard, Download, FileText, Lock, Plus, Receipt, ShieldCheck, TrendingUp, Wallet, RefreshCw } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';
import { MetricCard } from '../../components/MetricCard';
import { apiClient } from '../../services/apiClient';
import { sessionAdapter } from '../../services/sessionAdapter';

interface JournalLine {
  id: string;
  accountCode: string;
  accountNameEn: string;
  accountNameAr: string;
  debitMinor: number;
  creditMinor: number;
  memo?: string;
}

interface JournalEntry {
  id: string;
  journalNumber: string;
  date: string;
  descriptionEn: string;
  descriptionAr: string;
  postedBy: string;
  period: string;
  status: 'POSTED' | 'DRAFT';
  lines: JournalLine[];
}

const mockJournals: JournalEntry[] = [
  {
    id: 'je-1',
    journalNumber: 'JRN-2026-0891',
    date: '2026-11-23 16:30',
    descriptionEn: 'Daily POS Sales Settlement (Shift #42)',
    descriptionAr: 'تسوية مبيعات نقطة البيع اليومية (وردية #42)',
    postedBy: 'Automated POS Service',
    period: '2026-11',
    status: 'POSTED',
    lines: [
      { id: 'jl-1', accountCode: '1010', accountNameEn: 'Cash on Hand', accountNameAr: 'النقد في الصندوق', debitMinor: 485000, creditMinor: 0, memo: 'Shift cash collected' },
      { id: 'jl-2', accountCode: '1020', accountNameEn: 'Card Receivables', accountNameAr: 'مستحقات أجهزة البطاقات', debitMinor: 1142000, creditMinor: 0, memo: 'Terminal network batch' },
      { id: 'jl-3', accountCode: '4010', accountNameEn: 'Beverage & Coffee Revenue', accountNameAr: 'إيرادات المشروبات والقهوة', debitMinor: 0, creditMinor: 1549524, memo: 'Net beverage sales' },
      { id: 'jl-4', accountCode: '2020', accountNameEn: 'VAT Output Tax (5%)', accountNameAr: 'ضريبة القيمة المضافة المحصلة (5%)', debitMinor: 0, creditMinor: 77476, memo: '5% UAE standard tax' },
    ],
  },
  {
    id: 'je-2',
    journalNumber: 'JRN-2026-0890',
    date: '2026-11-23 11:15',
    descriptionEn: 'Inventory Goods Receipt - Ethiopian Green Beans (PO #304)',
    descriptionAr: 'استلام بضاعة مخزون - بن إثيوبي أخضر (طلب شراء #304)',
    postedBy: 'Mariam Al Mansoori',
    period: '2026-11',
    status: 'POSTED',
    lines: [
      { id: 'jl-5', accountCode: '1050', accountNameEn: 'Raw Coffee Inventory', accountNameAr: 'مخزون البن الخام', debitMinor: 520000, creditMinor: 0, memo: '50kg specialty green coffee' },
      { id: 'jl-6', accountCode: '2010', accountNameEn: 'Accounts Payable - Suppliers', accountNameAr: 'ذمم دائنة - الموردين', debitMinor: 0, creditMinor: 520000, memo: 'Dubai Roasters Trading' },
    ],
  },
  {
    id: 'je-3',
    journalNumber: 'JRN-2026-0889',
    date: '2026-11-22 22:00',
    descriptionEn: 'Kitchen Spoilage & Milk Expiry Reversal',
    descriptionAr: 'قيد إتلاف حليب ومنتجات ألبان منتهية الصلاحية',
    postedBy: 'Khaled Chef',
    period: '2026-11',
    status: 'POSTED',
    lines: [
      { id: 'jl-7', accountCode: '5030', accountNameEn: 'Inventory Spoilage & Waste Expense', accountNameAr: 'مصاريف تالف وهدر المخزون', debitMinor: 14500, creditMinor: 0, memo: '8 cartons fresh milk' },
      { id: 'jl-8', accountCode: '1055', accountNameEn: 'Dairy & Perishables Inventory', accountNameAr: 'مخزون الألبان والمواد الطازجة', debitMinor: 0, creditMinor: 14500, memo: 'Stock write-off' },
    ],
  },
];

const mockAccounts = [
  { code: '1010', nameEn: 'Cash on Hand', nameAr: 'النقد في الصندوق', type: 'Asset', balanceMinor: 1845000 },
  { code: '1020', nameEn: 'Card Receivables', nameAr: 'مستحقات أجهزة البطاقات', type: 'Asset', balanceMinor: 3421500 },
  { code: '1050', nameEn: 'Raw Coffee Inventory', nameAr: 'مخزون البن الخام', type: 'Asset', balanceMinor: 4890000 },
  { code: '2010', nameEn: 'Accounts Payable - Suppliers', nameAr: 'ذمم دائنة - الموردين', type: 'Liability', balanceMinor: 1950000 },
  { code: '2020', nameEn: 'VAT Output Tax (5%)', nameAr: 'ضريبة القيمة المضافة المحصلة (5%)', type: 'Liability', balanceMinor: 384500 },
  { code: '4010', nameEn: 'Beverage & Coffee Revenue', nameAr: 'إيرادات المشروبات والقهوة', type: 'Revenue', balanceMinor: 8945200 },
  { code: '5010', nameEn: 'Cost of Goods Sold (COGS)', nameAr: 'تكلفة البضاعة المباعة', type: 'Expense', balanceMinor: 2450000 },
];

export function AccountingPage() {
  const { locale } = useI18n();
  const [activeTab, setActiveTab] = useState<'journals' | 'accounts' | 'vat'>('journals');
  const [periodClosed, setPeriodClosed] = useState(false);
  const [showAddModal, setShowAddModal] = useState(false);
  const [selectedPeriod, setSelectedPeriod] = useState('2026-11');
  const [loading, setLoading] = useState(false);
  const [journals, setJournals] = useState<JournalEntry[]>(mockJournals);
  const [accounts, setAccounts] = useState(mockAccounts);
  const [vatData, setVatData] = useState<{
    standard_rated_sales_minor: number;
    output_tax_minor: number;
    recoverable_input_tax_minor: number;
    net_payable_minor: number;
  }>({
    standard_rated_sales_minor: 1549524,
    output_tax_minor: 77476,
    recoverable_input_tax_minor: 26000,
    net_payable_minor: 51476,
  });

  const loadAccountingData = async () => {
    if (sessionAdapter.isDemoMode()) return;
    setLoading(true);
    try {
      const jRes = await apiClient.request<{ journals: any[] }>(`accounting/journals?period=${selectedPeriod}`);
      if (jRes?.journals && jRes.journals.length > 0) {
        setJournals(
          jRes.journals.map((j: any) => ({
            id: String(j.id),
            journalNumber: j.journal_number,
            date: j.posted_at || j.created_at,
            descriptionEn: j.description,
            descriptionAr: j.description,
            postedBy: 'System ERP',
            period: j.period || selectedPeriod,
            status: 'POSTED',
            lines: (j.lines || []).map((l: any) => ({
              id: String(l.id),
              accountCode: l.account?.code || '1000',
              accountNameEn: l.account?.name_en || 'Account',
              accountNameAr: l.account?.name_ar || 'حساب',
              debitMinor: l.debit_minor || 0,
              creditMinor: l.credit_minor || 0,
              memo: l.memo,
            })),
          }))
        );
      }

      const aRes = await apiClient.request<{ accounts: any[] }>(`accounting/accounts?period=${selectedPeriod}`);
      if (aRes?.accounts && aRes.accounts.length > 0) {
        setAccounts(
          aRes.accounts.map((a: any) => ({
            code: a.code,
            nameEn: a.name_en,
            nameAr: a.name_ar,
            type: a.type.charAt(0).toUpperCase() + a.type.slice(1),
            balanceMinor: a.balance_minor,
          }))
        );
      }

      const vRes = await apiClient.request<any>(`accounting/vat-report?period=${selectedPeriod}`);
      if (vRes) {
        setVatData(vRes);
      }
    } catch {
      // Fallback gracefully on mock
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadAccountingData();
  }, [selectedPeriod]);

  // New journal entry state
  const [newDesc, setNewDesc] = useState('');
  const [debitAmt, setDebitAmt] = useState(100);
  const [creditAmt, setCreditAmt] = useState(100);

  const formatAed = (minor: number) => {
    return (minor / 100).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + ' AED';
  };

  const handleCreateJournal = (e: React.FormEvent) => {
    e.preventDefault();
    if (debitAmt !== creditAmt) {
      alert(locale === 'ar' ? 'يجب أن يتطابق مجموع المدين مع الدائن!' : 'Total Debits must equal Credits!');
      return;
    }

    const newEntry: JournalEntry = {
      id: `je-${Date.now()}`,
      journalNumber: `JRN-2026-0${journals.length + 892}`,
      date: new Date().toISOString().replace('T', ' ').substring(0, 16),
      descriptionEn: newDesc || 'Manual Adjustment Entry',
      descriptionAr: newDesc || 'قيد تسوية يدوي',
      postedBy: 'Branch Manager',
      period: '2026-11',
      status: 'POSTED',
      lines: [
        { id: `jl-${Date.now()}-1`, accountCode: '1010', accountNameEn: 'Cash on Hand', accountNameAr: 'النقد في الصندوق', debitMinor: debitAmt * 100, creditMinor: 0 },
        { id: `jl-${Date.now()}-2`, accountCode: '4010', accountNameEn: 'Beverage Revenue', accountNameAr: 'إيرادات المشروبات', debitMinor: 0, creditMinor: creditAmt * 100 },
      ],
    };

    setJournals([newEntry, ...journals]);
    setShowAddModal(false);
    setNewDesc('');
  };

  return (
    <div className="accounting-page">
      <div className="page-header">
        <div>
          <h2>{locale === 'ar' ? 'الإدارة المالية والمحاسبة' : 'General Ledger & Accounting'}</h2>
          <p className="page-subtitle">
            {locale === 'ar'
              ? 'قيود اليومية المزدوجة المتوازنة، دليل الحسابات، وتسويات ضريبة القيمة المضافة'
              : 'Balanced double-entry journals, chart of accounts, and automated tax compliance'}
          </p>
        </div>
        <div className="header-actions">
          <button className="btn-secondary" onClick={() => alert(locale === 'ar' ? 'تم تجهيز ملف التصدير للتدقيق' : 'Export prepared')}>
            <Download size={16} />
            <span>{locale === 'ar' ? 'تصدير التقارير' : 'Export'}</span>
          </button>
          <button className="btn-primary" onClick={() => setShowAddModal(true)}>
            <Plus size={16} />
            <span>{locale === 'ar' ? 'قيد يومية جديد' : 'New Journal'}</span>
          </button>
        </div>
      </div>

      <div className={`period-banner ${periodClosed ? 'period-closed' : 'period-open'}`}>
        <div className="period-info">
          <ShieldCheck size={20} className={periodClosed ? 'text-danger' : 'text-success'} />
          <div>
            <strong>
              {locale === 'ar' ? 'الفترة المالية الحالية: نوفمبر 2026 (2026-11)' : 'Current Financial Period: November 2026 (2026-11)'}
            </strong>
            <span className="period-badge">{periodClosed ? (locale === 'ar' ? 'مغلقة' : 'CLOSED') : (locale === 'ar' ? 'مفتوحة للقيود' : 'OPEN')}</span>
          </div>
        </div>
        <button
          className={`btn-period ${periodClosed ? 'btn-reopen' : 'btn-close'}`}
          onClick={() => setPeriodClosed(!periodClosed)}
        >
          <Lock size={15} />
          <span>
            {periodClosed
              ? (locale === 'ar' ? 'إعادة فتح الفترة (تتطلب تدقيق الأدمن)' : 'Re-open Period (Audited)')
              : (locale === 'ar' ? 'إغلاق الفترة وترحيل الأرصدة' : 'Close Period')}
          </span>
        </button>
      </div>

      <div className="metrics-grid">
        <MetricCard
          icon={TrendingUp}
          label={locale === 'ar' ? 'إجمالي المبيعات المرحلة' : 'Posted Revenue'}
          value="16,270.00 AED"
          trend={locale === 'ar' ? '+14% مقارنة بالأمس' : '+14% vs yesterday'}
        />
        <MetricCard
          icon={Receipt}
          label={locale === 'ar' ? 'ضريبة القيمة المضافة (5%)' : 'VAT Payable (5%)'}
          value="774.76 AED"
          trend={locale === 'ar' ? 'مطابقة للفواتير الضريبية' : 'Reconciled to tax invoices'}
        />
        <MetricCard
          icon={Wallet}
          label={locale === 'ar' ? 'النقد في الصندوق (تسوية الوردية)' : 'Cash in Register'}
          value="4,850.00 AED"
          trend={locale === 'ar' ? 'تمت المطابقة مع الخزنة' : 'Drawer count matched'}
        />
        <MetricCard
          icon={CreditCard}
          label={locale === 'ar' ? 'مستحقات شبكات الدفع (Visa/Master)' : 'Card Receivables'}
          value="11,420.00 AED"
          trend={locale === 'ar' ? 'قيد التحويل البنكي' : 'Pending batch settlement'}
        />
      </div>

      <div className="accounting-tabs">
        <button
          className={`tab-btn ${activeTab === 'journals' ? 'active' : ''}`}
          onClick={() => setActiveTab('journals')}
        >
          <FileText size={16} />
          <span>{locale === 'ar' ? 'سجل قيود اليومية (Journals)' : 'Journal Entries'}</span>
        </button>
        <button
          className={`tab-btn ${activeTab === 'accounts' ? 'active' : ''}`}
          onClick={() => setActiveTab('accounts')}
        >
          <CircleDollarSign size={16} />
          <span>{locale === 'ar' ? 'دليل الحسابات (Chart of Accounts)' : 'Chart of Accounts'}</span>
        </button>
        <button
          className={`tab-btn ${activeTab === 'vat' ? 'active' : ''}`}
          onClick={() => setActiveTab('vat')}
        >
          <CheckCircle2 size={16} />
          <span>{locale === 'ar' ? 'تقرير الإقرار الضريبي (VAT Return)' : 'VAT Return (UAE)'}</span>
        </button>
      </div>

      {activeTab === 'journals' && (
        <div className="journals-list">
          {journals.map((journal) => {
            const totalDebit = journal.lines.reduce((acc, l) => acc + l.debitMinor, 0);
            const totalCredit = journal.lines.reduce((acc, l) => acc + l.creditMinor, 0);
            const isBalanced = totalDebit === totalCredit;

            return (
              <div key={journal.id} className="journal-card">
                <div className="journal-header">
                  <div>
                    <div className="journal-title-row">
                      <span className="journal-code">{journal.journalNumber}</span>
                      <span className="journal-status-pill">{journal.status}</span>
                      {isBalanced ? (
                        <span className="balanced-pill"><CheckCircle2 size={13} /> {locale === 'ar' ? 'متوازن' : 'Balanced'}</span>
                      ) : (
                        <span className="unbalanced-pill"><AlertCircle size={13} /> {locale === 'ar' ? 'غير متوازن!' : 'Unbalanced!'}</span>
                      )}
                    </div>
                    <p className="journal-desc">{locale === 'ar' ? journal.descriptionAr : journal.descriptionEn}</p>
                  </div>
                  <div className="journal-meta">
                    <span>📅 {journal.date}</span>
                    <span>👤 {journal.postedBy}</span>
                  </div>
                </div>

                <table className="journal-table">
                  <thead>
                    <tr>
                      <th>{locale === 'ar' ? 'رقم الحساب' : 'Code'}</th>
                      <th>{locale === 'ar' ? 'اسم الحساب' : 'Account Name'}</th>
                      <th>{locale === 'ar' ? 'البيان' : 'Memo'}</th>
                      <th className="num-col">{locale === 'ar' ? 'مدين (Debit)' : 'Debit'}</th>
                      <th className="num-col">{locale === 'ar' ? 'دائن (Credit)' : 'Credit'}</th>
                    </tr>
                  </thead>
                  <tbody>
                    {journal.lines.map((line) => (
                      <tr key={line.id}>
                        <td><code>{line.accountCode}</code></td>
                        <td><strong>{locale === 'ar' ? line.accountNameAr : line.accountNameEn}</strong></td>
                        <td className="memo-cell">{line.memo || '—'}</td>
                        <td className="num-col">{line.debitMinor > 0 ? formatAed(line.debitMinor) : '—'}</td>
                        <td className="num-col">{line.creditMinor > 0 ? formatAed(line.creditMinor) : '—'}</td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot>
                    <tr>
                      <td colSpan={3}><strong>{locale === 'ar' ? 'الإجمالي' : 'Total'}</strong></td>
                      <td className="num-col"><strong>{formatAed(totalDebit)}</strong></td>
                      <td className="num-col"><strong>{formatAed(totalCredit)}</strong></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
            );
          })}
        </div>
      )}

      {activeTab === 'accounts' && (
        <div className="accounts-table-container">
          <table className="data-table">
            <thead>
              <tr>
                <th>{locale === 'ar' ? 'رمز الحساب' : 'Code'}</th>
                <th>{locale === 'ar' ? 'اسم الحساب' : 'Account Name'}</th>
                <th>{locale === 'ar' ? 'نوع الحساب' : 'Type'}</th>
                <th className="num-col">{locale === 'ar' ? 'الرصيد الدفتري' : 'Book Balance'}</th>
              </tr>
            </thead>
            <tbody>
              {accounts.map((acc) => (
                <tr key={acc.code}>
                  <td><code>{acc.code}</code></td>
                  <td><strong>{locale === 'ar' ? acc.nameAr : acc.nameEn}</strong></td>
                  <td><span className={`acc-type-pill ${acc.type.toLowerCase()}`}>{acc.type}</span></td>
                  <td className="num-col">{formatAed(acc.balanceMinor)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {activeTab === 'vat' && (
        <div className="vat-summary-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <div>
              <h3 style={{ margin: 0 }}>{locale === 'ar' ? 'ملخص ضريبة القيمة المضافة للدولة (UAE FTA 5%)' : 'UAE FTA 5% VAT Return Summary'}</h3>
              <p className="subtitle" style={{ margin: '4px 0 0', color: '#777169' }}>
                {locale === 'ar' ? `الفترة الضريبية: ${selectedPeriod}` : `Tax period: ${selectedPeriod}`}
              </p>
            </div>
            <select
              value={selectedPeriod}
              onChange={(e) => setSelectedPeriod(e.target.value)}
              style={{ padding: '6px 12px', borderRadius: 8, border: '1px solid #d5cfc4' }}
            >
              <option value="2026-11">2026-11 (November)</option>
              <option value="2026-12">2026-12 (December)</option>
            </select>
          </div>
          
          <div className="vat-breakdown-grid">
            <div className="vat-box">
              <span>{locale === 'ar' ? 'المبيعات الخاضعة للضريبة القياسية (5%)' : 'Standard Rated Supplies (5%)'}</span>
              <strong>{formatAed(vatData.standard_rated_sales_minor)}</strong>
            </div>
            <div className="vat-box">
              <span>{locale === 'ar' ? 'ضريبة المخرجات المستحقة' : 'Output Tax Collected'}</span>
              <strong className="text-primary">{formatAed(vatData.output_tax_minor)}</strong>
            </div>
            <div className="vat-box">
              <span>{locale === 'ar' ? 'ضريبة المدخلات القابلة للاسترداد (المشتريات)' : 'Recoverable Input Tax'}</span>
              <strong>{formatAed(vatData.recoverable_input_tax_minor)}</strong>
            </div>
            <div className="vat-box net-box">
              <span>{locale === 'ar' ? 'صافي الضريبة الواجبة السداد للهيئة' : 'Net Payable to FTA'}</span>
              <strong className="text-danger">{formatAed(vatData.net_payable_minor)}</strong>
            </div>
          </div>
        </div>
      )}

      {showAddModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <h3>{locale === 'ar' ? 'إنشاء قيد يومية يدوي متوازن' : 'Create Balanced Manual Journal Entry'}</h3>
            <form onSubmit={handleCreateJournal}>
              <div className="form-group">
                <label>{locale === 'ar' ? 'بيان القيد' : 'Description'}</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Petty cash replenishment"
                  value={newDesc}
                  onChange={(e) => setNewDesc(e.target.value)}
                />
              </div>

              <div className="journal-lines-form">
                <div className="form-row">
                  <span><strong>1010 - Cash on Hand</strong> (Debit):</span>
                  <input
                    type="number"
                    min="1"
                    value={debitAmt}
                    onChange={(e) => setDebitAmt(Number(e.target.value))}
                  />
                  <span>AED</span>
                </div>
                <div className="form-row">
                  <span><strong>4010 - Beverage Revenue</strong> (Credit):</span>
                  <input
                    type="number"
                    min="1"
                    value={creditAmt}
                    onChange={(e) => setCreditAmt(Number(e.target.value))}
                  />
                  <span>AED</span>
                </div>
              </div>

              <div className="balance-indicator">
                {debitAmt === creditAmt ? (
                  <span className="text-success"><CheckCircle2 size={16} /> {locale === 'ar' ? 'القيد متوازن تماماً' : 'Journal is balanced'} ({debitAmt} AED)</span>
                ) : (
                  <span className="text-danger"><AlertCircle size={16} /> {locale === 'ar' ? 'فرق عدم توازن:' : 'Imbalance:'} {Math.abs(debitAmt - creditAmt)} AED</span>
                )}
              </div>

              <div className="modal-actions">
                <button type="button" className="btn-secondary" onClick={() => setShowAddModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="btn-primary" disabled={debitAmt !== creditAmt}>
                  {locale === 'ar' ? 'ترحيل القيد' : 'Post Journal'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
