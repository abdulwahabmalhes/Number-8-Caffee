<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Support | خدمة العملاء والدعم - NUMBER EIGHT SPECIALTY COFFEE</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,400..700;1,9..40,400..700&family=Tajawal:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #0F0F11;
            --card-bg: #18181C;
            --gold: #C5A880;
            --text-main: #FFFFFF;
            --text-muted: #A0A0A5;
            --border: rgba(255, 255, 255, 0.08);
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            background-color: var(--bg-color);
            color: var(--text-main);
            font-family: 'Tajawal', sans-serif;
            line-height: 1.8;
            padding: 40px 20px;
        }
        .container { max-width: 720px; margin: 0 auto; }
        header {
            text-align: center;
            margin-bottom: 36px;
            padding-bottom: 24px;
            border-bottom: 1px solid var(--border);
        }
        .brand-badge {
            display: inline-block;
            color: var(--gold);
            font-family: 'DM Sans', sans-serif;
            font-weight: 800;
            letter-spacing: 3px;
            font-size: 14px;
            text-transform: uppercase;
            margin-bottom: 12px;
            padding: 6px 16px;
            background: rgba(197, 168, 128, 0.1);
            border-radius: 30px;
            border: 1px solid rgba(197, 168, 128, 0.25);
        }
        h1 { font-size: 26px; font-weight: 800; margin-bottom: 8px; }
        .subtitle { color: var(--text-muted); font-size: 14px; }
        .contact-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 16px;
            margin-bottom: 30px;
        }
        .contact-card {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 24px;
            text-align: center;
            transition: transform 0.2s;
        }
        .contact-card:hover {
            transform: translateY(-2px);
            border-color: rgba(197, 168, 128, 0.4);
        }
        .icon {
            font-size: 32px;
            margin-bottom: 12px;
            display: inline-block;
        }
        .contact-card h3 {
            color: var(--gold);
            font-size: 18px;
            margin-bottom: 6px;
        }
        .contact-card p {
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 14px;
        }
        .btn {
            display: inline-block;
            background: var(--gold);
            color: #000;
            font-weight: 700;
            text-decoration: none;
            padding: 10px 22px;
            border-radius: 12px;
            font-size: 14px;
        }
        footer {
            text-align: center;
            padding-top: 24px;
            color: var(--text-muted);
            font-size: 13px;
            border-top: 1px solid var(--border);
        }
        footer a { color: var(--gold); text-decoration: none; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="brand-badge">NUMBER EIGHT SPECIALTY COFFEE</div>
            <h1>مركز المساعدة والدعم الفني</h1>
            <p class="subtitle">Customer Support & Help Center</p>
        </header>

        <div class="contact-grid">
            <div class="contact-card">
                <div class="icon">💬</div>
                <h3>واتساب المباشر</h3>
                <p>متاحون لخدمتك والرد على استفساراتك بشأن الطلبات والولاء</p>
                <a href="https://wa.me/971500000000" class="btn" target="_blank">تواصل عبر WhatsApp</a>
            </div>

            <div class="contact-card">
                <div class="icon">✉️</div>
                <h3>البريد الإلكتروني</h3>
                <p>للمقترحات والشكاوى والدعم الفني للتطبيق</p>
                <a href="mailto:support@numbereight.ae" class="btn">إرسال بريد إلكتروني</a>
            </div>
        </div>

        <footer>
            <p>&copy; 2026 NUMBER EIGHT SPECIALTY COFFEE. All rights reserved.</p>
            <p style="margin-top: 6px;"><a href="/privacy-policy">سياسة الخصوصية / Privacy Policy</a></p>
        </footer>
    </div>
</body>
</html>
