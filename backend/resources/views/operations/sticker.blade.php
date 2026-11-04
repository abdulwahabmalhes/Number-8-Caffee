<!DOCTYPE html>
<html lang="ar">
<head>
    <meta charset="UTF-8">
    <title>ستيكر الأكواب — {{ $order->order_number }}</title>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@500;700;800;900&family=DM+Sans:wght@500;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: #F4F4F0;
            padding: 24px;
            font-family: 'DM Sans', 'Tajawal', sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 20px;
        }

        /* Standard 58mm Cup Sticker Container */
        .sticker-card {
            width: 58mm;
            min-height: 60mm;
            background: #FFFFFF;
            border: 1px solid #E0E0DC;
            border-radius: 14px;
            padding: 10px 12px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-shadow: 0 4px 12px rgba(0,0,0,0.06);
            page-break-after: always;
            position: relative;
            text-align: center;
            color: #111111;
        }

        /* Top Header Row */
        .top-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 11px;
            font-weight: 700;
            color: #333333;
        }

        /* Logo in Center */
        .logo-wrap {
            margin: 2px auto 0;
            display: flex;
            justify-content: center;
        }

        .logo-wrap img {
            width: 38px;
            height: 38px;
            object-fit: contain;
        }

        /* Customer Name */
        .customer-name {
            font-family: 'Tajawal', sans-serif;
            font-size: 18px;
            font-weight: 900;
            color: #000000;
            margin-top: 2px;
            letter-spacing: -0.3px;
        }

        /* Warm Personal Note */
        .warm-quote {
            font-family: 'Tajawal', sans-serif;
            font-size: 12px;
            font-weight: 700;
            color: #222222;
            margin-top: 1px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4px;
        }

        /* Loyalty & Status Badges Row */
        .badges-row {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 10px;
            font-weight: 700;
            margin: 5px 0 6px 0;
            color: #444444;
        }

        .badge-pill {
            display: inline-flex;
            align-items: center;
            gap: 2px;
        }

        /* Product Details */
        .product-section {
            margin: 4px 0 8px 0;
            border-top: 1px dashed #DDDDDD;
            border-bottom: 1px dashed #DDDDDD;
            padding: 6px 0;
        }

        .product-name-en {
            font-size: 13px;
            font-weight: 800;
            color: #000000;
            line-height: 1.2;
        }

        .product-customization {
            font-size: 10.5px;
            font-weight: 500;
            color: #555555;
            margin-top: 2px;
            font-style: italic;
        }

        /* Bottom Row */
        .bottom-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 9.5px;
            font-weight: 700;
            color: #666666;
            padding-top: 2px;
        }

        .brand-signature {
            font-family: 'DM Sans', cursive, sans-serif;
            font-size: 11px;
            font-weight: 900;
            font-style: italic;
            letter-spacing: 0.5px;
            color: #000000;
        }

        /* Print Media Styles */
        @media print {
            body {
                background: none;
                padding: 0;
                gap: 0;
            }

            .sticker-card {
                box-shadow: none;
                border: none;
                width: 100%;
                min-height: auto;
                padding: 6px 8px;
            }

            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>

    <!-- Controls Bar for Screen View -->
    <div class="no-print" style="margin-bottom: 12px; display: flex; gap: 10px; align-items: center;">
        <button onclick="window.print()" style="padding: 10px 22px; background: #000000; color: #FFFFFF; border: none; border-radius: 10px; font-weight: 700; font-size: 14px; cursor: pointer;">
            طباعة الستيكرات ({{ count($stickers) }}) 🖨️ / Print Stickers
        </button>
        <button onclick="window.close()" style="padding: 10px 18px; background: #FFFFFF; color: #333333; border: 1px solid #CCC; border-radius: 10px; font-weight: 700; font-size: 14px; cursor: pointer;">
            إغلاق / Close
        </button>
    </div>

    @foreach($stickers as $sticker)
        <div class="sticker-card">
            <!-- Top Row: Order # & Cup Count -->
            <div class="top-row">
                <span>{{ $order->order_number }}</span>
                <span>{{ $sticker['cup_number'] }} of {{ $sticker['total_cups'] }}</span>
            </div>

            <!-- Logo -->
            <div class="logo-wrap">
                <img src="/images/logo.png" alt="N8 Logo">
            </div>

            <!-- Customer Name -->
            <div class="customer-name">
                {{ $customerName }}
            </div>

            <!-- Warm Greeting Message matching reference photo -->
            <div class="warm-quote">
                حلو إنك هنا 🤍
            </div>

            <!-- Loyalty Badges -->
            <div class="badges-row">
                <span class="badge-pill">⚙ {{ $tier }}</span>
                <span class="badge-pill">☕ {{ $customerOrdersCount }}</span>
                <span class="badge-pill">🎁 {{ $order->grand_total == 0 ? 'Free' : 'N°8' }}</span>
            </div>

            <!-- Product & Instructions -->
            <div class="product-section">
                <div class="product-name-en">{{ $sticker['product_name_en'] }}</div>
                @if(!empty($sticker['special_instructions']))
                    <div class="product-customization">{{ $sticker['special_instructions'] }}</div>
                @else
                    <div class="product-customization">Handcrafted with care</div>
                @endif
            </div>

            <!-- Bottom Row: Sequence ID, Brand, Time -->
            <div class="bottom-row">
                <span>{{ $order->id }}-{{ substr(preg_replace('/[^0-9]/', '', $order->order_number), -4) ?: '1001' }}</span>
                <span class="brand-signature">Number Eight</span>
                <span>{{ $order->created_at->format('h:i A') }}</span>
            </div>
        </div>
    @endforeach

    <script>
        // Auto trigger print dialog on page load
        window.onload = function() {
            setTimeout(function() {
                window.print();
            }, 300);
        };
    </script>
</body>
</html>
