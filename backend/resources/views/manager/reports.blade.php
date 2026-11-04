@php
    $currentLang = request()->cookie('n8_lang', 'ar');
    if (!in_array($currentLang, ['ar', 'en'])) {
        $currentLang = 'ar';
    }
@endphp
<!DOCTYPE html>
<html lang="{{ $currentLang }}" dir="{{ $currentLang === 'en' ? 'ltr' : 'rtl' }}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NUMBER EIGHT — Sales & Revenue Reports | تقارير المبيعات</title>
    
    <!-- Instant Language Initialization (Prevents FOUC/Direction Flash) -->
    <script>
        (function() {
            var lang = localStorage.getItem('n8_lang');
            if (!lang) {
                var m = document.cookie.match(/(^|;)\s*n8_lang\s*=\s*([^;]+)/);
                lang = m ? m[2] : '{{ $currentLang }}';
            }
            if (lang !== 'en' && lang !== 'ar') lang = 'ar';
            document.documentElement.lang = lang;
            document.documentElement.dir = (lang === 'en') ? 'ltr' : 'rtl';
        })();
    </script>

    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&family=DM+Sans:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #101010;
            --bg: #FAF9F6;
            --card: #FFFFFF;
            --border: #E8E6E1;
            --secondary: #77736D;
            --gold: #D8BE95;
            --green: #278A54;
            --red: #C84A4A;
            --blue: #2563EB;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        html[dir="rtl"] body,
        html[dir="rtl"] * {
            font-family: 'Tajawal', sans-serif;
        }

        html[dir="ltr"] body,
        html[dir="ltr"] * {
            font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        body { background-color: var(--bg); color: var(--primary); min-height: 100vh; }

        header {
            background: #FFFFFF;
            border-bottom: 1px solid var(--border);
            padding: 16px 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }

        .brand-logo { display: flex; align-items: center; gap: 14px; }
        
        .container { max-width: 1400px; margin: 28px auto; padding: 0 32px; }

        /* Language Switcher */
        .lang-switch-wrap {
            display: inline-flex;
            align-items: center;
            background: #F4F3EE;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 3px;
            gap: 2px;
        }

        .lang-toggle-btn {
            border: none;
            background: transparent;
            padding: 6px 12px;
            border-radius: 9px;
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
            color: var(--secondary);
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .lang-toggle-btn.active {
            background: #FFFFFF;
            color: var(--primary);
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }

        /* Tabs Bar */
        .report-mode-tabs {
            display: flex;
            gap: 12px;
            margin-bottom: 24px;
        }

        .report-tab {
            padding: 12px 24px;
            border-radius: 14px;
            border: 1px solid var(--border);
            background: #FFFFFF;
            font-weight: 700;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--primary);
        }

        .report-tab.active {
            background: var(--primary);
            color: #FFFFFF;
            border-color: var(--primary);
        }

        /* Filter Controls Card */
        .filter-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 18px 24px;
            margin-bottom: 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }

        .filter-form {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .filter-input {
            padding: 10px 14px;
            border-radius: 12px;
            border: 1px solid var(--border);
            font-size: 14px;
            background: var(--bg);
            font-weight: 600;
            font-family: 'DM Sans', sans-serif;
        }

        /* KPI Cards */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .kpi-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 22px;
            position: relative;
            overflow: hidden;
        }

        .kpi-label { font-size: 13px; color: var(--secondary); font-weight: 600; }
        .kpi-value { font-family: 'DM Sans', sans-serif; font-size: 28px; font-weight: 800; margin-top: 6px; }
        .kpi-sub { font-size: 12px; margin-top: 4px; font-weight: 700; }

        /* Sections Grid */
        .sections-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 24px;
            margin-bottom: 28px;
        }

        @media (max-width: 900px) {
            .sections-grid { grid-template-columns: 1fr; }
        }

        .section-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 28px;
            overflow-x: auto;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 12px;
        }

        .section-title { font-size: 18px; font-weight: 800; }

        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px 14px; text-align: start; border-bottom: 1px solid var(--border); font-size: 13px; }
        th { color: var(--secondary); font-weight: 600; background: var(--bg); }

        .btn {
            padding: 8px 16px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            text-decoration: none;
        }

        .btn-primary { background: var(--primary); color: #FFF; }
        .btn-secondary { background: var(--bg); color: var(--primary); border: 1px solid var(--border); }
        .btn-gold { background: #FAF3E0; color: #8C6D23; border: 1px solid #EEDBB2; }
        .btn-danger { background: #fee2e2; color: #dc2626; }
        .btn-success { background: #E8F5E9; color: var(--green); border: 1px solid #C8E6C9; }

        /* Progress Bar for breakdown */
        .breakdown-row {
            margin-bottom: 16px;
        }
        .breakdown-info {
            display: flex;
            justify-content: space-between;
            font-size: 13px;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .bar-wrap {
            height: 10px;
            background: var(--border);
            border-radius: 6px;
            overflow: hidden;
        }
        .bar-fill {
            height: 100%;
            border-radius: 6px;
        }

        .status-badge {
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 700;
        }
        .status-paid { background: #E8F5E9; color: var(--green); }
        .status-unpaid { background: #FFF5F5; color: var(--red); }

        .type-badge {
            font-size: 12px;
            font-weight: 700;
            color: var(--secondary);
            border: 1px solid var(--border);
            padding: 4px 8px;
            border-radius: 6px;
            display: inline-block;
        }

        /* Printable Sheet */
        @media print {
            body { background: #FFFFFF; color: #000000; }
            header, .report-mode-tabs, .filter-card, .no-print { display: none !important; }
            .container { padding: 0; margin: 0; max-width: 100%; }
            .kpi-card, .section-card { box-shadow: none; border: 1px solid #000; break-inside: avoid; }
            .print-header { display: block !important; margin-bottom: 24px; text-align: center; }
            .print-header h1 { font-size: 20px; font-weight: 900; }
        }
        .print-header { display: none; }
    </style>
</head>
<body>

    <!-- Header -->
    <header>
        <div class="brand-logo">
            <img src="/images/logo.png" width="48" height="48" style="background: #FFFFFF; border-radius: 50%; padding: 2px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); object-fit: contain;" alt="Number Eight Logo">
            <div>
                <h1 style="font-size: 18px; font-weight: 800; font-family: 'DM Sans', sans-serif;">NUMBER EIGHT SPECIALTY COFFEE</h1>
                <p data-i18n="reports_header_sub" style="font-size: 11px; color: var(--secondary); font-family: 'DM Sans', sans-serif; font-weight: 700;">EXECUTIVE SALES & REVENUE REPORTS</p>
            </div>
        </div>

        <div style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
            <!-- Language Switcher Pill -->
            <div class="lang-switch-wrap">
                <button type="button" onclick="setN8Language('en')" class="lang-toggle-btn {{ $currentLang === 'en' ? 'active' : '' }}" id="btn-lang-en">
                    <span>🇬🇧 EN</span>
                </button>
                <button type="button" onclick="setN8Language('ar')" class="lang-toggle-btn {{ $currentLang === 'ar' ? 'active' : '' }}" id="btn-lang-ar">
                    <span>🇦🇪 عربي</span>
                </button>
            </div>

            <button onclick="window.location.href='/manager'" class="btn btn-secondary" data-i18n="back_to_dashboard">
                العودة للوحة التحكم ➔
            </button>
            <form action="/logout" method="POST" style="margin: 0;">
                @csrf
                <button type="submit" class="btn btn-danger" data-i18n="logout" style="padding: 8px 14px; font-weight: 700; cursor: pointer;">
                    خروج 🚪
                </button>
            </form>
        </div>
    </header>

    <div class="container">

        <!-- Print-only Brand Header -->
        <div class="print-header">
            <h1>NUMBER EIGHT SPECIALTY COFFEE</h1>
            <h3>{{ $reportType === 'daily' ? 'DAILY SALES REPORT — ' . $selectedDate : 'MONTHLY SALES REPORT — ' . $selectedMonth }}</h3>
            <p style="font-size: 11px; color: #555;">Printed on {{ now()->format('Y-m-d H:i') }} | Branch: Al Khabisi, Al Ain</p>
            <hr style="margin: 14px 0;">
        </div>

        <!-- Mode Tabs: Daily vs Monthly -->
        <div class="report-mode-tabs">
            <a href="/manager/reports?type=daily&date={{ $selectedDate }}" class="report-tab {{ $reportType === 'daily' ? 'active' : '' }}">
                <span>📅</span>
                <span data-i18n="tab_daily_report">التقرير اليومي للمبيعات</span>
            </a>
            <a href="/manager/reports?type=monthly&month={{ $selectedMonth }}" class="report-tab {{ $reportType === 'monthly' ? 'active' : '' }}">
                <span>🗓️</span>
                <span data-i18n="tab_monthly_report">التقرير الشهري للمبيعات</span>
            </a>
        </div>

        <!-- Filter Controls Bar -->
        <div class="filter-card">
            <form method="GET" action="/manager/reports" class="filter-form">
                <input type="hidden" name="type" value="{{ $reportType }}">
                
                @if($reportType === 'daily')
                    <label style="font-size: 13px; font-weight: 700;" data-i18n="label_select_date">اختر التاريخ:</label>
                    <input type="date" name="date" value="{{ $selectedDate }}" class="filter-input" onchange="this.form.submit()">
                @else
                    <label style="font-size: 13px; font-weight: 700;" data-i18n="label_select_month">اختر الشهر:</label>
                    <input type="month" name="month" value="{{ $selectedMonth }}" class="filter-input" onchange="this.form.submit()">
                @endif

                <button type="submit" class="btn btn-primary" data-i18n="btn_filter_apply">
                    عرض التقرير
                </button>
            </form>

            <div style="display: flex; gap: 8px;">
                <button onclick="window.print()" class="btn btn-secondary" data-i18n="btn_print_report">
                    طباعة التقرير 🖨️
                </button>
                <a href="/manager/reports?type={{ $reportType }}&date={{ $selectedDate }}&month={{ $selectedMonth }}&export=csv" class="btn btn-gold" data-i18n="btn_export_csv">
                    تصدير Excel / CSV 📥
                </a>
            </div>
        </div>

        @if($reportType === 'daily')
            <!-- DAILY REPORT CONTENT -->

            <!-- KPI Cards -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_total_day_sales">إجمالي مبيعات اليوم</div>
                    <div class="kpi-value">{{ number_format($grossSales, 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: var(--green);">
                        <span data-i18n="collected_paid">المحصل فعلياً:</span> {{ number_format($paidSales, 2) }} AED
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_day_orders">عدد طلبات اليوم</div>
                    <div class="kpi-value">{{ $ordersCount }}</div>
                    <div class="kpi-sub" style="color: var(--secondary);">
                        {{ $paidOrdersCount }} <span data-i18n="paid_orders_badge">طلب مدفوع</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_avg_order">متوسط قيمة الفاتورة</div>
                    <div class="kpi-value">{{ number_format($averageOrder, 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: var(--blue);" data-i18n="avg_order_sub">متوسط لكل عميل</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_vat_amount">ضريبة القيمة المضافة (5% VAT)</div>
                    <div class="kpi-value">{{ number_format($vatAmount, 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: var(--secondary);">
                        <span data-i18n="net_subtotal">الصافي:</span> {{ number_format($subtotalAmount, 2) }} AED
                    </div>
                </div>
            </div>

            <!-- Two Breakdown Cards: Channels & Payments -->
            <div class="sections-grid">
                <!-- Card 1: Channel Breakdown -->
                <div class="section-card" style="margin-bottom: 0;">
                    <h3 class="section-title" style="margin-bottom: 18px;" data-i18n="title_sales_by_channel">توزيع المبيعات حسب نوع الخدمة</h3>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🚗 <span data-i18n="channel_car">طلبات السيارات</span> ({{ $channels['car']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['car']['sales'], 2) }} AED ({{ $channels['car']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['car']['percent'] }}%; background: #D8BE95;"></div>
                        </div>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🍽️ <span data-i18n="channel_table">طلبات الطاولات</span> ({{ $channels['table']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['table']['sales'], 2) }} AED ({{ $channels['table']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['table']['percent'] }}%; background: #2563EB;"></div>
                        </div>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🛍️ <span data-i18n="channel_pickup">استلام خارجي</span> ({{ $channels['pickup']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['pickup']['sales'], 2) }} AED ({{ $channels['pickup']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['pickup']['percent'] }}%; background: #101010;"></div>
                        </div>
                    </div>
                </div>

                <!-- Card 2: Payment Methods Breakdown -->
                <div class="section-card" style="margin-bottom: 0;">
                    <h3 class="section-title" style="margin-bottom: 18px;" data-i18n="title_sales_by_payment">طرق الدفع والتحصيل</h3>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>💳 <span data-i18n="pay_online_apple">دفع إلكتروني / Apple Pay</span> ({{ $payments['paid']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($payments['paid']['sales'], 2) }} AED ({{ $payments['paid']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $payments['paid']['percent'] }}%; background: var(--green);"></div>
                        </div>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>💵 <span data-i18n="pay_cashier_pending">دفع عند الكاشير</span> ({{ $payments['pending']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($payments['pending']['sales'], 2) }} AED ({{ $payments['pending']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $payments['pending']['percent'] }}%; background: #F59E0B;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Peak Hours / Hourly Breakdown -->
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h2 class="section-title" data-i18n="title_hourly_sales">ساعات الذروة والمبيعات بالساعة</h2>
                        <p style="font-size: 12px; color: var(--secondary);" data-i18n="hourly_sales_sub">تحليل أوقات الذروة لتوزيع دوام الموظفين والباريستا</p>
                    </div>
                </div>

                <div style="display: flex; gap: 8px; overflow-x: auto; padding-bottom: 10px;">
                    @foreach($hourlyData as $h => $hData)
                        <div style="min-width: 65px; text-align: center; background: {{ $hData['count'] > 0 ? '#FAF3E0' : 'var(--bg)' }}; border: 1px solid var(--border); border-radius: 12px; padding: 10px 4px;">
                            <div style="font-size: 11px; font-weight: 700; color: var(--secondary); font-family: 'DM Sans', sans-serif;">{{ $hData['hour_formatted'] }}</div>
                            <div style="font-size: 16px; font-weight: 800; margin: 4px 0; font-family: 'DM Sans', sans-serif; color: {{ $hData['count'] > 0 ? 'var(--primary)' : '#AAA' }};">{{ $hData['count'] }}</div>
                            <div style="font-size: 10px; font-weight: 700; color: var(--green); font-family: 'DM Sans', sans-serif;">{{ $hData['sales'] > 0 ? number_format($hData['sales'], 0) . ' AED' : '-' }}</div>
                        </div>
                    @endforeach
                </div>
            </div>

            <!-- Top Selling Products & Orders Table -->
            <div class="sections-grid">
                <!-- Top Products Table -->
                <div class="section-card">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title" data-i18n="title_top_products">الأصناف الأكثر طلباً اليوم</h2>
                            <p style="font-size: 12px; color: var(--secondary);" data-i18n="top_products_sub">المشروبات والحلويات الأكثر مبيعاً</p>
                        </div>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th data-i18n="th_product">الصنف</th>
                                <th data-i18n="th_qty">الكمية</th>
                                <th data-i18n="th_revenue">الإيراد</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($topProducts as $prod)
                                <tr>
                                    <td style="font-weight: 700;">
                                        <div style="font-family: 'DM Sans', sans-serif;">{{ $prod['name_en'] }}</div>
                                        <div style="font-size: 11px; color: var(--secondary);">{{ $prod['name_ar'] }}</div>
                                    </td>
                                    <td style="font-family: 'DM Sans', sans-serif; font-weight: 800;">{{ $prod['quantity'] }}</td>
                                    <td style="font-family: 'DM Sans', sans-serif; font-weight: 800; color: var(--green);">{{ number_format($prod['sales'], 2) }} AED</td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="3" style="text-align: center; color: var(--secondary);" data-i18n="no_sales_day">لا توجد مبيعات مسجلة في هذا اليوم</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <!-- Day Orders Summary List -->
                <div class="section-card">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title" data-i18n="title_day_orders">سجل طلبات اليوم</h2>
                            <p style="font-size: 12px; color: var(--secondary);">{{ $ordersCount }} <span data-i18n="total_orders_label">طلب مسجل</span></p>
                        </div>
                    </div>

                    <div style="max-height: 440px; overflow-y: auto;">
                        <table>
                            <thead>
                                <tr>
                                    <th data-i18n="th_order_num">الطلب</th>
                                    <th data-i18n="th_time">الوقت</th>
                                    <th data-i18n="th_type">النوع</th>
                                    <th data-i18n="th_amount">المبلغ</th>
                                    <th data-i18n="th_status">الحالة</th>
                                </tr>
                            </thead>
                            <tbody>
                                @forelse($dailyOrders as $order)
                                    <tr>
                                        <td style="font-family: 'DM Sans', sans-serif; font-weight: 800;">{{ $order->order_number ?: '#' . $order->id }}</td>
                                        <td style="font-family: 'DM Sans', sans-serif; font-size: 12px; color: var(--secondary);">{{ $order->created_at->format('H:i') }}</td>
                                        <td>
                                            @if($order->order_type == 'table')
                                                <span class="type-badge">{{ $order->table ? $order->table->table_number : 'Table' }}</span>
                                            @elseif($order->order_type == 'car')
                                                <span class="type-badge">🚗 {{ $order->vehicle ? $order->vehicle->plate_number : 'Car' }}</span>
                                            @else
                                                <span class="type-badge">Takeaway</span>
                                            @endif
                                        </td>
                                        <td style="font-family: 'DM Sans', sans-serif; font-weight: 800;">{{ number_format($order->grand_total, 2) }}</td>
                                        <td>
                                            <span class="status-badge {{ $order->payment_status == 'paid' ? 'status-paid' : 'status-unpaid' }}">
                                                {{ $order->payment_status == 'paid' ? '✓' : 'Pending' }}
                                            </span>
                                        </td>
                                    </tr>
                                @empty
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--secondary);" data-i18n="no_orders_found">لا توجد طلبات في هذا اليوم</td>
                                    </tr>
                                @endforelse
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        @else
            <!-- MONTHLY REPORT CONTENT -->

            <!-- KPI Cards -->
            <div class="kpi-grid">
                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_month_sales">إجمالي مبيعات الشهر</div>
                    <div class="kpi-value">{{ number_format($grossSales, 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: {{ $growthRate >= 0 ? 'var(--green)' : 'var(--red)' }};">
                        {{ $growthRate >= 0 ? '+' : '' }}{{ $growthRate }}% <span data-i18n="vs_last_month">مقارنة بالشهر السابق</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_month_orders">إجمالي عدد طلبات الشهر</div>
                    <div class="kpi-value">{{ $ordersCount }}</div>
                    <div class="kpi-sub" style="color: var(--secondary);">
                        <span data-i18n="avg_per_day">بمتوسط</span> {{ $ordersCount > 0 ? round($ordersCount / count($dailyBreakdown), 1) : 0 }} <span data-i18n="orders_per_day">طلب/يوم</span>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_daily_avg_sales">متوسط المبيعات اليومية</div>
                    <div class="kpi-value">{{ number_format($averageDailySales, 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: var(--blue);" data-i18n="daily_avg_sub">معدل الإيراد اليومي</div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-label" data-i18n="kpi_best_day">أعلى يوم مبيعات بالشهر</div>
                    <div class="kpi-value">{{ number_format($bestDay['sales'], 2) }} <span style="font-size: 16px;">AED</span></div>
                    <div class="kpi-sub" style="color: var(--gold); font-family: 'DM Sans', sans-serif;">
                        ⭐ {{ $bestDay['date'] }}
                    </div>
                </div>
            </div>

            <!-- Channel Breakdown for Month -->
            <div class="section-card">
                <h3 class="section-title" style="margin-bottom: 18px;" data-i18n="title_month_channels">توزيع مبيعات الشهر حسب الخدمة</h3>

                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;">
                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🚗 <span data-i18n="channel_car">طلبات السيارات</span> ({{ $channels['car']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['car']['sales'], 2) }} AED ({{ $channels['car']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['car']['percent'] }}%; background: #D8BE95;"></div>
                        </div>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🍽️ <span data-i18n="channel_table">طلبات الطاولات</span> ({{ $channels['table']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['table']['sales'], 2) }} AED ({{ $channels['table']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['table']['percent'] }}%; background: #2563EB;"></div>
                        </div>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-info">
                            <span>🛍️ <span data-i18n="channel_pickup">استلام خارجي</span> ({{ $channels['pickup']['count'] }})</span>
                            <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($channels['pickup']['sales'], 2) }} AED ({{ $channels['pickup']['percent'] }}%)</span>
                        </div>
                        <div class="bar-wrap">
                            <div class="bar-fill" style="width: {{ $channels['pickup']['percent'] }}%; background: #101010;"></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Day-by-Day Table of the Month -->
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h2 class="section-title" data-i18n="title_daily_breakdown">تفصيل المبيعات اليومية خلال الشهر</h2>
                        <p style="font-size: 12px; color: var(--secondary);" data-i18n="daily_breakdown_sub">مبيعات كل يوم مع أعداد الطلبات ومبيعات السيارات والطاولات</p>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th data-i18n="th_date">التاريخ</th>
                            <th data-i18n="th_day">اليوم</th>
                            <th data-i18n="th_orders_count">عدد الطلبات</th>
                            <th data-i18n="th_car_sales">مبيعات السيارات</th>
                            <th data-i18n="th_table_sales">مبيعات الطاولات</th>
                            <th data-i18n="th_total_sales">إجمالي اليوم</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($dailyBreakdown as $row)
                            <tr style="{{ $row['sales'] > 0 ? 'background: #FAFFF9;' : '' }}">
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 700;">{{ $row['date'] }}</td>
                                <td>
                                    <span data-en="{{ $row['day_name'] }}" data-ar="{{ $row['day_name_ar'] }}">
                                        {{ $currentLang === 'en' ? $row['day_name'] : $row['day_name_ar'] }}
                                    </span>
                                </td>
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 800;">
                                    {{ $row['orders_count'] > 0 ? $row['orders_count'] : '-' }}
                                </td>
                                <td style="font-family: 'DM Sans', sans-serif;">
                                    {{ $row['car_sales'] > 0 ? number_format($row['car_sales'], 2) . ' AED' : '-' }}
                                </td>
                                <td style="font-family: 'DM Sans', sans-serif;">
                                    {{ $row['table_sales'] > 0 ? number_format($row['table_sales'], 2) . ' AED' : '-' }}
                                </td>
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 800; color: {{ $row['sales'] > 0 ? 'var(--green)' : 'var(--secondary)' }};">
                                    {{ $row['sales'] > 0 ? number_format($row['sales'], 2) . ' AED' : '0.00' }}
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>

            <!-- Top Products of the Month -->
            <div class="section-card">
                <div class="section-header">
                    <div>
                        <h2 class="section-title" data-i18n="title_month_top_products">أفضل 10 أصناف مبيعاً خلال الشهر</h2>
                        <p style="font-size: 12px; color: var(--secondary);" data-i18n="month_top_products_sub">المنتجات الأكثر طلباً وتحقيقاً للإيراد</p>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th data-i18n="th_rank">#</th>
                            <th data-i18n="th_product">الصنف</th>
                            <th data-i18n="th_qty">الكمية المباعة</th>
                            <th data-i18n="th_revenue">إجمالي الإيراد</th>
                            <th data-i18n="th_share">النسبة من إجمالي المبيعات</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($topProducts as $idx => $prod)
                            <tr>
                                <td style="font-weight: 800; font-family: 'DM Sans', sans-serif;">{{ $idx + 1 }}</td>
                                <td style="font-weight: 700;">
                                    <div style="font-family: 'DM Sans', sans-serif;">{{ $prod['name_en'] }}</div>
                                    <div style="font-size: 11px; color: var(--secondary);">{{ $prod['name_ar'] }}</div>
                                </td>
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 800;">{{ $prod['quantity'] }}</td>
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 800; color: var(--green);">{{ number_format($prod['sales'], 2) }} AED</td>
                                <td style="font-family: 'DM Sans', sans-serif; font-weight: 700;">
                                    {{ $grossSales > 0 ? round(($prod['sales'] / $grossSales) * 100, 1) : 0 }}%
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="5" style="text-align: center; color: var(--secondary);" data-i18n="no_sales_month">لا توجد مبيعات في هذا الشهر</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

        @endif

    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>
</body>
</html>

