# NUMBER EIGHT SPECIALTY COFFEE — Full Stack Ecosystem

A comprehensive specialty coffee ecosystem featuring a **Flutter Mobile App (iOS & Android)** and a **Laravel Backend & Operations Dashboard** with live order dispatch, curbside car pickup tracking, QR-table ordering, bilingual management hub, and loyalty punch card system.

---

## ☕ System Architecture

```
NUMBER EIGHT SPECIALTY COFFEE/
├── backend/                  # Laravel 12 API, WebSockets & Bilingual Hub
│   ├── app/                  # Controllers, Models, Events, Middleware
│   ├── config/               # App, Database, Stripe, Reverb configs
│   ├── database/             # Migrations & Seeders
│   ├── public/               # Public assets & localization engine (n8-i18n.js)
│   ├── resources/views/      # Operations, Manager, Reports, Receipts & Stickers
│   └── routes/               # API & Web routes
└── frontend/                 # Flutter Cross-Platform Mobile Application
    ├── lib/                  # Dart source code (Screens, Providers, Widgets)
    ├── android/              # Native Android wrapper & Manifest
    ├── ios/                  # Native iOS wrapper & Runner project
    └── pubspec.yaml          # Flutter dependencies
```

---

## 🌟 Key Features

### 1. Mobile App (Frontend - Flutter)
- **Curbside Car Service**: Customers specify vehicle model, color, and plate number. GPS/arrival trigger notifies barista upon arrival outside the cafe.
- **Dine-in Table Ordering**: Scan table QR codes with instant menu binding.
- **Loyalty Punch Card**: 1 free coffee for every 8 cups consumed.
- **Payment Gateway**: Apple Pay, Credit/Debit cards (Stripe Integration), and Pay at Cashier.
- **Real-time Order Tracking**: Live status progression (New → Preparing → Ready → Delivered).

### 2. Operations & Dispatch Hub (`/operations`)
- **Live Sound & Audio Alerts**: Plays custom chime when new orders arrive.
- **KDS Barista Screen**: Filter by Pending, Preparing, or Completed orders.
- **Curbside Arrival Alert**: Highlights car orders when customer pulls up outside.
- **Thermal Printing**:
  - 🧾 **Tax Receipts** (80mm / 58mm Thermal Receipt).
  - 🏷️ **Cup Stickers** (58mm Thermal Cup Label with customer name & instructions).
- **Bilingual Interface**: Instant English/Arabic toggle `[ 🇬🇧 EN | 🇦🇪 عربي ]` with persistent per-device memory.

### 3. Executive Manager Portal & Reports (`/manager`)
- **Daily & Monthly Sales Reports (`/manager/reports`)**:
  - Filter by any day or month.
  - KPI cards: Gross Sales, Orders Count, Average Order Value, 5% VAT.
  - Peak hours hourly breakdown (06:00 to 23:00).
  - Day-by-day table of the entire month with growth percentage.
  - One-click **Print Report 🖨️** (A4 / PDF) & **Export CSV / Excel 📥**.
- **Menu & Stock Control**: Toggle product availability in real-time, edit prices and images.
- **Table QR Management**: Supports custom alphanumeric table names (e.g., `VIP 1`, `Terrace`, `08`).

---

## 🚀 Getting Started

### Backend Setup (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

### Frontend Setup (Flutter)
```bash
cd frontend
flutter pub get
flutter run
```

---

## 📄 License
Proprietary — NUMBER EIGHT SPECIALTY COFFEE. All rights reserved.
