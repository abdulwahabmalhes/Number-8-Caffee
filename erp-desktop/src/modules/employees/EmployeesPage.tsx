import { useState } from 'react';
import { Check, KeyRound, Plus, Shield, ShieldAlert, ShieldCheck, UserCheck, Users, X } from 'lucide-react';
import { useI18n } from '../../i18n/I18nProvider';

interface Employee {
  id: string;
  name: string;
  email: string;
  role: string;
  isTenantAdmin: boolean;
  branches: string[];
  permissions: string[];
  isActive: boolean;
}

const mockEmployees: Employee[] = [
  {
    id: 'emp-1',
    name: 'Mariam Al Mansoori',
    email: 'mariam@no8.ae',
    role: 'Branch Manager',
    isTenantAdmin: false,
    branches: ['Dubai Flagship'],
    permissions: ['dashboard.view', 'pos.use', 'kitchen.view', 'inventory.view', 'accounting.view', 'reports.view'],
    isActive: true,
  },
  {
    id: 'emp-2',
    name: 'Owner Administrator',
    email: 'owner@no8.ae',
    role: 'Tenant Administrator',
    isTenantAdmin: true,
    branches: ['All Branches / كافة الفروع'],
    permissions: ['* (All System Capabilities)'],
    isActive: true,
  },
  {
    id: 'emp-3',
    name: 'Zaid Al Hashimi',
    email: 'zaid@no8.ae',
    role: 'Head Barista',
    isTenantAdmin: false,
    branches: ['Dubai Flagship'],
    permissions: ['kitchen.view', 'pos.use', 'inventory.view'],
    isActive: true,
  },
  {
    id: 'emp-4',
    name: 'Fatima Al Kaabi',
    email: 'fatima@no8.ae',
    role: 'Lead Cashier',
    isTenantAdmin: false,
    branches: ['Abu Dhabi Branch'],
    permissions: ['pos.use', 'kitchen.view'],
    isActive: true,
  },
  {
    id: 'emp-5',
    name: 'Tariq Accountant',
    email: 'tariq@no8.ae',
    role: 'Financial Accountant',
    isTenantAdmin: false,
    branches: ['Dubai Flagship', 'Abu Dhabi Branch'],
    permissions: ['accounting.view', 'accounting.post', 'reports.view'],
    isActive: true,
  },
];

const mockAuditLogs = [
  { id: 'al-1', time: '2026-11-23 16:45', actor: 'Owner Administrator', action: 'branch.admin_override', target: 'Abu Dhabi Branch (AUH-01)', reason: 'Emergency stock review audit' },
  { id: 'al-2', time: '2026-11-23 14:10', actor: 'Mariam Al Mansoori', action: 'permission.granted', target: 'Zaid Al Hashimi', reason: 'Assigned inventory.view permission' },
  { id: 'al-3', time: '2026-11-22 18:20', actor: 'Owner Administrator', action: 'period.close_rehearsal', target: 'Period 2026-10', reason: 'Reconciliation dry run complete' },
];

export function EmployeesPage() {
  const { locale } = useI18n();
  const [employees, setEmployees] = useState<Employee[]>(mockEmployees);
  const [activeTab, setActiveTab] = useState<'roster' | 'audit'>('roster');
  const [showAddModal, setShowAddModal] = useState(false);

  // New employee state
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [role, setRole] = useState('Barista');
  const [selectedBranch, setSelectedBranch] = useState('Dubai Flagship');

  const toggleStatus = (id: string) => {
    setEmployees((prev) =>
      prev.map((e) => (e.id === id ? { ...e, isActive: !e.isActive } : e))
    );
  };

  const handleAddEmployee = (e: React.FormEvent) => {
    e.preventDefault();
    const newEmp: Employee = {
      id: `emp-${Date.now()}`,
      name,
      email,
      role,
      isTenantAdmin: false,
      branches: [selectedBranch],
      permissions: ['pos.use', 'kitchen.view'],
      isActive: true,
    };
    setEmployees([...employees, newEmp]);
    setShowAddModal(false);
    setName('');
    setEmail('');
  };

  return (
    <div className="employees-page">
      <div className="page-header">
        <div>
          <h2>{locale === 'ar' ? 'فريق العمل والصلاحيات (RBAC)' : 'Team & Branch Permissions (RBAC)'}</h2>
          <p className="page-subtitle">
            {locale === 'ar'
              ? 'إدارة تعيين الفروع، الصلاحيات المحددة، وسجل تدقيق تجاوزات الإدارة'
              : 'Multi-branch access governance, deny-by-default capabilities, and audited administrative overrides'}
          </p>
        </div>
        <div className="header-actions">
          <button className="btn-primary" onClick={() => setShowAddModal(true)}>
            <Plus size={16} />
            <span>{locale === 'ar' ? 'إضافة موظف جديد' : 'Add Employee'}</span>
          </button>
        </div>
      </div>

      <div className="accounting-tabs">
        <button
          className={`tab-btn ${activeTab === 'roster' ? 'active' : ''}`}
          onClick={() => setActiveTab('roster')}
        >
          <Users size={16} />
          <span>{locale === 'ar' ? 'قائمة الموظفين والفروع' : 'Staff & Branch Assignments'}</span>
        </button>
        <button
          className={`tab-btn ${activeTab === 'audit' ? 'active' : ''}`}
          onClick={() => setActiveTab('audit')}
        >
          <ShieldAlert size={16} />
          <span>{locale === 'ar' ? 'سجل تدقيق الأمان والتجاوزات' : 'Security & Override Audit Trail'}</span>
        </button>
      </div>

      {activeTab === 'roster' && (
        <div className="employees-grid">
          {employees.map((emp) => (
            <div key={emp.id} className={`employee-card ${!emp.isActive ? 'card-disabled' : ''}`}>
              <div className="emp-card-header">
                <div className="emp-avatar">
                  {emp.name.split(' ').map((n) => n[0]).join('').substring(0, 2).toUpperCase()}
                </div>
                <div className="emp-details">
                  <div className="emp-name-row">
                    <strong>{emp.name}</strong>
                    {emp.isTenantAdmin && (
                      <span className="admin-badge">
                        <Shield size={12} /> {locale === 'ar' ? 'مدير مستأجر' : 'Tenant Admin'}
                      </span>
                    )}
                  </div>
                  <span className="emp-email">{emp.email}</span>
                </div>
                <span className={`status-pill ${emp.isActive ? 'status-active' : 'status-inactive'}`}>
                  {emp.isActive ? (locale === 'ar' ? 'نشط' : 'Active') : (locale === 'ar' ? 'معطّل' : 'Suspended')}
                </span>
              </div>

              <div className="emp-section">
                <span className="section-label">{locale === 'ar' ? 'المسمى والدور:' : 'Role:'}</span>
                <span className="role-tag">{emp.role}</span>
              </div>

              <div className="emp-section">
                <span className="section-label">{locale === 'ar' ? 'الفروع المصرح بها:' : 'Assigned Branches:'}</span>
                <div className="branches-list">
                  {emp.branches.map((b, i) => (
                    <span key={i} className="branch-tag">📍 {b}</span>
                  ))}
                </div>
              </div>

              <div className="emp-section">
                <span className="section-label">{locale === 'ar' ? 'الصلاحيات النشطة:' : 'Capabilities:'}</span>
                <div className="perms-list">
                  {emp.permissions.map((p, i) => (
                    <span key={i} className="perm-tag"><KeyRound size={11} /> {p}</span>
                  ))}
                </div>
              </div>

              <div className="emp-footer">
                <button
                  className={`btn-toggle-status ${emp.isActive ? 'btn-suspend' : 'btn-activate'}`}
                  onClick={() => toggleStatus(emp.id)}
                >
                  {emp.isActive ? (
                    <>
                      <X size={14} />
                      <span>{locale === 'ar' ? 'تعطيل الحساب' : 'Suspend Account'}</span>
                    </>
                  ) : (
                    <>
                      <UserCheck size={14} />
                      <span>{locale === 'ar' ? 'تفعيل الحساب' : 'Activate Account'}</span>
                    </>
                  )}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {activeTab === 'audit' && (
        <div className="audit-trail-container">
          <div className="audit-header-banner">
            <ShieldCheck size={20} className="text-primary" />
            <p>
              {locale === 'ar'
                ? 'سجل غير قابل للتعديل يتم تسجيله تلقائياً لتوثيق أي تجاوز للفرع من قبل مديري المستأجر أو تعديل للصلاحيات (معالجة لـ SEC-007).'
                : 'Append-only audit trail logging administrative branch overrides and privilege alterations (remediates SEC-007).'}
            </p>
          </div>

          <table className="data-table">
            <thead>
              <tr>
                <th>{locale === 'ar' ? 'التوقيت' : 'Timestamp'}</th>
                <th>{locale === 'ar' ? 'المستخدم الفاعل' : 'Actor'}</th>
                <th>{locale === 'ar' ? 'الإجراء المسجل' : 'Action'}</th>
                <th>{locale === 'ar' ? 'الهدف / الفرع' : 'Target'}</th>
                <th>{locale === 'ar' ? 'سبب التجاوز والتوثيق' : 'Reason / Note'}</th>
              </tr>
            </thead>
            <tbody>
              {mockAuditLogs.map((log) => (
                <tr key={log.id}>
                  <td><code>{log.time}</code></td>
                  <td><strong>{log.actor}</strong></td>
                  <td><span className="action-tag">{log.action}</span></td>
                  <td>{log.target}</td>
                  <td><span className="text-muted">{log.reason}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {showAddModal && (
        <div className="modal-backdrop">
          <div className="modal-content">
            <h3>{locale === 'ar' ? 'إضافة موظف وتخصيص الفرع' : 'Add Employee & Assign Branch'}</h3>
            <form onSubmit={handleAddEmployee}>
              <div className="form-group">
                <label>{locale === 'ar' ? 'الاسم الكامل' : 'Full Name'}</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Sultan Al Nuaimi"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label>{locale === 'ar' ? 'البريد الإلكتروني المهني' : 'Work Email'}</label>
                <input
                  type="email"
                  required
                  placeholder="sultan@no8.ae"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              <div className="form-group">
                <label>{locale === 'ar' ? 'المسمى الوظيفي' : 'Role'}</label>
                <select value={role} onChange={(e) => setRole(e.target.value)}>
                  <option value="Barista">Barista (باريستا)</option>
                  <option value="Cashier">Cashier (كاشير)</option>
                  <option value="Chef">Chef (شيف مطبخ)</option>
                  <option value="Branch Manager">Branch Manager (مدير فرع)</option>
                  <option value="Accountant">Accountant (محاسب)</option>
                </select>
              </div>

              <div className="form-group">
                <label>{locale === 'ar' ? 'تعيين الفرع المصرح' : 'Assigned Branch'}</label>
                <select value={selectedBranch} onChange={(e) => setSelectedBranch(e.target.value)}>
                  <option value="Dubai Flagship">Dubai Flagship (الفرع الرئيسي - دبي)</option>
                  <option value="Abu Dhabi Branch">Abu Dhabi Branch (فرع أبوظبي)</option>
                </select>
              </div>

              <div className="modal-actions">
                <button type="button" className="btn-secondary" onClick={() => setShowAddModal(false)}>
                  {locale === 'ar' ? 'إلغاء' : 'Cancel'}
                </button>
                <button type="submit" className="btn-primary">
                  {locale === 'ar' ? 'حفظ وتعيين الصلاحيات' : 'Save & Assign'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
