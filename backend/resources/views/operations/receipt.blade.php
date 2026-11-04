<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <title>فاتورة ضريبية — {{ $order->order_number }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Courier New', Courier, monospace, sans-serif;
        }

        body {
            background: #F0F0F0;
            padding: 20px;
            display: flex;
            justify-content: center;
        }

        .receipt-container {
            width: 80mm;
            background: #FFFFFF;
            padding: 15px 12px;
            border: 1px solid #CCC;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        .center { text-align: center; }
        .bold { font-weight: bold; }
        .divider { border-top: 1px dashed #000; margin: 8px 0; }
        .double-divider { border-top: 2px dashed #000; margin: 8px 0; }

        .logo-text { font-size: 18px; font-weight: 900; letter-spacing: 1px; }
        .sub-text { font-size: 11px; margin-top: 2px; }

        .info-row {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            margin: 3px 0;
        }

        .items-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
            margin: 6px 0;
        }

        .items-table th { text-align: right; border-bottom: 1px solid #000; padding: 4px 0; }
        .items-table td { padding: 4px 0; }

        .qr-code {
            display: flex;
            justify-content: center;
            margin: 10px 0;
        }

        @media print {
            body { background: none; padding: 0; }
            .receipt-container { width: 100%; border: none; box-shadow: none; }
            .no-print { display: none; }
        }
    </style>
</head>
<body>

    <div class="receipt-container">
        <!-- Brand Header -->
        <div class="center">
            <div class="logo-text">NUMBER EIGHT</div>
            <div class="sub-text">SPECIALTY COFFEE — القهوة المختصة</div>
            <div class="sub-text">فرع الخبيصي — العين — الإمارات</div>
            <div class="sub-text">الرقم الضريبي (TRN): 100293847500003</div>
            <div class="divider"></div>
            <div class="bold" style="font-size: 13px;">فاتورة ضريبية مبسطة / TAX INVOICE</div>
        </div>

        <div class="divider"></div>

        <!-- Order Meta -->
        <div class="info-row">
            <span>رقم الطلب / Order:</span>
            <span class="bold">{{ $order->order_number }}</span>
        </div>
        <div class="info-row">
            <span>التاريخ والوقت / Date:</span>
            <span>{{ $order->created_at->format('Y-m-d H:i') }}</span>
        </div>
        <div class="info-row">
            <span>نوع الطلب / Type:</span>
            <span class="bold">
                @if($order->order_type == 'car')
                    سيارة ({{ $order->vehicle ? $order->vehicle->plate_number : '12345 أ ب' }})
                @elseif($order->order_type == 'table')
                    طاولة رقم ({{ $order->table ? $order->table->table_number : '08' }})
                @else
                    استلام من الكاونتر
                @endif
            </span>
        </div>
        <div class="info-row">
            <span>طريقة الدفع / Payment:</span>
            <span>{{ strtoupper($order->payment_method ?? 'APPLE PAY') }} ({{ $order->payment_status == 'paid' ? 'مدفوع' : 'غير مدفوع' }})</span>
        </div>

        <div class="divider"></div>

        <!-- Items Table -->
        <table class="items-table">
            <thead>
                <tr>
                    <th>الصنف / Item</th>
                    <th class="center">الكمية</th>
                    <th style="text-align: left;">السعر</th>
                </tr>
            </thead>
            <tbody>
                @foreach($order->items as $item)
                    <tr>
                        <td>
                            <div class="bold">{{ $item->product ? $item->product->name_en : 'Spanish Latte' }}</div>
                            <div style="font-size: 9px; color: #555;">{{ $item->product ? $item->product->name_ar : 'سبانش لاتيه' }}</div>
                            @if($item->special_instructions)
                                <div style="font-size: 8px; color: #666;">• {{ $item->special_instructions }}</div>
                            @endif
                        </td>
                        <td class="center bold">{{ $item->quantity }}</td>
                        <td style="text-align: left;" class="bold">{{ number_format($item->total_price, 2) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <div class="divider"></div>

        <!-- Financial Totals -->
        <div class="info-row">
            <span>المجموع الفرعي / Subtotal:</span>
            <span>{{ number_format(($order->grand_total / 1.05), 2) }} AED</span>
        </div>
        <div class="info-row">
            <span>ضريبة القيمة المضافة (5% VAT):</span>
            <span>{{ number_format(($order->grand_total - ($order->grand_total / 1.05)), 2) }} AED</span>
        </div>
        <div class="double-divider"></div>
        <div class="info-row" style="font-size: 14px; font-weight: 900;">
            <span>الإجمالي الكلي / TOTAL:</span>
            <span>{{ number_format($order->grand_total, 2) }} AED</span>
        </div>
        <div class="double-divider"></div>

        <!-- QR Code for E-Invoice Verification -->
        <div class="qr-code">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=N8-INVOICE-{{ $order->order_number }}" width="90" height="90" alt="QR Verification">
        </div>

        <div class="center" style="font-size: 10px; margin-top: 8px;">
            <div>شكراً لزيارتكم نمر إيت للقهوة المختصة</div>
            <div>Thank You for Visiting Number Eight</div>
            <div>www.numbereight.ae</div>
        </div>

        <div class="no-print" style="margin-top: 20px; text-align: center;">
            <button onclick="window.print()" style="padding: 10px 20px; background: #101010; color: #FFF; border: none; border-radius: 8px; font-weight: bold; cursor: pointer;">
                طباعة الفاتورة 🖨️ / Print Receipt
            </button>
            <button onclick="window.close()" style="padding: 10px 20px; background: #EEE; color: #333; border: none; border-radius: 8px; font-weight: bold; cursor: pointer; margin-right: 8px;">
                إغلاق / Close
            </button>
        </div>
    </div>

    <script>
        // Auto trigger print dialog on page load
        window.onload = function() {
            setTimeout(function() {
                window.print();
            }, 400);
        };
    </script>
</body>
</html>
