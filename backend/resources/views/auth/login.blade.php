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
    <title>Login - NUMBER EIGHT SPECIALTY COFFEE</title>
    
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

    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Tajawal:wght@400;500;700;800&family=DM+Sans:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>
        html[dir="rtl"] body,
        html[dir="rtl"] * {
            font-family: 'Tajawal', sans-serif;
        }

        html[dir="ltr"] body,
        html[dir="ltr"] * {
            font-family: 'DM Sans', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        /* Language Switcher */
        .lang-switch-wrap {
            display: inline-flex;
            align-items: center;
            background: #18181b;
            border: 1px solid #27272a;
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
            color: #a1a1aa;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .lang-toggle-btn.active {
            background: #27272a;
            color: #ffffff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body class="bg-zinc-950 text-white font-sans antialiased min-h-screen flex items-center justify-center p-4">
    <div class="w-full max-w-md bg-zinc-900 border border-zinc-800 p-8 rounded-2xl shadow-2xl relative">
        
        <!-- Top Language Switcher -->
        <div class="flex justify-end mb-4">
            <div class="lang-switch-wrap">
                <button type="button" onclick="setN8Language('en')" class="lang-toggle-btn {{ $currentLang === 'en' ? 'active' : '' }}" id="btn-lang-en">
                    <span>🇬🇧 EN</span>
                </button>
                <button type="button" onclick="setN8Language('ar')" class="lang-toggle-btn {{ $currentLang === 'ar' ? 'active' : '' }}" id="btn-lang-ar">
                    <span>🇦🇪 عربي</span>
                </button>
            </div>
        </div>

        <div class="text-center mb-8">
            <div class="flex justify-center mb-4">
                <div class="w-20 h-20 bg-white rounded-full p-2 flex items-center justify-center shadow-lg">
                    <img src="/images/logo.png" class="w-full h-full object-contain" alt="NUMBER EIGHT">
                </div>
            </div>
            <h1 class="text-2xl font-bold text-amber-500 mb-1" style="font-family: 'DM Sans', sans-serif;">NUMBER EIGHT</h1>
            <p class="text-zinc-400 text-sm" data-i18n="login_subtitle">Sign in to access your dashboard</p>
        </div>

        <form method="POST" action="{{ route('login.post') }}" class="space-y-6">
            @csrf

            <div>
                <label for="email" class="block text-sm font-medium text-zinc-300 mb-2" data-i18n="login_email">Email Address</label>
                <input id="email" name="email" type="email" autocomplete="email" required value="{{ old('email') }}"
                    class="w-full px-4 py-3 bg-zinc-950 border border-zinc-700 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500 text-white placeholder-zinc-500"
                    placeholder="Enter your email" data-i18n-placeholder="placeholder_email">
                @error('email')
                    <p class="mt-2 text-sm text-red-500">{{ $message }}</p>
                @enderror
            </div>

            <div>
                <label for="password" class="block text-sm font-medium text-zinc-300 mb-2" data-i18n="login_password">Password</label>
                <input id="password" name="password" type="password" autocomplete="current-password" required
                    class="w-full px-4 py-3 bg-zinc-950 border border-zinc-700 rounded-lg focus:ring-2 focus:ring-amber-500 focus:border-amber-500 text-white placeholder-zinc-500"
                    placeholder="Enter your password" data-i18n-placeholder="placeholder_password">
            </div>

            <button type="submit" data-i18n="login_submit"
                class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-sm font-bold text-zinc-900 bg-amber-500 hover:bg-amber-400 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-amber-500 focus:ring-offset-zinc-900 transition-colors">
                Sign In
            </button>
        </form>
    </div>

    <!-- Master Localization Engine Script -->
    <script src="/js/n8-i18n.js"></script>
</body>
</html>