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
    <title>NUMBER EIGHT — Executive Management | لوحة الإدارة</title>
    
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
        }

        .kpi-label { font-size: 13px; color: var(--secondary); font-weight: 600; }
        .kpi-value { font-family: 'DM Sans', sans-serif; font-size: 28px; font-weight: 800; margin-top: 6px; }
        .kpi-sub { font-size: 12px; color: var(--green); margin-top: 4px; font-weight: 700; }

        /* Sections Grid */
        .sections-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 24px;
        }

        @media (max-width: 992px) {
            .sections-grid {
                grid-template-columns: 1fr;
            }
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
        th, td { padding: 12px 14px; text-align: start; border-bottom: 1px solid var(--border); font-size: 13px; }
        th { color: var(--secondary); font-weight: 600; }

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
        .btn-danger { background: #FFF5F5; color: var(--red); border: 1px solid #FFE0E0; }
        .btn-success { background: #E8F5E9; color: var(--green); border: 1px solid #C8E6C9; }

        .qr-card {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px;
            border: 1px solid var(--border);
            border-radius: 14px;
            margin-bottom: 12px;
            background: #FAFAFA;
        }

        /* Modal styling */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0,0,0,0.5);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }

        .modal-box {
            background: #FFF;
            border-radius: 20px;
            padding: 28px;
            width: 90%;
            max-width: 480px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            font-size: 12px;
            font-weight: 700;
            margin-bottom: 6px;
            color: var(--secondary);
        }

        .form-control {
            width: 100%;
            padding: 12px 14px;
            border-radius: 12px;
            border: 1px solid var(--border);
            font-size: 14px;
            background: var(--bg);
        }

        .alert-success {
            background: #E8F5E9;
            color: var(--green);
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
            font-weight: 700;
        }
    </style>
</head>
<body>

    <header>
        <div class="brand-logo">
            <img src="/images/logo.png" width="48" height="48" style="background: #FFFFFF; border-radius: 50%; padding: 2px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); object-fit: contain;" alt="Number Eight Logo">
            <div>
                <h1 style="font-size: 18px; font-weight: 800; font-family: 'DM Sans', sans-serif;">NUMBER EIGHT SPECIALTY COFFEE</h1>
                <p data-i18n="mgr_subtitle" style="font-size: 11px; color: var(--secondary); font-family: 'DM Sans', sans-serif; font-weight: 700;">EXECUTIVE MANAGEMENT & MENU CONTROL</p>
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
            <button onclick="window.location.href='/manager/orders'" class="btn btn-secondary" data-i18n="nav_orders">
                سجل الفواتير والطلبات 📜
            </button>
            <button onclick="window.location.href='/manager/customers'" class="btn btn-secondary" data-i18n="nav_customers">
                العملاء والجوائز 🎁
            </button>
            <button onclick="window.location.href='/operations'" class="btn btn-secondary" data-i18n="nav_operations">
                شاشة الكاشير والطلبات ➔
            </button>
            <button onclick="window.open('/manager/tables/print-all', '_blank')" class="btn btn-primary" data-i18n="nav_print_tables">
                طباعة بطاقات الطاولات 🖨️
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
        @if(session('success'))
            <div class="alert-success">{{ session('success') }}</div>
        @endif

        <!-- Quick Reports Access Banner -->
        <div style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; background: #FFFFFF; border: 1px solid var(--border); border-radius: 20px; padding: 18px 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.02); flex-wrap: wrap; gap: 14px;">
            <div style="display: flex; align-items: center; gap: 14px;">
                <div style="width: 44px; height: 44px; border-radius: 12px; background: #FFF8E1; display: flex; align-items: center; justify-content: center; font-size: 22px;">📊</div>
                <div>
                    <h3 style="font-size: 16px; font-weight: 800;" data-i18n="reports_banner_title">تقارير مبيعات الكافيه (اليومية والشهرية)</h3>
                    <p style="font-size: 12px; color: var(--secondary);" data-i18n="reports_banner_sub">تحليلات الأرباح، ساعات الذروة، مبيعات السيارات والطاولات، والأصناف الأكثر طلباً</p>
                </div>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <a href="/manager/reports?type=daily" class="btn btn-secondary" style="padding: 10px 18px; font-size: 13px;" data-i18n="btn_daily_report">
                    📅 التقرير اليومي
                </a>
                <a href="/manager/reports?type=monthly" class="btn btn-primary" style="padding: 10px 18px; font-size: 13px;" data-i18n="btn_monthly_report">
                    🗓️ التقرير الشهري
                </a>
            </div>
        </div>

        <!-- KPI Cards -->
        <div class="kpi-grid">
            <div class="kpi-card">
                <div class="kpi-label" data-i18n="kpi_sales">مبيعات اليوم الإجمالية</div>
                <div class="kpi-value">{{ number_format($totalSales > 0 ? $totalSales : 3840, 2) }} AED</div>
                <div class="kpi-sub" data-i18n="kpi_sales_sub">+14% عن الأمس</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label" data-i18n="kpi_orders">إجمالي عدد الطلبات</div>
                <div class="kpi-value">{{ $ordersCount > 0 ? $ordersCount : 84 }}</div>
                <div class="kpi-sub" data-i18n="kpi_orders_sub">متوسط 22 دقيقة لكل تحضير</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label" data-i18n="kpi_car">طلبات السيارات 🚗</div>
                <div class="kpi-value">{{ $carOrdersCount > 0 ? $carOrdersCount : 32 }}</div>
                <div class="kpi-sub" data-i18n="kpi_car_sub">خدمة الاستلام بالسيارة</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label" data-i18n="kpi_table">طلبات الطاولات بالكافيه</div>
                <div class="kpi-value">{{ $tableOrdersCount > 0 ? $tableOrdersCount : 52 }}</div>
                <div class="kpi-sub" data-i18n="kpi_table_sub">عبر QR Code مشفر</div>
            </div>
        </div>

        <div class="sections-grid">
            <!-- Menu Products Management -->
            <div>
                <div class="section-card">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title" data-i18n="menu_title">إدارة القائمة والمنتجات</h2>
                            <p style="font-size: 12px; color: var(--secondary);" data-i18n="menu_sub">إضافة وتعديل وحذف أصناف ومشروبات الكافيه</p>
                        </div>
                        <div style="display: flex; gap: 8px;">
                            <button onclick="openAddCategoryModal()" class="btn btn-secondary" data-i18n="btn_add_category">+ تصنيف جديد</button>
                            <button onclick="openAddProductModal()" class="btn btn-primary" data-i18n="btn_add_product">+ منتج جديد</button>
                        </div>
                    </div>

                    <table>
                        <thead>
                            <tr>
                                <th data-i18n="th_image">الصورة</th>
                                <th data-i18n="th_product_name">اسم المنتج</th>
                                <th data-i18n="th_category">التصنيف</th>
                                <th data-i18n="th_price">السعر</th>
                                <th data-i18n="th_status">الحالة</th>
                                <th data-i18n="th_actions">إجراءات</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($categories as $cat)
                                @foreach($cat->products as $product)
                                    <tr>
                                        <td>
                                            <img src="{{ $product->image ?: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=120&auto=format&fit=crop' }}" width="42" height="42" style="border-radius: 10px; object-fit: cover; border: 1px solid var(--border);" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=120&auto=format&fit=crop';" alt="{{ $product->name_en }}">
                                        </td>
                                        <td style="font-weight: 700;">
                                            <div style="font-family: 'DM Sans', sans-serif; font-size: 14px;">{{ $product->name_en }}</div>
                                            <div style="font-size: 11px; color: var(--secondary);">{{ $product->name_ar }}</div>
                                        </td>
                                        <td>
                                            <span data-en="{{ $cat->name_en }}" data-ar="{{ $cat->name_ar }}">
                                                {{ $currentLang === 'en' ? $cat->name_en : $cat->name_ar }}
                                            </span>
                                        </td>
                                        <td style="font-family: 'DM Sans', sans-serif; font-weight: 700;">{{ number_format($product->price, 0) }} AED</td>
                                        <td>
                                            <span class="product-status-badge" data-available="{{ $product->is_available ? '1' : '0' }}" style="color: {{ $product->is_available ? 'var(--green)' : 'var(--red)' }}; font-weight: 700;">
                                                {{ $product->is_available ? ($currentLang === 'en' ? 'Available' : 'متوفر') : ($currentLang === 'en' ? 'Out of Stock' : 'نفذ') }}
                                            </span>
                                        </td>
                                        <td>
                                            <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                                                <button class="btn btn-secondary" style="padding: 4px 8px;" onclick="toggleStock({{ $product->id }})" data-i18n="{{ $product->is_available ? 'btn_disable' : 'btn_enable' }}">
                                                    {{ $product->is_available ? ($currentLang === 'en' ? 'Disable' : 'تعطيل') : ($currentLang === 'en' ? 'Enable' : 'تفعيل') }}
                                                </button>
                                                <button class="btn btn-secondary" style="padding: 4px 8px;" onclick='openEditProductModal({{ json_encode($product) }})' data-i18n="btn_edit">
                                                    تعديل
                                                </button>
                                                <form action="/manager/products/{{ $product->id }}/delete" method="POST" onsubmit="return confirm(getN8Language() === 'en' ? 'Are you sure you want to delete this product?' : 'هل أنت متأكد من حذف هذا المنتج؟');" style="display: inline;">
                                                    @csrf
                                                    <button type="submit" class="btn btn-danger" style="padding: 4px 8px;" data-i18n="btn_delete">حذف</button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                @endforeach
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Table Cryptographic QR Generator & Management -->
            <div>
                <div class="section-card">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title" data-i18n="qr_section_title">إدارة رموز QR للطاولات</h2>
                            <p style="font-size: 12px; color: var(--secondary);" data-i18n="qr_section_sub">إنشاء وطباعة وتجديد باركود الطاولات</p>
                        </div>
                        <button onclick="openAddTableModal()" class="btn btn-primary" data-i18n="btn_add_table">+ طاولة</button>
                    </div>

                    <div style="max-height: 520px; overflow-y: auto;">
                        @foreach($tables as $table)
                            <div class="qr-card">
                                <div>
                                    <div style="font-weight: 800; font-size: 15px;">
                                        <span data-i18n="table_prefix">طاولة</span> <span style="font-family: 'DM Sans', sans-serif;">{{ $table->table_number }}</span>
                                    </div>
                                    <div style="font-size: 10px; color: var(--secondary); font-family: 'DM Sans', sans-serif;">Token: {{ substr($table->qr_token, 0, 8) }}...</div>
                                </div>
                                <div style="display: flex; gap: 6px;">
                                    <button onclick="window.open('/manager/tables/{{ $table->id }}/print', '_blank')" class="btn btn-secondary" style="padding: 6px 10px;" data-i18n="btn_print">
                                        طباعة 🖨️
                                    </button>
                                    <button onclick="generateQr({{ $table->id }})" class="btn btn-secondary" style="padding: 6px 8px;" title="تجديد الرمز" data-i18n-title="qr_refresh">
                                        ↻
                                    </button>
                                    <form action="/manager/tables/{{ $table->id }}/delete" method="POST" onsubmit="return confirm(getN8Language() === 'en' ? 'Delete this table?' : 'حذف الطاولة؟');" style="display: inline;">
                                        @csrf
                                        <button type="submit" class="btn btn-danger" style="padding: 6px 8px;">×</button>
                                    </form>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>

                <!-- Product Add-ons & Customization Options Management -->
                <div class="section-card" style="margin-top: 20px;">
                    <div class="section-header">
                        <div>
                            <h2 class="section-title">إضافات وخيارات المنتجات (Add-ons)</h2>
                            <p style="font-size: 12px; color: var(--secondary);">أنواع البن، درجة الحرارة، الحليب، التوبينج</p>
                        </div>
                        <button onclick="openAddOptionGroupModal()" class="btn btn-primary" style="padding: 6px 12px;">+ مجموعة</button>
                    </div>

                    <div style="max-height: 480px; overflow-y: auto;">
                        @forelse($optionGroups as $og)
                            <div style="background: var(--bg); border: 1px solid var(--border); border-radius: 14px; padding: 12px; margin-bottom: 12px;">
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <div>
                                        <div style="font-weight: 800; font-size: 14px;">{{ $og->name_en }} / {{ $og->name_ar }}</div>
                                        <div style="font-size: 11px; color: var(--secondary);">
                                            {{ $og->is_multiple ? 'اختيار متعدد (Multiple)' : 'اختيار فردي (Single)' }} 
                                            • {{ $og->is_required ? 'إجباري (Required)' : 'اختياري (Optional)' }}
                                        </div>
                                    </div>
                                    <div style="display: flex; gap: 6px;">
                                        <button onclick="openAddOptionModal({{ $og->id }}, '{{ addslashes($og->name_en) }}')" class="btn btn-secondary" style="padding: 4px 8px; font-size: 11px;">+ خيار</button>
                                        <form action="/manager/option-groups/{{ $og->id }}/delete" method="POST" onsubmit="return confirm('حذف مجموعة الخيارات هذه بالكامل؟');" style="margin: 0;">
                                            @csrf
                                            <button type="submit" class="btn btn-danger" style="padding: 4px 6px; font-size: 11px;">×</button>
                                        </form>
                                    </div>
                                </div>

                                <!-- Options Pills -->
                                <div style="display: flex; flex-wrap: wrap; gap: 6px;">
                                    @foreach($og->options as $opt)
                                        <span style="display: inline-flex; align-items: center; gap: 6px; background: #FFFFFF; border: 1px solid var(--border); padding: 4px 10px; border-radius: 20px; font-size: 12px;">
                                            <span>{{ $opt->name_en }} ({{ $opt->name_ar }})</span>
                                            <strong style="color: var(--gold); font-family: 'DM Sans', sans-serif;">{{ $opt->additional_price > 0 ? '+'.$opt->additional_price.' AED' : 'Free' }}</strong>
                                            <form action="/manager/options/{{ $opt->id }}/delete" method="POST" onsubmit="return confirm('حذف هذا الخيار؟');" style="display: inline; margin: 0;">
                                                @csrf
                                                <button type="submit" style="background: none; border: none; color: var(--red); font-weight: bold; cursor: pointer; padding: 0 2px;">×</button>
                                            </form>
                                        </span>
                                    @endforeach
                                </div>
                            </div>
                        @empty
                            <div style="text-align: center; color: var(--secondary); padding: 20px;">لا توجد مجموعات خيارات مضافة بعد</div>
                        @endforelse
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal 1: Add Product -->
    <div class="modal-overlay" id="addProductModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;" data-i18n="modal_add_product_title">إضافة منتج جديد للقائمة</h3>
            <form action="/manager/products" method="POST" enctype="multipart/form-data">
                @csrf
                <div class="form-group">
                    <label data-i18n="label_name_ar">الاسم بالعربية</label>
                    <input type="text" name="name_ar" class="form-control" placeholder="مثال: فلات وايت بالكراميل" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_name_en">الاسم بالإنجليزية</label>
                    <input type="text" name="name_en" class="form-control" placeholder="e.g. Caramel Flat White" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_category">التصنيف</label>
                    <select name="category_id" class="form-control" required>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name_en }} ({{ $cat->name_ar }})</option>
                        @endforeach
                    </select>
                </div>
                <div class="form-group">
                    <label data-i18n="label_price">السعر (AED)</label>
                    <input type="number" step="0.5" name="price" class="form-control" placeholder="24" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_image_file">اختيار صورة من الجهاز / المعرض 📷</label>
                    <input type="file" name="image_file" class="form-control" accept="image/*" onchange="previewUpload(this, 'add_preview_container', 'add_preview_img')">
                    <div id="add_preview_container" style="display: none; margin-top: 10px;">
                        <img id="add_preview_img" src="" style="width: 100%; height: 120px; object-fit: cover; border-radius: 12px; border: 1px solid var(--border);">
                    </div>
                </div>
                <div class="form-group" style="margin-top: 10px;">
                    <label style="font-size: 12px; color: var(--secondary);" data-i18n="label_image_url">أو رابط صورة خارجي (اختياري)</label>
                    <input type="url" name="image_url" class="form-control" placeholder="https://...">
                </div>

                <div class="form-group" style="margin-top: 14px;">
                    <label style="font-weight: 700;">خيارات وإضافات المنتج (Add-on Groups)</label>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-top: 6px; max-height: 140px; overflow-y: auto; padding: 8px; background: var(--bg); border: 1px solid var(--border); border-radius: 10px;">
                        @foreach($optionGroups as $og)
                            <label style="display: flex; align-items: center; gap: 8px; font-size: 12px; cursor: pointer;">
                                <input type="checkbox" name="option_groups[]" value="{{ $og->id }}">
                                <span>{{ $og->name_en }} ({{ $og->name_ar }})</span>
                            </label>
                        @endforeach
                    </div>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;" data-i18n="btn_save_product">حفظ المنتج</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;" data-i18n="cancel">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 2: Edit Product -->
    <div class="modal-overlay" id="editProductModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;" data-i18n="modal_edit_product_title">تعديل بيانات المنتج</h3>
            <form id="editProductForm" method="POST" enctype="multipart/form-data">
                @csrf
                <div class="form-group">
                    <label data-i18n="label_name_ar">الاسم بالعربية</label>
                    <input type="text" id="edit_name_ar" name="name_ar" class="form-control" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_name_en">الاسم بالإنجليزية</label>
                    <input type="text" id="edit_name_en" name="name_en" class="form-control" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_category">التصنيف</label>
                    <select id="edit_category_id" name="category_id" class="form-control" required>
                        @foreach($categories as $cat)
                            <option value="{{ $cat->id }}">{{ $cat->name_en }} ({{ $cat->name_ar }})</option>
                        @endforeach
                    </select>
                </div>
                <div class="form-group">
                    <label data-i18n="label_price">السعر (AED)</label>
                    <input type="number" step="0.5" id="edit_price" name="price" class="form-control" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_change_image">تغيير الصورة من المعرض 📷</label>
                    <input type="file" name="image_file" class="form-control" accept="image/*" onchange="previewUpload(this, 'edit_preview_container', 'edit_preview_img')">
                    <div id="edit_preview_container" style="margin-top: 10px;">
                        <img id="edit_preview_img" src="" style="width: 100%; height: 120px; object-fit: cover; border-radius: 12px; border: 1px solid var(--border);">
                    </div>
                </div>
                <div class="form-group" style="margin-top: 10px;">
                    <label style="font-size: 12px; color: var(--secondary);" data-i18n="label_image_url">أو رابط صورة (اختياري)</label>
                    <input type="url" id="edit_image_url" name="image_url" class="form-control">
                </div>

                <div class="form-group" style="margin-top: 14px;">
                    <label style="font-weight: 700;">خيارات وإضافات المنتج (Add-on Groups)</label>
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-top: 6px; max-height: 140px; overflow-y: auto; padding: 8px; background: var(--bg); border: 1px solid var(--border); border-radius: 10px;">
                        @foreach($optionGroups as $og)
                            <label style="display: flex; align-items: center; gap: 8px; font-size: 12px; cursor: pointer;">
                                <input type="checkbox" name="option_groups[]" value="{{ $og->id }}" class="edit-og-checkbox" id="edit_og_{{ $og->id }}">
                                <span>{{ $og->name_en }} ({{ $og->name_ar }})</span>
                            </label>
                        @endforeach
                    </div>
                </div>

                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;" data-i18n="btn_update_product">تحديث التعديلات</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;" data-i18n="cancel">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 3: Add Table -->
    <div class="modal-overlay" id="addTableModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;" data-i18n="modal_add_table_title">إضافة طاولة جديدة (أرقام أو أحرف)</h3>
            <form action="/manager/tables" method="POST">
                @csrf
                <div class="form-group">
                    <label data-i18n="label_table_number">اسم أو رقم الطاولة (أرقام أو كتابة)</label>
                    <input type="text" name="table_number" class="form-control" placeholder="مثال: T-01 أو طاولة VIP أو 21" required maxlength="50">
                    <small style="font-size: 11px; color: var(--secondary); margin-top: 4px; display: block;" data-i18n="table_number_hint">يمكنك كتابة رقم أو اسم كتابة بحروف عربية أو إنجليزية</small>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;" data-i18n="btn_save_table">إضافة وتوليد QR</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;" data-i18n="cancel">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 4: Add Category -->
    <div class="modal-overlay" id="addCategoryModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;" data-i18n="modal_add_category_title">إضافة تصنيف جديد</h3>
            <form action="/manager/categories" method="POST">
                @csrf
                <div class="form-group">
                    <label data-i18n="label_category_ar">اسم التصنيف بالعربية</label>
                    <input type="text" name="name_ar" class="form-control" placeholder="مثال: مشروبات صيفية" required>
                </div>
                <div class="form-group">
                    <label data-i18n="label_category_en">اسم التصنيف بالإنجليزية</label>
                    <input type="text" name="name_en" class="form-control" placeholder="e.g. Summer Refreshers" required>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;" data-i18n="btn_save_category">إضافة التصنيف</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;" data-i18n="cancel">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 5: Add Option Group -->
    <div class="modal-overlay" id="addOptionGroupModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;">إضافة مجموعة خيارات جديدة</h3>
            <form action="/manager/option-groups" method="POST">
                @csrf
                <div class="form-group">
                    <label>اسم المجموعة بالعربية</label>
                    <input type="text" name="name_ar" class="form-control" placeholder="مثال: اختيار نوع الحليب" required>
                </div>
                <div class="form-group">
                    <label>اسم المجموعة بالإنجليزية</label>
                    <input type="text" name="name_en" class="form-control" placeholder="e.g. Milk Choice" required>
                </div>
                <div style="display: flex; gap: 20px; margin-top: 15px;">
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="checkbox" name="is_multiple" value="1">
                        <span>اختيار متعدد (Multiple Choice)</span>
                    </label>
                    <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                        <input type="checkbox" name="is_required" value="1">
                        <span>إجباري للاختيار (Required)</span>
                    </label>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;">حفظ المجموعة</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal 6: Add Option to Group -->
    <div class="modal-overlay" id="addOptionModal">
        <div class="modal-box">
            <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 18px;">
                إضافة خيار إلى: <span id="modal_og_title" style="color: var(--gold);"></span>
            </h3>
            <form action="/manager/options" method="POST">
                @csrf
                <input type="hidden" name="option_group_id" id="modal_og_id">
                <div class="form-group">
                    <label>اسم الخيار بالعربية</label>
                    <input type="text" name="name_ar" class="form-control" placeholder="مثال: حليب لوز / كولومبي" required>
                </div>
                <div class="form-group">
                    <label>اسم الخيار بالإنجليزية</label>
                    <input type="text" name="name_en" class="form-control" placeholder="e.g. Almond Milk / Colombian" required>
                </div>
                <div class="form-group">
                    <label>سعر إضافي (AED - 0 إذا مجاني)</label>
                    <input type="number" step="0.5" name="additional_price" class="form-control" value="0" required>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 24px;">
                    <button type="submit" class="btn btn-primary" style="flex: 1; justify-content: center; padding: 12px;">إضافة الخيار</button>
                    <button type="button" onclick="closeModals()" class="btn btn-secondary" style="padding: 12px 20px;">إلغاء</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>

    <script>
        function openAddProductModal() { document.getElementById('addProductModal').style.display = 'flex'; }
        function openAddTableModal() { document.getElementById('addTableModal').style.display = 'flex'; }
        function openAddCategoryModal() { document.getElementById('addCategoryModal').style.display = 'flex'; }
        function openAddOptionGroupModal() { document.getElementById('addOptionGroupModal').style.display = 'flex'; }
        function openAddOptionModal(groupId, groupName) {
            document.getElementById('modal_og_id').value = groupId;
            document.getElementById('modal_og_title').textContent = groupName;
            document.getElementById('addOptionModal').style.display = 'flex';
        }
        function closeModals() {
            document.querySelectorAll('.modal-overlay').forEach(m => m.style.display = 'none');
        }

        function previewUpload(input, containerId, imgId) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    document.getElementById(imgId).src = e.target.result;
                    document.getElementById(containerId).style.display = 'block';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function openEditProductModal(product) {
            document.getElementById('editProductForm').action = `/manager/products/${product.id}/update`;
            document.getElementById('edit_name_ar').value = product.name_ar;
            document.getElementById('edit_name_en').value = product.name_en;
            document.getElementById('edit_category_id').value = product.category_id;
            document.getElementById('edit_price').value = product.price;
            document.getElementById('edit_image_url').value = product.image && !product.image.startsWith('/uploads') ? product.image : '';
            
            const editImg = document.getElementById('edit_preview_img');
            if (product.image) {
                editImg.src = product.image;
                document.getElementById('edit_preview_container').style.display = 'block';
            } else {
                document.getElementById('edit_preview_container').style.display = 'none';
            }

            // Uncheck all option group checkboxes
            document.querySelectorAll('.edit-og-checkbox').forEach(cb => cb.checked = false);
            // Check attached option groups
            if (product.option_groups && Array.isArray(product.option_groups)) {
                product.option_groups.forEach(og => {
                    const cb = document.getElementById('edit_og_' + og.id);
                    if (cb) cb.checked = true;
                });
            }
            
            document.getElementById('editProductModal').style.display = 'flex';
        }

        async function toggleStock(productId) {
            try {
                const res = await fetch(`/manager/products/${productId}/toggle-stock`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    }
                });
                const data = await res.json();
                if (data.success) location.reload();
            } catch(e) {
                console.error(e);
            }
        }

        async function generateQr(tableId) {
            try {
                const res = await fetch(`/manager/tables/${tableId}/generate-qr`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    }
                });
                const data = await res.json();
                if (data.success) {
                    alert(data.message);
                    location.reload();
                }
            } catch(e) {
                console.error(e);
            }
        }
    </script>
</body>
</html>