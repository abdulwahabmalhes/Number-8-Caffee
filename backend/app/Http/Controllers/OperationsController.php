<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\Table;
use App\Models\Branch;

class OperationsController extends Controller
{
    public function index()
    {
        // Fetch all orders for today (excluding uncompleted Stripe checkouts)
        $orders = Order::with(['items.product', 'items.options.option', 'table', 'vehicle', 'branch'])
            ->whereDate('created_at', today())
            ->where('status', '!=', 'payment_pending')
            ->orderBy('created_at', 'desc')
            ->get();

        $stats = [
            'new' => $orders->where('status', 'new')->count(),
            'preparing' => $orders->whereIn('status', ['accepted', 'preparing'])->count(),
            'ready' => $orders->where('status', 'ready')->count(),
            'delivered' => $orders->where('status', 'delivered')->count(),
            'arrived_cars' => $orders->where('order_type', 'car')->whereNotNull('customer_arrived_at')->where('status', '!=', 'delivered')->count(),
        ];

        return view('operations.dashboard', compact('orders', 'stats'));
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string|in:new,accepted,preparing,ready,delivered,cancelled'
        ]);

        $order = Order::findOrFail($id);
        $order->status = $request->status;

        if ($request->status === 'delivered') {
            $order->delivered_at = now();
        }

        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث حالة الطلب بنجاح',
            'order' => $order
        ]);
    }

    public function markArrived($id)
    {
        $order = Order::findOrFail($id);
        $order->customer_arrived_at = now();
        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'تم تسجيل وصول العميل',
            'order' => $order
        ]);
    }

    public function liveFeed()
    {
        $orders = Order::with(['items.product', 'items.options.option', 'table', 'vehicle', 'branch'])
            ->whereDate('created_at', today())
            ->where('status', '!=', 'payment_pending')
            ->orderBy('created_at', 'desc')
            ->get();

        $stats = [
            'new' => $orders->where('status', 'new')->count(),
            'preparing' => $orders->whereIn('status', ['accepted', 'preparing'])->count(),
            'ready' => $orders->where('status', 'ready')->count(),
            'delivered' => $orders->where('status', 'delivered')->count(),
            'arrived_cars' => $orders->where('order_type', 'car')->whereNotNull('customer_arrived_at')->where('status', '!=', 'delivered')->count(),
        ];

        return response()->json([
            'success' => true,
            'orders' => $orders,
            'stats' => $stats
        ]);
    }

    // Print Thermal Receipt / Tax Invoice
    public function printReceipt($id)
    {
        $order = Order::with(['items.product', 'items.options.option', 'table', 'vehicle', 'branch'])->findOrFail($id);
        return view('operations.receipt', compact('order'));
    }

    // Public Customer Tax Invoice View (No auth required)
    public function publicReceipt($orderNumber)
    {
        $order = Order::with(['items.product', 'items.options.option', 'table', 'vehicle', 'branch'])
            ->where('order_number', $orderNumber)
            ->orWhere('id', $orderNumber)
            ->firstOrFail();
        return view('operations.receipt', compact('order'));
    }

    // Print Cup Sticker Labels (50x50mm / 58mm Thermal Sticker)
    public function printSticker($id)
    {
        $order = Order::with(['items.product', 'items.options.option', 'table', 'vehicle', 'branch', 'customer.orders'])->findOrFail($id);
        
        $stickers = [];
        $totalCups = max(1, $order->items->sum('quantity'));
        $currentCup = 1;

        foreach ($order->items as $item) {
            $optionsList = $item->options ? $item->options->map(function($o) {
                return $o->option ? ($o->option->name_en ?: $o->option->name_ar) : '';
            })->filter()->implode(' • ') : '';

            for ($i = 0; $i < $item->quantity; $i++) {
                $stickers[] = [
                    'cup_number' => $currentCup++,
                    'total_cups' => $totalCups,
                    'product_name_en' => $item->product ? $item->product->name_en : 'Specialty Drink',
                    'product_name_ar' => $item->product ? $item->product->name_ar : 'مشروب مختص',
                    'special_instructions' => $optionsList ?: ($item->special_instructions ?: ''),
                ];
            }
        }

        $customerName = $order->customer ? $order->customer->name : 'ضيف NUMBER EIGHT';
        $customerOrdersCount = $order->customer ? $order->customer->orders->where('payment_status', 'paid')->count() : 1;
        $tier = $customerOrdersCount >= 20 ? 'Platinum 5' : ($customerOrdersCount >= 8 ? 'Gold' : 'Silver');

        return view('operations.sticker', compact('order', 'stickers', 'customerName', 'customerOrdersCount', 'tier'));
    }
}
