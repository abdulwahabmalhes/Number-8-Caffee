<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>طباعة جميع بطاقات الطاولات — NUMBER EIGHT</title>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;700;800&family=DM+Sans:wght@700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Tajawal', sans-serif; }
        body { background: #EFEFEF; padding: 20px; }

        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(110mm, 1fr));
            gap: 20px;
            justify-content: center;
        }

        .table-stand-card {
            width: 110mm;
            height: 150mm;
            background: #FFFFFF;
            border: 2px solid #101010;
            border-radius: 20px;
            padding: 24px 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            text-align: center;
            margin: 0 auto;
            page-break-inside: avoid;
        }

        .n8-badge {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            border: 2px solid #101010;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'DM Sans', sans-serif;
            font-size: 20px;
            font-weight: 800;
        }

        .brand-title { font-size: 15px; font-weight: 800; letter-spacing: 2px; margin-top: 6px; }
        .brand-sub { font-family: 'DM Sans', sans-serif; font-size: 9px; letter-spacing: 3px; color: #77736D; }

        .table-badge {
            background: #101010;
            color: #FFFFFF;
            padding: 4px 20px;
            border-radius: 20px;
            font-size: 16px;
            font-weight: 800;
            margin: 10px 0;
            font-family: 'DM Sans', sans-serif;
        }

        .qr-frame {
            padding: 8px;
            background: #FAF9F6;
            border: 1.5px solid #E8E6E1;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .instructions-ar { font-size: 13px; font-weight: 800; color: #101010; margin-top: 8px; }
        .instructions-en { font-family: 'DM Sans', sans-serif; font-size: 10px; color: #77736D; }

        @media print {
            body { background: none; padding: 0; }
            .cards-grid { display: block; }
            .table-stand-card { margin-bottom: 20mm; box-shadow: none; border: 1.5px solid #000; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>

    <div class="no-print" style="margin-bottom: 20px; text-align: center;">
        <button onclick="window.print()" style="padding: 12px 28px; background: #101010; color: #FFF; border: none; border-radius: 12px; font-weight: bold; font-size: 15px; cursor: pointer;">
            طباعة جميع بطاقات الطاولات 🖨️
        </button>
    </div>

    <div class="cards-grid">
        @foreach($tables as $table)
            <div class="table-stand-card">
                <div>
                    <div style="display: flex; justify-content: center;">
                        <div class="n8-badge">N°8</div>
                    </div>
                    <div class="brand-title">NUMBER EIGHT</div>
                    <div class="brand-sub">SPECIALTY COFFEE</div>
                </div>

                <div>
                    <div class="table-badge">TABLE {{ $table->table_number }}</div>
                </div>

                <div class="qr-frame">
                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data={{ urlencode('https://app.numbereight.ae/order?table=' . $table->table_number . '&token=' . $table->qr_token) }}" width="170" height="170" alt="QR Table {{ $table->table_number }}">
                </div>

                <div>
                    <div class="instructions-ar">امسح الرمز للطلب والدفع من طاولتك</div>
                    <div class="instructions-en">Scan QR code to browse menu & order directly</div>
                </div>
            </div>
        @endforeach
    </div>

</body>
</html>
