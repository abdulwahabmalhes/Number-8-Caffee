<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>بطاقة طاولة #{{ $table->table_number }} — NUMBER EIGHT</title>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;700;800&family=DM+Sans:wght@700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Tajawal', sans-serif; }
        body { background: #EFEFEF; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }

        .table-stand-card {
            width: 110mm;
            height: 155mm;
            background: #FFFFFF;
            border: 2px solid #101010;
            border-radius: 20px;
            padding: 30px 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        }

        .n8-badge {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            border: 2px solid #101010;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'DM Sans', sans-serif;
            font-size: 22px;
            font-weight: 800;
        }

        .brand-title {
            font-size: 16px;
            font-weight: 800;
            letter-spacing: 2px;
            margin-top: 8px;
        }

        .brand-sub {
            font-family: 'DM Sans', sans-serif;
            font-size: 10px;
            letter-spacing: 3px;
            color: #77736D;
        }

        .table-badge {
            background: #101010;
            color: #FFFFFF;
            padding: 6px 24px;
            border-radius: 30px;
            font-size: 18px;
            font-weight: 800;
            margin: 14px 0;
            font-family: 'DM Sans', sans-serif;
        }

        .qr-frame {
            padding: 12px;
            background: #FAF9F6;
            border: 1.5px solid #E8E6E1;
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .instructions-ar { font-size: 14px; font-weight: 800; color: #101010; margin-top: 10px; }
        .instructions-en { font-family: 'DM Sans', sans-serif; font-size: 11px; color: #77736D; margin-top: 2px; }

        @media print {
            body { background: none; padding: 0; min-height: auto; }
            .table-stand-card { box-shadow: none; page-break-inside: avoid; border: 1.5px solid #000; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>

    <div>
        <div class="table-stand-card">
            <!-- Top Branding -->
            <div>
                <div style="display: flex; justify-content: center;">
                    <div class="n8-badge">N°8</div>
                </div>
                <div class="brand-title">NUMBER EIGHT</div>
                <div class="brand-sub">SPECIALTY COFFEE</div>
            </div>

            <!-- Table Indicator -->
            <div>
                <div class="table-badge">TABLE {{ $table->table_number }}</div>
            </div>

            <!-- Scannable High-Res QR Code -->
            <div class="qr-frame">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=220x220&data={{ urlencode('https://app.numbereight.ae/order?table=' . $table->table_number . '&token=' . $table->qr_token) }}" width="190" height="190" alt="QR Table {{ $table->table_number }}">
            </div>

            <!-- Instructions -->
            <div>
                <div class="instructions-ar">امسح الرمز للطلب والدفع من طاولتك</div>
                <div class="instructions-en">Scan QR code to browse menu & order directly</div>
            </div>
        </div>

        <div class="no-print" style="margin-top: 20px; text-align: center;">
            <button onclick="window.print()" style="padding: 12px 28px; background: #101010; color: #FFF; border: none; border-radius: 12px; font-weight: bold; font-size: 15px; cursor: pointer;">
                طباعة بطاقة الطاولة 🖨️
            </button>
            <button onclick="window.close()" style="padding: 12px 20px; background: #DDD; color: #333; border: none; border-radius: 12px; font-weight: bold; font-size: 15px; cursor: pointer; margin-right: 8px;">
                إغلاق
            </button>
        </div>
    </div>

</body>
</html>
