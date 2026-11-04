<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\Product;
use App\Models\Table;
use App\Models\Category;
use App\Models\Branch;
use App\Models\Customer;
use Illuminate\Support\Str;

class ManagerController extends Controller
{
    public function index()
    {
        $todayOrders = Order::whereDate('created_at', today())->get();
        $totalSales = $todayOrders->where('payment_status', 'paid')->sum('grand_total');
        $ordersCount = $todayOrders->count();
        $tableOrdersCount = $todayOrders->where('order_type', 'table')->count();
        $carOrdersCount = $todayOrders->where('order_type', 'car')->count();
        $pickupOrdersCount = $todayOrders->where('order_type', 'pickup')->count();

        $tables = Table::where('is_active', true)->orderBy('table_number')->get();
        $categories = Category::with('products')->where('is_active', true)->orderBy('sort_order')->get();
        $recentOrders = Order::with(['items.product', 'table', 'vehicle'])->orderBy('created_at', 'desc')->take(20)->get();

        return view('manager.dashboard', compact(
            'totalSales',
            'ordersCount',
            'tableOrdersCount',
            'carOrdersCount',
            'pickupOrdersCount',
            'tables',
            'categories',
            'recentOrders'
        ));
    }

    public function customers()
    {
        // Get all customers, with a count of their paid orders
        $customers = Customer::withCount(['orders' => function ($query) {
            $query->where('payment_status', 'paid');
        }])->orderBy('orders_count', 'desc')->get();

        // Calculate cups for each customer
        foreach ($customers as $customer) {
            // Number of completed cups based on orders_count
            $customer->total_cups = $customer->orders_count;
            // Cups remaining for next reward (every 8 cups -> 1 free)
            $customer->cups_remaining = 8 - ($customer->total_cups % 8);
            if ($customer->cups_remaining == 8 && $customer->total_cups > 0) {
                // If it's a multiple of 8, they just earned a reward, so 0 remaining to GET a reward
                // But typically UI shows 8 out of 8 as full, so we'll leave cups_remaining = 8 as "8 cups to go for NEXT reward"
                // Or maybe 0? The UI on frontend: 8 cups target, if 0, then reward.
                // Let's use standard modulo arithmetic.
                $customer->cups_remaining = 0; // Means they have a reward ready to claim!
            }
        }

        return view('manager.customers', compact('customers'));
    }

    public function orders()
    {
        $orders = Order::with(['items.product', 'table', 'vehicle', 'customer'])
            ->orderBy('created_at', 'desc')
            ->paginate(50);
            
        return view('manager.orders', compact('orders'));
    }

    // Toggle stock availability
    public function toggleProductStock(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $product->is_available = !$product->is_available;
        $product->save();

        return response()->json([
            'success' => true,
            'is_available' => $product->is_available,
            'message' => 'تم تحديث حالة توفر المنتج'
        ]);
    }

    // Create a new product
    public function storeProduct(Request $request)
    {
        $request->validate([
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'price' => 'required|numeric|min:0',
            'image_file' => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:5120',
            'image_url' => 'nullable|string',
            'description_ar' => 'nullable|string',
            'description_en' => 'nullable|string',
        ]);

        $imagePath = 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop';

        if ($request->hasFile('image_file')) {
            $file = $request->file('image_file');
            $filename = time() . '_' . Str::random(8) . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('uploads/products'), $filename);
            $imagePath = '/uploads/products/' . $filename;
        } elseif ($request->filled('image_url')) {
            $imagePath = $request->image_url;
        }

        $product = Product::create([
            'category_id' => $request->category_id,
            'name_ar' => $request->name_ar,
            'name_en' => $request->name_en,
            'price' => $request->price,
            'image' => $imagePath,
            'is_available' => true,
            'sort_order' => Product::count() + 1,
        ]);

        return redirect()->back()->with('success', 'تمت إضافة المنتج الجديد بنجاح');
    }

    // Update existing product
    public function updateProduct(Request $request, $id)
    {
        $request->validate([
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
            'category_id' => 'required|exists:categories,id',
            'price' => 'required|numeric|min:0',
            'image_file' => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:5120',
            'image_url' => 'nullable|string',
        ]);

        $product = Product::findOrFail($id);
        $imagePath = $product->image;

        if ($request->hasFile('image_file')) {
            $file = $request->file('image_file');
            $filename = time() . '_' . Str::random(8) . '.' . $file->getClientOriginalExtension();
            $file->move(public_path('uploads/products'), $filename);
            $imagePath = '/uploads/products/' . $filename;
        } elseif ($request->filled('image_url')) {
            $imagePath = $request->image_url;
        }

        $product->update([
            'category_id' => $request->category_id,
            'name_ar' => $request->name_ar,
            'name_en' => $request->name_en,
            'price' => $request->price,
            'image' => $imagePath,
        ]);

        return redirect()->back()->with('success', 'تم تعديل بيانات المنتج بنجاح');
    }

    // Delete product
    public function deleteProduct($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();

        return redirect()->back()->with('success', 'تم حذف المنتج بنجاح');
    }

    // Store new category
    public function storeCategory(Request $request)
    {
        $request->validate([
            'name_ar' => 'required|string|max:255',
            'name_en' => 'required|string|max:255',
        ]);

        Category::create([
            'name_ar' => $request->name_ar,
            'name_en' => $request->name_en,
            'sort_order' => Category::count() + 1,
            'is_active' => true,
        ]);

        return redirect()->back()->with('success', 'تمت إضافة التصنيف الجديد بنجاح');
    }

    // Store new table (accepts letters, numbers, names e.g. "VIP 1", "T-01", "08")
    public function storeTable(Request $request)
    {
        $request->validate([
            'table_number' => 'required|string|max:50',
        ]);

        $branch = Branch::first() ?? Branch::create([
            'name_ar' => 'فرع الخبيصي',
            'name_en' => 'Al Khabisi Branch',
            'is_active' => true,
        ]);

        $rawNumber = trim($request->table_number);
        // If pure digits, pad with leading zero (e.g. 8 -> 08), otherwise keep the exact custom name
        $finalTableNumber = is_numeric($rawNumber) ? str_pad($rawNumber, 2, '0', STR_PAD_LEFT) : $rawNumber;

        Table::create([
            'branch_id' => $branch->id,
            'table_number' => $finalTableNumber,
            'qr_token' => Str::random(32),
            'is_active' => true,
        ]);

        return redirect()->back()->with('success', 'تمت إضافة الطاولة وتوليد رمز QR بنجاح');
    }

    // Delete table
    public function deleteTable($id)
    {
        $table = Table::findOrFail($id);
        $table->delete();

        return redirect()->back()->with('success', 'تم حذف الطاولة بنجاح');
    }

    // Generate new QR token
    public function generateTableQr(Request $request, $id)
    {
        $table = Table::findOrFail($id);
        $table->qr_token = Str::random(32);
        $table->save();

        return response()->json([
            'success' => true,
            'qr_token' => $table->qr_token,
            'message' => 'تم تجديد الرمز المشفر للطاولة رقم ' . $table->table_number
        ]);
    }

    // Printable Table QR Sheet
    public function printTableQr($id)
    {
        $table = Table::with('branch')->findOrFail($id);
        return view('manager.print_qr', compact('table'));
    }

    // Printable All Tables QR Sheet
    public function printAllTablesQr()
    {
        $tables = Table::where('is_active', true)->orderBy('table_number')->get();
        return view('manager.print_all_qr', compact('tables'));
    }

    // Daily & Monthly Sales Reports
    public function reports(Request $request)
    {
        $reportType = $request->input('type', 'daily');
        if (!in_array($reportType, ['daily', 'monthly'])) {
            $reportType = 'daily';
        }

        $selectedDate = $request->input('date', today()->toDateString());
        $selectedMonth = $request->input('month', now()->format('Y-m'));

        if ($reportType === 'daily') {
            $dailyOrders = Order::with(['items.product', 'table', 'vehicle', 'customer'])
                ->whereDate('created_at', $selectedDate)
                ->where('status', '!=', 'payment_pending')
                ->orderBy('created_at', 'desc')
                ->get();

            $grossSales = (float) $dailyOrders->sum('grand_total');
            $paidSales = (float) $dailyOrders->where('payment_status', 'paid')->sum('grand_total');
            $pendingSales = (float) $dailyOrders->where('payment_status', '!=', 'paid')->sum('grand_total');
            $ordersCount = $dailyOrders->count();
            $paidOrdersCount = $dailyOrders->where('payment_status', 'paid')->count();
            $averageOrder = $ordersCount > 0 ? round($grossSales / $ordersCount, 2) : 0;
            $vatAmount = round($grossSales - ($grossSales / 1.05), 2);
            $subtotalAmount = round($grossSales / 1.05, 2);

            // Channel Breakdown
            $carOrders = $dailyOrders->where('order_type', 'car');
            $tableOrders = $dailyOrders->where('order_type', 'table');
            $pickupOrders = $dailyOrders->where('order_type', 'pickup');

            $channels = [
                'car' => [
                    'count' => $carOrders->count(),
                    'sales' => (float) $carOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($carOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
                'table' => [
                    'count' => $tableOrders->count(),
                    'sales' => (float) $tableOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($tableOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
                'pickup' => [
                    'count' => $pickupOrders->count(),
                    'sales' => (float) $pickupOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($pickupOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
            ];

            // Payment Methods Breakdown
            $paidOnline = $dailyOrders->where('payment_status', 'paid');
            $unpaidOrCash = $dailyOrders->where('payment_status', '!=', 'paid');
            $payments = [
                'paid' => [
                    'count' => $paidOnline->count(),
                    'sales' => (float) $paidOnline->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($paidOnline->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
                'pending' => [
                    'count' => $unpaidOrCash->count(),
                    'sales' => (float) $unpaidOrCash->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($unpaidOrCash->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
            ];

            // Hourly Sales (from 06:00 to 23:00)
            $hourlyData = [];
            for ($h = 6; $h <= 23; $h++) {
                $hourlyData[$h] = [
                    'hour_formatted' => sprintf('%02d:00', $h),
                    'count' => 0,
                    'sales' => 0,
                ];
            }
            foreach ($dailyOrders as $ord) {
                $hour = (int) $ord->created_at->format('H');
                if (isset($hourlyData[$hour])) {
                    $hourlyData[$hour]['count']++;
                    $hourlyData[$hour]['sales'] += (float) $ord->grand_total;
                }
            }

            // Top Products
            $productStats = [];
            foreach ($dailyOrders as $ord) {
                foreach ($ord->items as $item) {
                    $pId = $item->product_id;
                    if (!isset($productStats[$pId])) {
                        $productStats[$pId] = [
                            'name_en' => $item->product ? $item->product->name_en : 'Product #' . $pId,
                            'name_ar' => $item->product ? ($item->product->name_ar ?: $item->product->name_en) : 'منتج #' . $pId,
                            'image' => $item->product ? $item->product->image : null,
                            'quantity' => 0,
                            'sales' => 0,
                        ];
                    }
                    $productStats[$pId]['quantity'] += $item->quantity;
                    $productStats[$pId]['sales'] += (float) $item->total_price;
                }
            }
            usort($productStats, fn($a, $b) => $b['quantity'] <=> $a['quantity']);
            $topProducts = array_slice($productStats, 0, 10);

            // Handle CSV export
            if ($request->input('export') === 'csv') {
                return $this->exportDailyCsv($selectedDate, $dailyOrders, $grossSales, $ordersCount);
            }

            return view('manager.reports', compact(
                'reportType',
                'selectedDate',
                'selectedMonth',
                'dailyOrders',
                'grossSales',
                'paidSales',
                'pendingSales',
                'ordersCount',
                'paidOrdersCount',
                'averageOrder',
                'vatAmount',
                'subtotalAmount',
                'channels',
                'payments',
                'hourlyData',
                'topProducts'
            ));
        } else {
            // Monthly Report
            $parts = explode('-', $selectedMonth);
            $year = isset($parts[0]) ? (int) $parts[0] : (int) now()->year;
            $m = isset($parts[1]) ? (int) $parts[1] : (int) now()->month;

            $monthOrders = Order::with(['items.product', 'table', 'vehicle', 'customer'])
                ->whereYear('created_at', $year)
                ->whereMonth('created_at', $m)
                ->where('status', '!=', 'payment_pending')
                ->orderBy('created_at', 'desc')
                ->get();

            $grossSales = (float) $monthOrders->sum('grand_total');
            $paidSales = (float) $monthOrders->where('payment_status', 'paid')->sum('grand_total');
            $ordersCount = $monthOrders->count();
            $averageOrder = $ordersCount > 0 ? round($grossSales / $ordersCount, 2) : 0;
            $vatAmount = round($grossSales - ($grossSales / 1.05), 2);
            $subtotalAmount = round($grossSales / 1.05, 2);

            $carbonMonth = \Carbon\Carbon::createFromDate($year, $m, 1);
            $daysInMonth = $carbonMonth->daysInMonth;

            // Previous Month Comparison
            $prevMonthCarbon = $carbonMonth->copy()->subMonth();
            $prevMonthSales = (float) Order::whereYear('created_at', $prevMonthCarbon->year)
                ->whereMonth('created_at', $prevMonthCarbon->month)
                ->where('status', '!=', 'payment_pending')
                ->sum('grand_total');

            $growthRate = $prevMonthSales > 0 ? round((($grossSales - $prevMonthSales) / $prevMonthSales) * 100, 1) : ($grossSales > 0 ? 100 : 0);

            // Active elapsed days for daily average
            $now = \Carbon\Carbon::now();
            $elapsedDays = ($now->format('Y-m') === $selectedMonth) ? max(1, min($now->day, $daysInMonth)) : $daysInMonth;
            $averageDailySales = round($grossSales / $elapsedDays, 2);

            // Daily breakdown list
            $dailyBreakdown = [];
            $bestDay = ['date' => '-', 'sales' => 0];

            for ($d = 1; $d <= $daysInMonth; $d++) {
                $currentDayCarbon = \Carbon\Carbon::createFromDate($year, $m, $d);
                $dayStr = $currentDayCarbon->toDateString();
                $ordersForDay = $monthOrders->filter(fn($o) => $o->created_at->toDateString() === $dayStr);

                $daySales = (float) $ordersForDay->sum('grand_total');
                $dayOrdersCount = $ordersForDay->count();

                if ($daySales > $bestDay['sales']) {
                    $bestDay = [
                        'date' => $dayStr,
                        'day_name' => $currentDayCarbon->format('l'),
                        'sales' => $daySales,
                    ];
                }

                $dailyBreakdown[] = [
                    'day' => $d,
                    'date' => $dayStr,
                    'day_name' => $currentDayCarbon->format('l'),
                    'day_name_ar' => $this->arabicDayName($currentDayCarbon->format('l')),
                    'orders_count' => $dayOrdersCount,
                    'car_sales' => (float) $ordersForDay->where('order_type', 'car')->sum('grand_total'),
                    'table_sales' => (float) $ordersForDay->where('order_type', 'table')->sum('grand_total'),
                    'sales' => $daySales,
                ];
            }

            // Channel Breakdown
            $carOrders = $monthOrders->where('order_type', 'car');
            $tableOrders = $monthOrders->where('order_type', 'table');
            $pickupOrders = $monthOrders->where('order_type', 'pickup');

            $channels = [
                'car' => [
                    'count' => $carOrders->count(),
                    'sales' => (float) $carOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($carOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
                'table' => [
                    'count' => $tableOrders->count(),
                    'sales' => (float) $tableOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($tableOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
                'pickup' => [
                    'count' => $pickupOrders->count(),
                    'sales' => (float) $pickupOrders->sum('grand_total'),
                    'percent' => $grossSales > 0 ? round(($pickupOrders->sum('grand_total') / $grossSales) * 100, 1) : 0,
                ],
            ];

            // Top Products for the Month
            $productStats = [];
            foreach ($monthOrders as $ord) {
                foreach ($ord->items as $item) {
                    $pId = $item->product_id;
                    if (!isset($productStats[$pId])) {
                        $productStats[$pId] = [
                            'name_en' => $item->product ? $item->product->name_en : 'Product #' . $pId,
                            'name_ar' => $item->product ? ($item->product->name_ar ?: $item->product->name_en) : 'منتج #' . $pId,
                            'image' => $item->product ? $item->product->image : null,
                            'quantity' => 0,
                            'sales' => 0,
                        ];
                    }
                    $productStats[$pId]['quantity'] += $item->quantity;
                    $productStats[$pId]['sales'] += (float) $item->total_price;
                }
            }
            usort($productStats, fn($a, $b) => $b['quantity'] <=> $a['quantity']);
            $topProducts = array_slice($productStats, 0, 10);

            // Handle CSV export
            if ($request->input('export') === 'csv') {
                return $this->exportMonthlyCsv($selectedMonth, $dailyBreakdown, $grossSales, $ordersCount);
            }

            return view('manager.reports', compact(
                'reportType',
                'selectedDate',
                'selectedMonth',
                'monthOrders',
                'grossSales',
                'paidSales',
                'ordersCount',
                'averageOrder',
                'vatAmount',
                'subtotalAmount',
                'averageDailySales',
                'growthRate',
                'prevMonthSales',
                'dailyBreakdown',
                'bestDay',
                'channels',
                'topProducts'
            ));
        }
    }

    private function exportDailyCsv($date, $orders, $grossSales, $ordersCount)
    {
        $filename = "n8-daily-sales-report-{$date}.csv";
        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ];

        $callback = function () use ($orders, $date, $grossSales, $ordersCount) {
            $handle = fopen('php://output', 'w');
            fprintf($handle, chr(0xEF).chr(0xBB).chr(0xBF)); // UTF-8 BOM

            fputcsv($handle, ['NUMBER EIGHT SPECIALTY COFFEE - DAILY SALES REPORT']);
            fputcsv($handle, ['Date', $date]);
            fputcsv($handle, ['Total Sales (AED)', number_format($grossSales, 2)]);
            fputcsv($handle, ['Total Orders', $ordersCount]);
            fputcsv($handle, []);
            fputcsv($handle, ['Order #', 'Time', 'Customer', 'Phone', 'Order Type', 'Payment Method', 'Payment Status', 'Total (AED)', 'Status']);

            foreach ($orders as $o) {
                fputcsv($handle, [
                    $o->order_number ?: '#' . $o->id,
                    $o->created_at->format('H:i'),
                    $o->customer ? ($o->customer->name ?? 'Guest') : 'Guest',
                    $o->customer ? $o->customer->phone : '',
                    strtoupper($o->order_type),
                    strtoupper($o->payment_method ?? 'CASH/POS'),
                    strtoupper($o->payment_status),
                    number_format($o->grand_total, 2),
                    strtoupper($o->status),
                ]);
            }
            fclose($handle);
        };

        return response()->stream($callback, 200, $headers);
    }

    private function exportMonthlyCsv($month, $dailyBreakdown, $grossSales, $ordersCount)
    {
        $filename = "n8-monthly-sales-report-{$month}.csv";
        $headers = [
            'Content-Type' => 'text/csv; charset=UTF-8',
            'Content-Disposition' => "attachment; filename=\"{$filename}\"",
        ];

        $callback = function () use ($dailyBreakdown, $month, $grossSales, $ordersCount) {
            $handle = fopen('php://output', 'w');
            fprintf($handle, chr(0xEF).chr(0xBB).chr(0xBF)); // UTF-8 BOM

            fputcsv($handle, ['NUMBER EIGHT SPECIALTY COFFEE - MONTHLY SALES REPORT']);
            fputcsv($handle, ['Month', $month]);
            fputcsv($handle, ['Total Sales (AED)', number_format($grossSales, 2)]);
            fputcsv($handle, ['Total Orders', $ordersCount]);
            fputcsv($handle, []);
            fputcsv($handle, ['Date', 'Day', 'Orders Count', 'Car Sales (AED)', 'Table Sales (AED)', 'Total Sales (AED)']);

            foreach ($dailyBreakdown as $row) {
                fputcsv($handle, [
                    $row['date'],
                    $row['day_name_ar'] . ' / ' . $row['day_name'],
                    $row['orders_count'],
                    number_format($row['car_sales'], 2),
                    number_format($row['table_sales'], 2),
                    number_format($row['sales'], 2),
                ]);
            }
            fclose($handle);
        };

        return response()->stream($callback, 200, $headers);
    }

    private function arabicDayName($englishDay)
    {
        $map = [
            'Saturday' => 'السبت',
            'Sunday' => 'الأحد',
            'Monday' => 'الاثنين',
            'Tuesday' => 'الثلاثاء',
            'Wednesday' => 'الأربعاء',
            'Thursday' => 'الخميس',
            'Friday' => 'الجمعة',
        ];
        return $map[$englishDay] ?? $englishDay;
    }
}
