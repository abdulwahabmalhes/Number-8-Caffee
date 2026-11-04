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
    <title>NUMBER EIGHT — Orders History | سجل الطلبات والفواتير</title>
    
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

        .section-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 24px;
            margin-bottom: 24px;
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
        th, td { padding: 14px 14px; text-align: start; border-bottom: 1px solid var(--border); font-size: 14px; }
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

        .btn-secondary { background: var(--bg); color: var(--primary); border: 1px solid var(--border); }
        .btn-danger { background: #fee2e2; color: #dc2626; }

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
    </style>
</head>
<body>

    <header>
        <div class="brand-logo">
            <img src="/images/logo.png" width="48" height="48" style="background: #FFFFFF; border-radius: 50%; padding: 2px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); object-fit: contain;" alt="Number Eight Logo">
            <div>
                <h1 style="font-size: 18px; font-weight: 800;" data-i18n="orders_title">سجل الطلبات والفواتير كاملة</h1>
                <p style="font-size: 11px; color: var(--secondary); font-family: 'DM Sans', sans-serif; font-weight: 700;">ALL INVOICES & ORDERS HISTORY</p>
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

            <button onclick="window.location.href='/manager/reports'" class="btn btn-secondary" data-i18n="nav_reports">
                تقارير المبيعات 📊
            </button>
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
        <div class="section-card">
            <div class="section-header">
                <div>
                    <h2 class="section-title" data-i18n="orders_card_title">سجل الطلبات</h2>
                    <p style="font-size: 12px; color: var(--secondary);" data-i18n="orders_card_sub">عرض جميع الطلبات مع تفاصيل العميل، الدفع، والنوع</p>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th data-i18n="th_order_num">رقم الطلب</th>
                        <th data-i18n="th_date_time">التاريخ والوقت</th>
                        <th data-i18n="th_customer">العميل</th>
                        <th data-i18n="th_order_type">نوع الطلب</th>
                        <th data-i18n="th_total_amount">المبلغ الإجمالي</th>
                        <th data-i18n="th_payment_status">حالة الدفع</th>
                        <th data-i18n="th_items">المنتجات</th>
                        <th data-i18n="th_print_actions">إجراءات الطباعة</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($orders as $order)
                        <tr>
                            <td style="font-weight: 800; font-family: 'DM Sans', sans-serif;">{{ $order->order_number ?: '#' . $order->id }}</td>
                            <td style="font-family: 'DM Sans', sans-serif; color: var(--secondary); font-size: 13px;">
                                {{ $order->created_at->format('Y-m-d H:i') }}
                            </td>
                            <td>
                                @if($order->customer)
                                    <div style="font-weight: 700;">{{ $order->customer->name ?? 'User' }}</div>
                                    <div style="font-size: 12px; color: var(--secondary); font-family: 'DM Sans', sans-serif;">{{ $order->customer->phone }}</div>
                                @else
                                    <span style="color: var(--secondary);" data-i18n="guest_customer">زائر (بدون حساب)</span>
                                @endif
                            </td>
                            <td>
                                @if($order->order_type == 'table')
                                    <span class="type-badge">
                                        <span data-i18n="badge_table_prefix">طاولة</span> {{ $order->table ? $order->table->table_number : '?' }}
                                    </span>
                                @elseif($order->order_type == 'car')
                                    <span class="type-badge" data-i18n="badge_car_pickup">استلام بالسيارة 🚗</span>
                                    @if($order->vehicle)
                                        <div style="font-size: 11px; margin-top: 4px; color: var(--secondary);">
                                            {{ $order->vehicle->vehicle_model ?: $order->vehicle->brand }} ({{ $order->vehicle->plate_number }})
                                        </div>
                                    @endif
                                @else
                                    <span class="type-badge" data-i18n="badge_counter_pickup">استلام خارجي (Pickup)</span>
                                @endif
                            </td>
                            <td style="font-family: 'DM Sans', sans-serif; font-weight: 800; white-space: nowrap;">
                                {{ number_format($order->grand_total, 2) }} AED
                            </td>
                            <td>
                                <span class="status-badge {{ $order->payment_status == 'paid' ? 'status-paid' : 'status-unpaid' }}" data-i18n="{{ $order->payment_status == 'paid' ? 'badge_paid' : 'badge_unpaid' }}">
                                    {{ $order->payment_status == 'paid' ? ($currentLang === 'en' ? 'Paid' : 'مدفوع') : ($currentLang === 'en' ? 'Unpaid' : 'غير مدفوع') }}
                                </span>
                            </td>
                            <td>
                                <div style="font-size: 12px; line-height: 1.5; color: var(--secondary);">
                                    @foreach($order->items as $item)
                                        <div>
                                            <span style="font-family: 'DM Sans', sans-serif;">{{ $item->quantity }}x</span> 
                                            <span data-en="{{ $item->product ? $item->product->name_en : 'Product' }}" data-ar="{{ $item->product ? ($item->product->name_ar ?: $item->product->name_en) : 'منتج' }}">
                                                {{ $item->product ? ($currentLang === 'en' ? $item->product->name_en : ($item->product->name_ar ?: $item->product->name_en)) : 'Product' }}
                                            </span>
                                        </div>
                                    @endforeach
                                </div>
                            </td>
                            <td>
                                <div style="display: flex; gap: 6px;">
                                    <button class="btn btn-secondary" style="padding: 5px 8px; font-size: 12px;" onclick="window.open('/operations/orders/{{ $order->id }}/sticker', '_blank', 'width=420,height=600')" data-i18n="sticker">
                                        ستيكر 🏷️
                                    </button>
                                    <button class="btn btn-secondary" style="padding: 5px 8px; font-size: 12px;" onclick="window.open('/operations/orders/{{ $order->id }}/receipt', '_blank', 'width=450,height=700')" data-i18n="receipt">
                                        فاتورة 🧾
                                    </button>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" style="text-align: center; color: var(--secondary);" data-i18n="no_orders_yet">لا توجد طلبات حتى الآن</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
            
            <div style="margin-top: 20px;">
                {{ $orders->links() }}
            </div>
        </div>
    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>
</body>
</html>