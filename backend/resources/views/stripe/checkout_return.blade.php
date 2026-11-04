<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NUMBER EIGHT - حالة الدفع</title>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@500;700;800;900&family=DM+Sans:wght@700;800&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: 'Tajawal', sans-serif;
            background-color: #0E0E10;
            color: #FFFFFF;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .card {
            background: #18181C;
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 24px;
            padding: 36px 28px;
            max-width: 440px;
            width: 100%;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.5);
        }
        .icon-circle {
            width: 72px;
            height: 72px;
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
        }
        .success-circle {
            background: rgba(34, 197, 94, 0.15);
            border: 2px solid #22c55e;
            color: #22c55e;
        }
        .cancel-circle {
            background: rgba(239, 68, 68, 0.15);
            border: 2px solid #ef4444;
            color: #ef4444;
        }
        .brand {
            font-family: 'DM Sans', sans-serif;
            font-size: 13px;
            letter-spacing: 2px;
            color: #C5A880;
            margin-bottom: 8px;
            font-weight: 700;
        }
        h1 {
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 12px;
            line-height: 1.4;
        }
        p {
            color: #A0A0A5;
            font-size: 14px;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .order-badge-container {
            margin-bottom: 24px;
        }
        .order-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            background: #232328;
            border: 1px solid rgba(197, 168, 128, 0.4);
            color: #FFFFFF;
            padding: 10px 22px;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 700;
        }
        .order-num {
            color: #C5A880;
            font-family: 'DM Sans', sans-serif;
            font-weight: 900;
            font-size: 18px;
            letter-spacing: 1px;
            direction: ltr;
        }
        .btn {
            display: block;
            width: 100%;
            background: #C5A880;
            color: #0E0E10;
            border: none;
            padding: 15px;
            border-radius: 14px;
            font-weight: 800;
            font-size: 15px;
            font-family: 'Tajawal', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
            text-decoration: none;
        }
        .btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }
        .btn:active {
            transform: translateY(1px);
        }
        .hint-text {
            color: #71717A;
            font-size: 12px;
            margin-top: 14px;
            line-height: 1.5;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="brand">NUMBER EIGHT SPECIALTY COFFEE</div>
        
        @if($status === 'success')
            <div class="icon-circle success-circle">✓</div>
            <h1>تم تأكيد الدفع وإرسال الطلب!</h1>
            <p>شكراً لك. تم تأكيد الدفع بنجاح وإرسال طلبك فورياً إلى شاشة الباريستا للبدء بتحضيره.</p>
            
            <div class="order-badge-container">
                <div class="order-badge">
                    <span>رقم الطلب:</span>
                    <span class="order-num">{{ $orderNumber }}</span>
                </div>
            </div>

            <button onclick="returnToApp()" class="btn">العودة للتطبيق لمتابعة الطلب 📱</button>
            <p class="hint-text">إذا لم يعد المتصفح تلقائياً، يمكنك إغلاق هذه الصفحة والرجوع للتطبيق وستجد طلبك قيد التحضير.</p>
        @else
            <div class="icon-circle cancel-circle">✕</div>
            <h1>تم إلغاء عملية الدفع</h1>
            <p>لم يتم خصم أي مبالغ. يمكنك الرجوع للتطبيق والمحاولة مجدداً في أي وقت.</p>
            
            @if(!empty($orderNumber) && $orderNumber !== '#NE----')
                <div class="order-badge-container">
                    <div class="order-badge">
                        <span>الطلب:</span>
                        <span class="order-num">{{ $orderNumber }}</span>
                    </div>
                </div>
            @endif

            <button onclick="returnToApp()" class="btn">العودة للتطبيق</button>
        @endif
    </div>

    <script>
        function returnToApp() {
            var orderNum = encodeURIComponent("{{ $orderNumber }}");
            
            // 1. Try App Custom URL Scheme (Android & iOS)
            window.location.href = "numbereight://order-success?order_number=" + orderNum;
            
            // 2. Try closing the tab/window
            setTimeout(function() {
                try {
                    window.close();
                } catch(e) {}
            }, 500);
        }

        // Auto attempt redirect back to the app on load
        window.addEventListener('DOMContentLoaded', function() {
            setTimeout(function() {
                returnToApp();
            }, 800);
        });
    </script>
</body>
</html>
