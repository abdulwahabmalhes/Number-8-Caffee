import { createContext, useContext, useEffect, useMemo, useState, type PropsWithChildren } from 'react';

type Locale = 'en' | 'ar';
type Messages = Record<string, { en: string; ar: string }>;

const messages: Messages = {
  dashboard: { en: 'Overview', ar: 'نظرة عامة' },
  pos: { en: 'Point of Sale', ar: 'نقطة البيع' },
  inventory: { en: 'Inventory', ar: 'المخزون' },
  reports: { en: 'Reports', ar: 'التقارير' },
  demo: { en: 'DEMO DATA', ar: 'بيانات تجريبية' },
  branch: { en: 'Dubai Flagship', ar: 'فرع دبي الرئيسي' },
};

interface I18nValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: keyof typeof messages) => string;
}

const I18nContext = createContext<I18nValue | null>(null);

export function I18nProvider({ children }: PropsWithChildren) {
  const [locale, setLocale] = useState<Locale>('en');
  useEffect(() => {
    document.documentElement.lang = locale;
    document.documentElement.dir = locale === 'ar' ? 'rtl' : 'ltr';
  }, [locale]);

  const value = useMemo(() => ({ locale, setLocale, t: (key: keyof typeof messages) => messages[key][locale] }), [locale]);
  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export function useI18n() {
  const context = useContext(I18nContext);
  if (!context) throw new Error('I18nProvider is required.');
  return context;
}
