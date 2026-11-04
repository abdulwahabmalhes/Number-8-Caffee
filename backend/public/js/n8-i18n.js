/**
 * NUMBER EIGHT SPECIALTY COFFEE — Bilingual Dashboard Localization Engine (AR / EN)
 * Seamless language switcher with instant DOM translation and localStorage/cookie persistence.
 */

const N8_TRANSLATIONS = {
    ar: {
        // Global & Common
        brand_title: "NUMBER EIGHT SPECIALTY COFFEE",
        logout: "خروج 🚪",
        cancel: "إلغاء",
        save: "حفظ",
        delete: "حذف",
        edit: "تعديل",
        back_to_dashboard: "العودة للوحة التحكم ➔",
        confirm_delete_product: "هل أنت متأكد من حذف هذا المنتج؟",
        confirm_delete_table: "حذف الطاولة؟",
        table_prefix: "طاولة",

        // Operations Dashboard (/operations)
        ops_subtitle: "لوحة التشغيل وتوجيه الطلبات",
        live_status: "متصل بالنظام المباشر (Reverb)",
        manager_portal: "لوحة الإدارة والمبيعات ➔",
        tab_all: "جميع الطلبات",
        tab_table: "طلبات الطاولات",
        tab_car: "طلبات السيارات 🚗",
        tab_preparing: "شاشة الباريستا (KDS)",
        tab_delivered: "الطلبات المنجزة ✓",
        paid: "مدفوع ✓",
        pay_cashier: "دفع عند الكاشير",
        order_type_car: "طلب سيارة 🚗",
        order_type_table: "طاولة #",
        plate: "اللوحة:",
        customer_arrived: "🚨 العميل وصل الآن أمام الكافيه!",
        delivered_at: "تم التسليم في",
        order_took: "استغرق الطلب:",
        minutes: "دقيقة",
        total: "الإجمالي:",
        sticker: "ستيكر 🏷️",
        receipt: "فاتورة 🧾",
        btn_accept: "قبول وتحضير",
        btn_ready: "جاهز للاستلام ✓",
        btn_deliver: "تسليم العميل",
        btn_delivered: "تم التسليم ✓",
        no_orders: "لا توجد طلبات حالية",
        new_order_alert: "تم استلام طلب جديد!",

        // Manager Dashboard (/manager)
        mgr_subtitle: "لوحة الإدارة والتحليلات وإدارة القائمة",
        nav_reports: "تقارير المبيعات 📊",
        nav_orders: "سجل الفواتير والطلبات 📜",
        nav_customers: "العملاء والجوائز 🎁",
        nav_operations: "شاشة الكاشير والطلبات ➔",
        nav_print_tables: "طباعة بطاقات الطاولات 🖨️",
        reports_banner_title: "تقارير مبيعات الكافيه (اليومية والشهرية)",
        reports_banner_sub: "تحليلات الأرباح، ساعات الذروة، مبيعات السيارات والطاولات، والأصناف الأكثر طلباً",
        btn_daily_report: "📅 التقرير اليومي",
        btn_monthly_report: "🗓️ التقرير الشهري",
        kpi_sales: "مبيعات اليوم الإجمالية",
        kpi_sales_sub: "+14% عن الأمس",
        kpi_orders: "إجمالي عدد الطلبات",
        kpi_orders_sub: "متوسط 22 دقيقة لكل تحضير",
        kpi_car: "طلبات السيارات 🚗",
        kpi_car_sub: "خدمة الاستلام بالسيارة",
        kpi_table: "طلبات الطاولات بالكافيه",
        kpi_table_sub: "عبر QR Code مشفر",
        menu_title: "إدارة القائمة والمنتجات",
        menu_sub: "إضافة وتعديل وحذف أصناف ومشروبات الكافيه",
        btn_add_category: "+ تصنيف جديد",
        btn_add_product: "+ منتج جديد",
        th_image: "الصورة",
        th_product_name: "اسم المنتج",
        th_category: "التصنيف",
        th_price: "السعر",
        th_status: "الحالة",
        th_actions: "إجراءات",
        status_available: "متوفر",
        status_out: "نفذ",
        btn_disable: "تعطيل",
        btn_enable: "تفعيل",
        btn_edit: "تعديل",
        btn_delete: "حذف",
        qr_section_title: "إدارة رموز QR للطاولات",
        qr_section_sub: "إنشاء وطباعة وتجديد باركود الطاولات",
        btn_add_table: "+ طاولة",
        table_number_label: "طاولة:",
        btn_print: "طباعة 🖨️",
        modal_add_product_title: "إضافة منتج جديد للقائمة",
        label_name_ar: "الاسم بالعربية",
        label_name_en: "الاسم بالإنجليزية",
        label_category: "التصنيف",
        label_price: "السعر (AED)",
        label_image_file: "اختيار صورة من الجهاز / المعرض 📷",
        label_image_url: "أو رابط صورة خارجي (اختياري)",
        btn_save_product: "حفظ المنتج",
        modal_edit_product_title: "تعديل بيانات المنتج",
        label_change_image: "تغيير الصورة من المعرض 📷",
        btn_update_product: "تحديث التعديلات",
        modal_add_table_title: "إضافة طاولة جديدة (أرقام أو أحرف)",
        label_table_number: "اسم أو رقم الطاولة (أرقام أو كتابة)",
        table_number_hint: "يمكنك كتابة رقم أو اسم كتابة بحروف عربية أو إنجليزية",
        btn_save_table: "إضافة وتوليد QR",
        modal_add_category_title: "إضافة تصنيف جديد",
        label_category_ar: "اسم التصنيف بالعربية",
        label_category_en: "اسم التصنيف بالإنجليزية",
        btn_save_category: "إضافة التصنيف",

        // Reports View (/manager/reports)
        reports_header_sub: "تقارير مبيعات وإيرادات الكافيه",
        tab_daily_report: "التقرير اليومي للمبيعات",
        tab_monthly_report: "التقرير الشهري للمبيعات",
        label_select_date: "اختر التاريخ:",
        label_select_month: "اختر الشهر:",
        btn_filter_apply: "عرض التقرير",
        btn_print_report: "طباعة التقرير 🖨️",
        btn_export_csv: "تصدير Excel / CSV 📥",
        kpi_total_day_sales: "إجمالي مبيعات اليوم",
        collected_paid: "المحصل فعلياً:",
        kpi_day_orders: "عدد طلبات اليوم",
        paid_orders_badge: "طلب مدفوع",
        kpi_avg_order: "متوسط قيمة الفاتورة",
        avg_order_sub: "متوسط لكل عميل",
        kpi_vat_amount: "ضريبة القيمة المضافة (5% VAT)",
        net_subtotal: "الصافي:",
        title_sales_by_channel: "توزيع المبيعات حسب نوع الخدمة",
        channel_car: "طلبات السيارات",
        channel_table: "طلبات الطاولات",
        channel_pickup: "استلام خارجي",
        title_sales_by_payment: "طرق الدفع والتحصيل",
        pay_online_apple: "دفع إلكتروني / Apple Pay",
        pay_cashier_pending: "دفع عند الكاشير",
        title_hourly_sales: "ساعات الذروة والمبيعات بالساعة",
        hourly_sales_sub: "تحليل أوقات الذروة لتوزيع دوام الموظفين والباريستا",
        title_top_products: "الأصناف الأكثر طلباً اليوم",
        top_products_sub: "المشروبات والحلويات الأكثر مبيعاً",
        th_product: "الصنف",
        th_qty: "الكمية",
        th_revenue: "الإيراد",
        no_sales_day: "لا توجد مبيعات مسجلة في هذا اليوم",
        title_day_orders: "سجل طلبات اليوم",
        total_orders_label: "طلب مسجل",
        th_order_num: "الطلب",
        th_time: "الوقت",
        th_type: "النوع",
        th_amount: "المبلغ",
        th_status: "الحالة",
        no_orders_found: "لا توجد طلبات في هذا اليوم",
        kpi_month_sales: "إجمالي مبيعات الشهر",
        vs_last_month: "مقارنة بالشهر السابق",
        kpi_month_orders: "إجمالي عدد طلبات الشهر",
        avg_per_day: "بمتوسط",
        orders_per_day: "طلب/يوم",
        kpi_daily_avg_sales: "متوسط المبيعات اليومية",
        daily_avg_sub: "معدل الإيراد اليومي",
        kpi_best_day: "أعلى يوم مبيعات بالشهر",
        title_month_channels: "توزيع مبيعات الشهر حسب الخدمة",
        title_daily_breakdown: "تفصيل المبيعات اليومية خلال الشهر",
        daily_breakdown_sub: "مبيعات كل يوم مع أعداد الطلبات ومبيعات السيارات والطاولات",
        th_date: "التاريخ",
        th_day: "اليوم",
        th_orders_count: "عدد الطلبات",
        th_car_sales: "مبيعات السيارات",
        th_table_sales: "مبيعات الطاولات",
        th_total_sales: "إجمالي اليوم",
        title_month_top_products: "أفضل 10 أصناف مبيعاً خلال الشهر",
        month_top_products_sub: "المنتجات الأكثر طلباً وتحقيقاً للإيراد",
        th_rank: "#",
        th_share: "النسبة من إجمالي المبيعات",
        no_sales_month: "لا توجد مبيعات في هذا الشهر",

        // Orders History (/manager/orders)
        orders_title: "سجل الطلبات والفواتير كاملة",
        orders_sub: "ALL INVOICES & ORDERS HISTORY",
        orders_card_title: "سجل الطلبات",
        orders_card_sub: "عرض جميع الطلبات مع تفاصيل العميل، الدفع، والنوع",
        th_date_time: "التاريخ والوقت",
        th_customer: "العميل",
        th_order_type: "نوع الطلب",
        th_total_amount: "المبلغ الإجمالي",
        th_payment_status: "حالة الدفع",
        th_items: "المنتجات",
        th_print_actions: "إجراءات الطباعة",
        badge_paid: "مدفوع",
        badge_unpaid: "غير مدفوع",
        guest_customer: "زائر (بدون حساب)",
        badge_table_prefix: "طاولة",
        badge_car_pickup: "استلام بالسيارة 🚗",
        badge_counter_pickup: "استلام خارجي (Pickup)",
        no_orders_yet: "لا توجد طلبات حتى الآن",

        // Customers (/manager/customers)
        customers_title: "سجل العملاء والجوائز",
        customers_sub: "CUSTOMER LOYALTY PROGRAM",
        cust_card_title: "بيانات العملاء وبرنامج الولاء",
        cust_card_sub: "كوب مجاني لكل 8 أكواب - هنا يمكنك تتبع استهلاك العملاء",
        th_cust_name: "الاسم",
        th_cust_phone: "رقم الهاتف",
        th_cust_orders: "إجمالي الطلبات (المدفوعة)",
        th_cust_cups: "إجمالي الأكواب",
        th_cust_remaining: "المتبقي للكوب المجاني",
        unspecified: "غير محدد",
        unit_orders: "طلب",
        unit_cups: "كوب",
        reward_ready_badge: "🎁 يستحق كوب مجاني الآن!",
        cups_remaining_prefix: "باقي",
        cups_remaining_suffix: "أكواب",
        no_customers_yet: "لا يوجد عملاء مسجلين حتى الآن",

        // Login (/login)
        login_subtitle: "سجل الدخول للوصول إلى لوحة التحكم",
        login_email: "البريد الإلكتروني",
        login_password: "كلمة المرور",
        login_submit: "تسجيل الدخول",
        placeholder_email: "أدخل بريدك الإلكتروني",
        placeholder_password: "أدخل كلمة المرور"
    },
    en: {
        // Global & Common
        brand_title: "NUMBER EIGHT SPECIALTY COFFEE",
        logout: "Logout 🚪",
        cancel: "Cancel",
        save: "Save",
        delete: "Delete",
        edit: "Edit",
        back_to_dashboard: "Back to Dashboard ➔",
        confirm_delete_product: "Are you sure you want to delete this product?",
        confirm_delete_table: "Delete this table?",
        table_prefix: "Table",

        // Operations Dashboard (/operations)
        ops_subtitle: "OPERATIONS & DISPATCH HUB",
        live_status: "Live System Connected (Reverb)",
        manager_portal: "Manager Portal ➔",
        tab_all: "All Orders",
        tab_table: "Table Orders",
        tab_car: "Car Orders 🚗",
        tab_preparing: "Barista Screen (KDS)",
        tab_delivered: "Completed Orders ✓",
        paid: "Paid ✓",
        pay_cashier: "Pay at Cashier",
        order_type_car: "Car Order 🚗",
        order_type_table: "Table #",
        plate: "Plate:",
        customer_arrived: "🚨 Customer arrived outside cafe!",
        delivered_at: "Delivered at",
        order_took: "Order took:",
        minutes: "min(s)",
        total: "Total:",
        sticker: "Sticker 🏷️",
        receipt: "Receipt 🧾",
        btn_accept: "Accept & Prepare",
        btn_ready: "Ready for Pickup ✓",
        btn_deliver: "Handover Order",
        btn_delivered: "Delivered ✓",
        no_orders: "No active orders currently",
        new_order_alert: "New order received!",

        // Manager Dashboard (/manager)
        mgr_subtitle: "EXECUTIVE MANAGEMENT & MENU CONTROL",
        nav_reports: "Sales Reports 📊",
        nav_orders: "Orders & Invoices 📜",
        nav_customers: "Customers & Loyalty 🎁",
        nav_operations: "Cashier & Orders Screen ➔",
        nav_print_tables: "Print Table Cards 🖨️",
        reports_banner_title: "Cafe Sales Reports (Daily & Monthly)",
        reports_banner_sub: "Detailed analytics on revenue, peak hours, car vs table sales, and bestsellers",
        btn_daily_report: "📅 Daily Report",
        btn_monthly_report: "🗓️ Monthly Report",
        kpi_sales: "Today's Total Sales",
        kpi_sales_sub: "+14% vs yesterday",
        kpi_orders: "Total Orders",
        kpi_orders_sub: "Avg 22 mins per prep",
        kpi_car: "Car Orders 🚗",
        kpi_car_sub: "Curbside Pickup Service",
        kpi_table: "Dine-in Table Orders",
        kpi_table_sub: "Via Encrypted QR Code",
        menu_title: "Menu & Products Management",
        menu_sub: "Add, edit, and delete coffee items & beverages",
        btn_add_category: "+ New Category",
        btn_add_product: "+ New Product",
        th_image: "Image",
        th_product_name: "Product Name",
        th_category: "Category",
        th_price: "Price",
        th_status: "Status",
        th_actions: "Actions",
        status_available: "Available",
        status_out: "Out of Stock",
        btn_disable: "Disable",
        btn_enable: "Enable",
        btn_edit: "Edit",
        btn_delete: "Delete",
        qr_section_title: "Table QR Codes Management",
        qr_section_sub: "Generate, print, and refresh table QR codes",
        btn_add_table: "+ Table",
        table_number_label: "Table:",
        btn_print: "Print 🖨️",
        modal_add_product_title: "Add New Product to Menu",
        label_name_ar: "Arabic Name",
        label_name_en: "English Name",
        label_category: "Category",
        label_price: "Price (AED)",
        label_image_file: "Choose image from device / gallery 📷",
        label_image_url: "Or external image URL (optional)",
        btn_save_product: "Save Product",
        modal_edit_product_title: "Edit Product Details",
        label_change_image: "Change image from gallery 📷",
        btn_update_product: "Update Changes",
        modal_add_table_title: "Add New Table (Name or Number)",
        label_table_number: "Table Name or Number (Text or Digits)",
        table_number_hint: "You can write numbers or names in Arabic/English letters (e.g. VIP 1, Terrace)",
        btn_save_table: "Add & Generate QR",
        modal_add_category_title: "Add New Category",
        label_category_ar: "Category Name (Arabic)",
        label_category_en: "Category Name (English)",
        btn_save_category: "Add Category",

        // Reports View (/manager/reports)
        reports_header_sub: "EXECUTIVE SALES & REVENUE REPORTS",
        tab_daily_report: "Daily Sales Report",
        tab_monthly_report: "Monthly Sales Report",
        label_select_date: "Select Date:",
        label_select_month: "Select Month:",
        btn_filter_apply: "View Report",
        btn_print_report: "Print Report 🖨️",
        btn_export_csv: "Export CSV / Excel 📥",
        kpi_total_day_sales: "Today's Total Sales",
        collected_paid: "Collected / Paid:",
        kpi_day_orders: "Today's Orders",
        paid_orders_badge: "paid orders",
        kpi_avg_order: "Average Order Value",
        avg_order_sub: "Average per customer",
        kpi_vat_amount: "VAT Amount (5%)",
        net_subtotal: "Net Subtotal:",
        title_sales_by_channel: "Sales by Service Type",
        channel_car: "Car Pickup Orders",
        channel_table: "Table Orders",
        channel_pickup: "Takeaway Orders",
        title_sales_by_payment: "Payment Methods Breakdown",
        pay_online_apple: "Online / Apple Pay",
        pay_cashier_pending: "Pay at Cashier",
        title_hourly_sales: "Peak Hours & Hourly Sales",
        hourly_sales_sub: "Analyze busiest hours to schedule barista & staff shifts",
        title_top_products: "Top Selling Items Today",
        top_products_sub: "Best performing beverages and food items",
        th_product: "Product",
        th_qty: "Quantity",
        th_revenue: "Revenue",
        no_sales_day: "No sales recorded for this date",
        title_day_orders: "Today's Orders Log",
        total_orders_label: "registered orders",
        th_order_num: "Order #",
        th_time: "Time",
        th_type: "Type",
        th_amount: "Amount",
        th_status: "Status",
        no_orders_found: "No orders found for this date",
        kpi_month_sales: "Monthly Total Sales",
        vs_last_month: "vs previous month",
        kpi_month_orders: "Monthly Total Orders",
        avg_per_day: "Avg",
        orders_per_day: "orders/day",
        kpi_daily_avg_sales: "Average Daily Sales",
        daily_avg_sub: "Daily revenue run-rate",
        kpi_best_day: "Highest Sales Day",
        title_month_channels: "Monthly Sales Breakdown by Service",
        title_daily_breakdown: "Daily Sales Breakdown of the Month",
        daily_breakdown_sub: "Day-by-day sales including order counts, car & table revenue",
        th_date: "Date",
        th_day: "Day",
        th_orders_count: "Orders Count",
        th_car_sales: "Car Sales",
        th_table_sales: "Table Sales",
        th_total_sales: "Day Total",
        title_month_top_products: "Top 10 Bestselling Products This Month",
        month_top_products_sub: "Most ordered items generating top revenue",
        th_rank: "#",
        th_share: "% Share of Sales",
        no_sales_month: "No sales recorded in this month",

        // Orders History (/manager/orders)
        orders_title: "All Orders & Invoices History",
        orders_sub: "ALL INVOICES & ORDERS HISTORY",
        orders_card_title: "Orders Log",
        orders_card_sub: "View all orders with customer details, payment, and type",
        th_date_time: "Date & Time",
        th_customer: "Customer",
        th_order_type: "Order Type",
        th_total_amount: "Total Amount",
        th_payment_status: "Payment Status",
        th_items: "Products",
        th_print_actions: "Print Actions",
        badge_paid: "Paid",
        badge_unpaid: "Unpaid",
        guest_customer: "Guest (No Account)",
        badge_table_prefix: "Table",
        badge_car_pickup: "Car Pickup 🚗",
        badge_counter_pickup: "Takeaway (Pickup)",
        no_orders_yet: "No orders yet",

        // Customers (/manager/customers)
        customers_title: "Customers & Loyalty Program",
        customers_sub: "CUSTOMER LOYALTY PROGRAM",
        cust_card_title: "Customer Data & Loyalty Program",
        cust_card_sub: "1 Free cup per 8 cups - Track customer loyalty here",
        th_cust_name: "Name",
        th_cust_phone: "Phone Number",
        th_cust_orders: "Total Paid Orders",
        th_cust_cups: "Total Cups",
        th_cust_remaining: "Remaining for Free Cup",
        unspecified: "Not Specified",
        unit_orders: "orders",
        unit_cups: "cups",
        reward_ready_badge: "🎁 Eligible for free cup now!",
        cups_remaining_prefix: "Remaining",
        cups_remaining_suffix: "cup(s)",
        no_customers_yet: "No registered customers yet",

        // Login (/login)
        login_subtitle: "Sign in to access your dashboard",
        login_email: "Email Address",
        login_password: "Password",
        login_submit: "Sign In",
        placeholder_email: "Enter your email",
        placeholder_password: "Enter your password"
    }
};

/**
 * Get current active language ('ar' or 'en')
 */
function getN8Language() {
    let lang = localStorage.getItem('n8_lang');
    if (!lang) {
        const match = document.cookie.match(/(^|;)\s*n8_lang\s*=\s*([^;]+)/);
        lang = match ? match[2] : 'ar';
    }
    return (lang === 'en') ? 'en' : 'ar';
}

/**
 * Set active language with persistence
 */
function setN8Language(lang) {
    if (lang !== 'ar' && lang !== 'en') lang = 'ar';
    localStorage.setItem('n8_lang', lang);
    document.cookie = `n8_lang=${lang};path=/;max-age=31536000;SameSite=Lax`;
    applyN8Language(lang);
}

/**
 * Apply language to DOM elements
 */
function applyN8Language(lang) {
    if (!lang) lang = getN8Language();
    
    // Set document attributes
    document.documentElement.lang = lang;
    document.documentElement.dir = (lang === 'en') ? 'ltr' : 'rtl';

    // Update switcher buttons state
    const btnAr = document.getElementById('btn-lang-ar');
    const btnEn = document.getElementById('btn-lang-en');
    if (btnAr && btnEn) {
        btnAr.classList.toggle('active', lang === 'ar');
        btnEn.classList.toggle('active', lang === 'en');
    }

    const dict = N8_TRANSLATIONS[lang] || N8_TRANSLATIONS.ar;

    // Translate all elements with data-i18n
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (dict[key] !== undefined) {
            el.textContent = dict[key];
        }
    });

    // Translate HTML elements if specified
    document.querySelectorAll('[data-i18n-html]').forEach(el => {
        const key = el.getAttribute('data-i18n-html');
        if (dict[key] !== undefined) {
            el.innerHTML = dict[key];
        }
    });

    // Translate placeholders
    document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
        const key = el.getAttribute('data-i18n-placeholder');
        if (dict[key] !== undefined) {
            el.placeholder = dict[key];
        }
    });

    // Translate titles / tooltips
    document.querySelectorAll('[data-i18n-title]').forEach(el => {
        const key = el.getAttribute('data-i18n-title');
        if (dict[key] !== undefined) {
            el.title = dict[key];
        }
    });

    // Translate dynamic dual-language attributes (data-en and data-ar)
    document.querySelectorAll('[data-en][data-ar]').forEach(el => {
        const val = el.getAttribute('data-' + lang);
        if (val !== null && val !== '') {
            el.textContent = val;
        }
    });

    // Translate payment status badges
    document.querySelectorAll('.payment-status-text').forEach(el => {
        const status = el.getAttribute('data-payment-status');
        if (status === 'paid') {
            el.textContent = dict.paid;
        } else {
            el.textContent = dict.pay_cashier;
        }
    });

    // Translate order type chip
    document.querySelectorAll('.order-type-label').forEach(el => {
        const type = el.getAttribute('data-order-type');
        const num = el.getAttribute('data-table-num');
        if (type === 'car') {
            el.textContent = dict.order_type_car;
        } else if (type === 'table') {
            el.textContent = dict.order_type_table + (num || '08');
        }
    });

    // Dispatch event so any custom page listeners can respond
    window.dispatchEvent(new CustomEvent('n8-language-changed', { detail: { language: lang } }));
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => applyN8Language());
} else {
    applyN8Language();
}
