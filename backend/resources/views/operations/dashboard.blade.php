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
    <title>NUMBER EIGHT — Operations Hub | لوحة التشغيل</title>
    
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

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html[dir="rtl"] body,
        html[dir="rtl"] * {
            font-family: 'Tajawal', sans-serif;
        }

        html[dir="ltr"] body,
        html[dir="ltr"] * {
            font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        body {
            background-color: var(--bg);
            color: var(--primary);
            min-height: 100vh;
        }

        /* Top Header */
        header {
            background: #FFFFFF;
            border-bottom: 1px solid var(--border);
            padding: 14px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .brand-logo {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .brand-title h1 {
            font-size: 17px;
            font-weight: 800;
            letter-spacing: 1px;
            font-family: 'DM Sans', sans-serif;
        }

        .brand-title p {
            font-size: 11px;
            color: var(--secondary);
            font-family: 'DM Sans', sans-serif;
            letter-spacing: 1.5px;
            font-weight: 700;
        }

        .status-indicators {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
        }

        .live-chip {
            display: flex;
            align-items: center;
            gap: 8px;
            background: #E8F5E9;
            color: var(--green);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
        }

        .pulse-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--green);
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(0.95); opacity: 0.7; }
            50% { transform: scale(1.3); opacity: 1; }
            100% { transform: scale(0.95); opacity: 0.7; }
        }

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
        .tabs-nav {
            padding: 16px 28px;
            display: flex;
            gap: 12px;
            background: #FFFFFF;
            border-bottom: 1px solid var(--border);
            overflow-x: auto;
        }

        .tab-btn {
            padding: 10px 20px;
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
            white-space: nowrap;
        }

        .tab-btn.active {
            background: var(--primary);
            color: #FFFFFF;
            border-color: var(--primary);
        }

        .tab-badge {
            background: rgba(255,255,255,0.2);
            color: inherit;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-family: 'DM Sans', sans-serif;
            font-weight: 700;
        }

        .tab-btn:not(.active) .tab-badge {
            background: var(--bg);
            color: var(--secondary);
            border: 1px solid var(--border);
        }

        /* Container */
        .container {
            padding: 24px 28px;
            max-width: 1440px;
            margin: 0 auto;
        }

        /* Grid */
        .orders-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(340px, 1fr));
            gap: 20px;
        }

        /* Order Card */
        .order-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 20px;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.02);
            transition: transform 0.2s;
        }

        .order-card.arrived {
            border: 2px solid var(--green);
            background: #FAFFF9;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
        }

        .order-num {
            font-family: 'DM Sans', sans-serif;
            font-weight: 800;
            font-size: 18px;
        }

        .order-type-chip {
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 11px;
            font-weight: 700;
            border: 1px solid var(--border);
            background: var(--bg);
        }

        .type-car { background: #FFF8E1; color: #8D6E63; border-color: #FFE082; }
        .type-table { background: #E3F2FD; color: #1565C0; border-color: #BBDEFB; }

        .meta-row {
            display: flex;
            gap: 10px;
            font-size: 12px;
            color: var(--secondary);
            align-items: center;
        }

        .vehicle-box {
            background: #F4F3EE;
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 13px;
            font-weight: 600;
        }

        .items-list {
            border-top: 1px dashed var(--border);
            border-bottom: 1px dashed var(--border);
            padding: 12px 0;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .item-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            font-size: 13px;
            gap: 8px;
        }

        .item-name {
            font-weight: 700;
            line-height: 1.3;
        }

        .item-notes {
            font-size: 11px;
            color: var(--secondary);
            margin-top: 2px;
            font-style: italic;
        }

        .card-footer {
            display: flex;
            gap: 10px;
            margin-top: auto;
        }

        .btn-action {
            flex: 1;
            padding: 12px;
            border-radius: 12px;
            font-weight: 700;
            font-size: 13px;
            cursor: pointer;
            border: none;
            transition: opacity 0.2s;
            text-align: center;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary);
            color: #FFFFFF;
        }

        .btn-success {
            background: var(--green);
            color: #FFFFFF;
        }

        .btn-secondary {
            background: #F4F3EE;
            color: var(--primary);
            border: 1px solid var(--border);
        }
    </style>
</head>
<body>
    <audio id="audio-new" src="https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3" preload="auto"></audio>
    <audio id="audio-status" src="https://assets.mixkit.co/active_storage/sfx/1054/1054-preview.mp3" preload="auto"></audio>

    <!-- Header -->
    <header>
        <div class="brand-logo">
            <img src="/images/logo.png" width="48" height="48" style="background: #FFFFFF; border-radius: 50%; padding: 2px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); object-fit: contain;" alt="Number Eight Logo">
            <div class="brand-title">
                <h1>NUMBER EIGHT SPECIALTY COFFEE</h1>
                <p data-i18n="ops_subtitle">OPERATIONS & DISPATCH HUB</p>
            </div>
        </div>

        <div class="status-indicators">
            <!-- Language Switcher Pill -->
            <div class="lang-switch-wrap">
                <button type="button" onclick="setN8Language('en')" class="lang-toggle-btn {{ $currentLang === 'en' ? 'active' : '' }}" id="btn-lang-en">
                    <span>🇬🇧 EN</span>
                </button>
                <button type="button" onclick="setN8Language('ar')" class="lang-toggle-btn {{ $currentLang === 'ar' ? 'active' : '' }}" id="btn-lang-ar">
                    <span>🇦🇪 عربي</span>
                </button>
            </div>

            <!-- Live Status Indicator -->
            <div class="live-chip">
                <div class="pulse-dot"></div>
                <span data-i18n="live_status">متصل بالنظام المباشر (Reverb)</span>
            </div>

            @if(Auth::user()->hasRole('Super Admin') || Auth::user()->hasRole('Manager'))
            <button onclick="window.location.href='/manager/reports'" data-i18n="nav_reports" style="padding: 8px 16px; border-radius: 12px; background: #FAF9F6; border: 1px solid var(--border); cursor: pointer; font-weight: 700;">
                تقارير المبيعات 📊
            </button>
            <button onclick="window.location.href='/manager'" data-i18n="manager_portal" style="padding: 8px 16px; border-radius: 12px; background: #FAF9F6; border: 1px solid var(--border); cursor: pointer; font-weight: 700;">
                لوحة الإدارة والمبيعات ➔
            </button>
            @endif

            <form action="/logout" method="POST" style="margin: 0;">
                @csrf
                <button type="submit" data-i18n="logout" style="padding: 8px 14px; border-radius: 12px; background: #fee2e2; color: #dc2626; border: none; cursor: pointer; font-weight: 700;">
                    خروج 🚪
                </button>
            </form>
        </div>
    </header>

    <!-- Operational Mode Tabs -->
    <div class="tabs-nav">
        <button class="tab-btn active" onclick="switchView('all', this)">
            <span data-i18n="tab_all">جميع الطلبات</span>
            <span class="tab-badge" id="badge-all">{{ count($orders) }}</span>
        </button>
        <button class="tab-btn" onclick="switchView('table', this)">
            <span data-i18n="tab_table">طلبات الطاولات</span>
            <span class="tab-badge" id="badge-table">{{ $orders->where('order_type', 'table')->count() }}</span>
        </button>
        <button class="tab-btn" onclick="switchView('car', this)">
            <span data-i18n="tab_car">طلبات السيارات 🚗</span>
            <span class="tab-badge" id="badge-car">{{ $orders->where('order_type', 'car')->count() }}</span>
        </button>
        <button class="tab-btn" onclick="switchView('preparing', this)">
            <span data-i18n="tab_preparing">شاشة الباريستا (KDS)</span>
            <span class="tab-badge" id="badge-preparing">{{ $stats['preparing'] }}</span>
        </button>
        <button class="tab-btn" onclick="switchView('delivered', this)">
            <span data-i18n="tab_delivered">الطلبات المنجزة ✓</span>
            <span class="tab-badge" id="badge-delivered">{{ $stats['delivered'] ?? 0 }}</span>
        </button>
    </div>

    <!-- Main Live Order Board -->
    <div class="container">
        <div class="orders-grid" id="ordersGrid">
            @forelse($orders as $order)
                <div class="order-card {{ $order->customer_arrived_at && $order->status != 'delivered' ? 'arrived' : '' }}" data-type="{{ $order->order_type }}" data-status="{{ $order->status }}">
                    <div class="card-header">
                        <div>
                            <div class="order-num">{{ $order->order_number }}</div>
                            <div class="meta-row" style="margin-top: 4px;">
                                <span style="font-family: 'DM Sans', sans-serif;">{{ $order->created_at->format('H:i A') }}</span>
                                <span>•</span>
                                <span class="payment-status-text" data-payment-status="{{ $order->payment_status }}">
                                    {{ $order->payment_status == 'paid' ? 'مدفوع ✓' : 'دفع عند الكاشير' }}
                                </span>
                            </div>
                        </div>
                        <span class="order-type-chip {{ $order->order_type == 'car' ? 'type-car' : 'type-table' }}">
                            <span class="order-type-label" data-order-type="{{ $order->order_type }}" data-table-num="{{ $order->table ? $order->table->table_number : '08' }}">
                                {{ $order->order_type == 'car' ? 'طلب سيارة 🚗' : 'طاولة #' . ($order->table ? $order->table->table_number : '08') }}
                            </span>
                        </span>
                    </div>

                    @if($order->order_type == 'car')
                        <div class="vehicle-box">
                            <div>
                                <strong><span data-i18n="plate">اللوحة:</span></strong> 
                                <span style="font-family: 'DM Sans', sans-serif;">{{ $order->vehicle ? $order->vehicle->plate_number : '-' }}</span>
                            </div>
                            <div style="font-size: 11px; color: var(--secondary); margin-top: 2px;">
                                {{ $order->vehicle ? ($order->vehicle->vehicle_model . ' • ' . $order->vehicle->vehicle_color) : '-' }}
                            </div>
                            @if($order->customer_arrived_at)
                                <div style="color: var(--green); font-weight: 800; margin-top: 6px;" data-i18n="customer_arrived">
                                    🚨 العميل وصل الآن أمام الكافيه!
                                </div>
                            @endif
                        </div>
                    @endif

                    @if($order->status == 'delivered')
                        <div style="background: #E8F5E9; color: var(--green); padding: 8px; border-radius: 8px; font-size: 12px; font-weight: 700; text-align: center; margin-bottom: -6px;">
                            <span data-i18n="delivered_at">تم التسليم في</span> 
                            <span style="font-family: 'DM Sans', sans-serif;">{{ $order->delivered_at ? \Carbon\Carbon::parse($order->delivered_at)->format('H:i') : '' }}</span>
                            <br>
                            <span data-i18n="order_took">استغرق الطلب:</span> 
                            <span style="font-family: 'DM Sans', sans-serif;">{{ $order->delivered_at ? \Carbon\Carbon::parse($order->created_at)->diffInMinutes($order->delivered_at) : 0 }}</span> 
                            <span data-i18n="minutes">دقيقة</span>
                        </div>
                    @endif

                    <div class="items-list">
                        @forelse($order->items as $item)
                            <div class="item-row">
                                <div>
                                    <div class="item-name">
                                        <span style="font-family: 'DM Sans', sans-serif;">{{ $item->quantity }}x</span> 
                                        <span class="product-name" 
                                              data-en="{{ $item->product ? $item->product->name_en : 'Product' }}" 
                                              data-ar="{{ $item->product ? ($item->product->name_ar ?: $item->product->name_en) : 'منتج' }}">
                                            {{ $item->product ? ($currentLang === 'en' ? $item->product->name_en : ($item->product->name_ar ?: $item->product->name_en)) : 'Product' }}
                                        </span>
                                        <span class="product-name-secondary" 
                                              style="font-size: 11px; color: var(--secondary); font-weight: normal; margin-inline-start: 4px;"
                                              data-en="({{ $item->product ? ($item->product->name_ar ?: '') : '' }})" 
                                              data-ar="({{ $item->product ? ($item->product->name_en ?: '') : '' }})">
                                            @if($item->product)
                                                ({{ $currentLang === 'en' ? $item->product->name_ar : $item->product->name_en }})
                                            @endif
                                        </span>
                                    </div>
                                    @if($item->options && $item->options->count() > 0)
                                        <div style="font-size: 11px; color: #9A7B4F; font-weight: 700; margin-top: 2px;">
                                            @foreach($item->options as $opt)
                                                <span>• {{ $opt->option ? ($currentLang === 'en' ? $opt->option->name_en : $opt->option->name_ar) : '' }}</span>
                                            @endforeach
                                        </div>
                                    @endif
                                    @if($item->special_instructions)
                                        <div class="item-notes">{{ $item->special_instructions }}</div>
                                    @endif
                                </div>
                                <div style="font-family: 'DM Sans', sans-serif; font-weight: 700; white-space: nowrap;">
                                    {{ number_format($item->total_price, 0) }} AED
                                </div>
                            </div>
                        @empty
                            <div class="item-row">
                                <div>
                                    <div class="item-name">1x Spanish Latte (L)</div>
                                    <div class="item-notes">Extra Shot, Oat Milk</div>
                                </div>
                                <div style="font-family: 'DM Sans', sans-serif; font-weight: 700;">24 AED</div>
                            </div>
                        @endforelse
                    </div>

                    <div style="display: flex; justify-content: space-between; font-weight: 800; font-size: 15px;">
                        <span data-i18n="total">الإجمالي:</span>
                        <span style="font-family: 'DM Sans', sans-serif;">{{ number_format($order->grand_total > 0 ? $order->grand_total : 24, 0) }} AED</span>
                    </div>

                    <div class="card-footer" style="flex-wrap: wrap;">
                        <button class="btn-action btn-secondary" style="flex: 1; padding: 10px 8px; font-size: 12px;" onclick="window.open('/operations/orders/{{ $order->id }}/sticker', '_blank', 'width=420,height=600')" data-i18n="sticker">
                            ستيكر 🏷️
                        </button>
                        <button class="btn-action btn-secondary" style="flex: 1; padding: 10px 8px; font-size: 12px;" onclick="window.open('/operations/orders/{{ $order->id }}/receipt', '_blank', 'width=450,height=700')" data-i18n="receipt">
                            فاتورة 🧾
                        </button>
                        @if($order->status == 'new' || $order->status == 'pending')
                            <button class="btn-action btn-primary" style="flex: 2; padding: 10px 12px;" onclick="updateOrderStatus({{ $order->id }}, 'preparing')" data-i18n="btn_accept">
                                قبول وتحضير
                            </button>
                        @elseif($order->status == 'accepted' || $order->status == 'preparing')
                            <button class="btn-action btn-success" style="flex: 2; padding: 10px 12px;" onclick="updateOrderStatus({{ $order->id }}, 'ready')" data-i18n="btn_ready">
                                جاهز للاستلام ✓
                            </button>
                        @elseif($order->status == 'ready')
                            <button class="btn-action btn-primary" style="flex: 2; padding: 10px 12px;" onclick="updateOrderStatus({{ $order->id }}, 'delivered')" data-i18n="btn_deliver">
                                تسليم العميل
                            </button>
                        @else
                            <button class="btn-action btn-secondary" style="flex: 2; padding: 10px 12px;" disabled data-i18n="btn_delivered">
                                تم التسليم ✓
                            </button>
                        @endif
                    </div>
                </div>
            @empty
                <p data-i18n="no_orders" style="color: var(--secondary); text-align: center; grid-column: 1/-1; padding: 40px;">لا توجد طلبات حالية</p>
            @endforelse
        </div>
    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>

    <script>
        function switchView(type, btn) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');

            const cards = document.querySelectorAll('.order-card');
            cards.forEach(c => {
                if (type === 'all') {
                    c.style.display = 'flex';
                } else if (type === 'car' || type === 'table') {
                    c.style.display = c.getAttribute('data-type') === type ? 'flex' : 'none';
                } else if (type === 'preparing') {
                    c.style.display = (c.getAttribute('data-status') === 'preparing' || c.getAttribute('data-status') === 'accepted') ? 'flex' : 'none';
                } else if (type === 'delivered') {
                    c.style.display = (c.getAttribute('data-status') === 'delivered') ? 'flex' : 'none';
                }
            });
        }

        async function updateOrderStatus(orderId, newStatus) {
            try {
                const res = await fetch(`/operations/orders/${orderId}/status`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({ status: newStatus })
                });
                const data = await res.json();
                if (data.success) {
                    location.reload();
                }
            } catch(e) {
                console.error(e);
            }
        }

        // Live Polling Logic
        let lastStats = @json($stats);
        let lastTotal = {{ count($orders) }};
        
        setInterval(async () => {
            try {
                const res = await fetch('/operations/live-feed');
                const data = await res.json();
                
                if (data.success) {
                    let changed = false;
                    
                    if (data.stats.new > lastStats.new || data.orders.length > lastTotal) {
                        document.getElementById('audio-new').play().catch(e => console.log(e));
                        changed = true;
                    } else if (JSON.stringify(data.stats) !== JSON.stringify(lastStats)) {
                        document.getElementById('audio-status').play().catch(e => console.log(e));
                        changed = true;
                    }
                    
                    if (changed) {
                        setTimeout(() => location.reload(), 1500); // Wait for sound, then reload with saved lang
                    }
                }
            } catch(e) {}
        }, 3000);
    </script>
</body>
</html>