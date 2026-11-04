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
    <title>NUMBER EIGHT — Customers & Loyalty | العملاء والجوائز</title>
    
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

        .progress-bar {
            width: 100%;
            background-color: var(--border);
            border-radius: 8px;
            overflow: hidden;
            height: 8px;
            margin-top: 6px;
        }

        .progress-fill {
            height: 100%;
            background-color: var(--gold);
        }

        .reward-ready {
            color: var(--green);
            font-weight: 800;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
    </style>
</head>
<body>

    <header>
        <div class="brand-logo">
            <img src="/images/logo.png" width="48" height="48" style="background: #FFFFFF; border-radius: 50%; padding: 2px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); object-fit: contain;" alt="Number Eight Logo">
            <div>
                <h1 style="font-size: 18px; font-weight: 800;" data-i18n="customers_title">سجل العملاء والجوائز</h1>
                <p style="font-size: 11px; color: var(--secondary); font-family: 'DM Sans', sans-serif; font-weight: 700;">CUSTOMER LOYALTY PROGRAM</p>
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
                    <h2 class="section-title" data-i18n="cust_card_title">بيانات العملاء وبرنامج الولاء</h2>
                    <p style="font-size: 12px; color: var(--secondary);" data-i18n="cust_card_sub">كوب مجاني لكل 8 أكواب - هنا يمكنك تتبع استهلاك العملاء</p>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th data-i18n="th_cust_name">الاسم</th>
                        <th data-i18n="th_cust_phone">رقم الهاتف</th>
                        <th data-i18n="th_cust_orders">إجمالي الطلبات (المدفوعة)</th>
                        <th data-i18n="th_cust_cups">إجمالي الأكواب</th>
                        <th data-i18n="th_cust_remaining">المتبقي للكوب المجاني</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($customers as $customer)
                        <tr>
                            <td style="font-weight: 700;">{{ $customer->name ?? ($currentLang === 'en' ? 'Customer' : 'عميل') }}</td>
                            <td style="font-family: 'DM Sans', sans-serif;">{{ $customer->phone }}</td>
                            <td>
                                <span style="font-family: 'DM Sans', sans-serif;">{{ $customer->orders_count }}</span> 
                                <span data-i18n="unit_orders">طلب</span>
                            </td>
                            <td>
                                <div style="font-weight: 800; color: var(--primary);">
                                    <span style="font-family: 'DM Sans', sans-serif;">{{ $customer->total_cups }}</span> 
                                    <span data-i18n="unit_cups">كوب</span>
                                </div>
                            </td>
                            <td>
                                @if($customer->cups_remaining == 0 && $customer->total_cups > 0)
                                    <div class="reward-ready" data-i18n="reward_ready_badge">
                                        🎁 يستحق كوب مجاني الآن!
                                    </div>
                                    <div class="progress-bar">
                                        <div class="progress-fill" style="width: 100%;"></div>
                                    </div>
                                @else
                                    <div style="font-weight: 700;">
                                        <span data-i18n="cups_remaining_prefix">باقي</span> 
                                        <span style="font-family: 'DM Sans', sans-serif;">{{ $customer->cups_remaining }}</span> 
                                        <span data-i18n="cups_remaining_suffix">أكواب</span>
                                    </div>
                                    <div class="progress-bar">
                                        @php
                                            $progress = ((8 - $customer->cups_remaining) / 8) * 100;
                                        @endphp
                                        <div class="progress-fill" style="width: {{ $progress }}%;"></div>
                                    </div>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" style="text-align: center; color: var(--secondary);" data-i18n="no_customers_yet">لا يوجد عملاء مسجلين حتى الآن</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>
</body>
</html>