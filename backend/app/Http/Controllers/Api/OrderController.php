<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Table;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function checkout(Request $request)
    {
        $request->validate([
            'session_id' => 'required|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.special_instructions' => 'nullable|string|max:255',
            'table_id' => 'nullable|integer|exists:tables,id',
            'branch_id' => 'nullable|integer|exists:branches,id',
            'order_type' => 'nullable|string',
            'payment_method' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($request) {
            $totalAmount = 0;
            // First pass to calculate total
            foreach ($request->items as $item) {
                $product = \App\Models\Product::find($item['product_id']);
                $itemBase = (float) ($product ? $product->price : 0);
                if (!empty($item['options'])) {
                    foreach ($item['options'] as $opt) {
                        $optId = is_array($opt) ? ($opt['id'] ?? null) : $opt;
                        if ($optId) {
                            $optModel = \App\Models\Option::find($optId);
                            if ($optModel) {
                                $itemBase += (float) $optModel->additional_price;
                            }
                        }
                    }
                }
                $totalAmount += $itemBase * $item['quantity'];
            }

            $vehicleId = null;
            if ($request->order_type === 'car' && $request->has('vehicle_details')) {
                $vDetails = $request->vehicle_details;
                $vehicle = \App\Models\Vehicle::firstOrCreate(
                    ['plate_number' => $vDetails['plate_number'] ?? 'Unknown'],
                    [
                        'plate_emirate' => $vDetails['plate_emirate'] ?? null,
                        'vehicle_model' => $vDetails['vehicle_model'] ?? null,
                        'vehicle_color' => $vDetails['vehicle_color'] ?? null,
                    ]
                );
                $vehicleId = $vehicle->id;
            }

            // Determine branch_id and table_id
            $branchId = $request->branch_id ?? 1;
            $tableId = $request->order_type === 'table' ? ($request->table_id ?? 1) : null;

            // Determine customer_id from authenticated sanctum customer
            $customer = $request->user();
            $customerId = $customer ? $customer->id : null;

            $order = Order::create([
                'branch_id' => $branchId,
                'table_id' => $tableId,
                'vehicle_id' => $vehicleId,
                'customer_id' => $customerId,
                'order_type' => $request->order_type ?? 'table',
                'order_number' => '#NE' . rand(1000, 9999), // matching standard format
                'status' => 'new',
                'payment_method' => $request->payment_method ?? 'cash',
                'payment_status' => ($request->payment_method === 'cash') ? 'pending' : 'paid',
                'notes' => $request->payment_reference ? ('Stripe Ref: ' . $request->payment_reference) : ($request->notes ?? null),
                'grand_total' => $totalAmount + ($request->order_type === 'table' ? 2.0 : 0.0), // Include service fee if table
                'subtotal' => $totalAmount,
                'tax_amount' => 0,
                'session_id' => $request->session_id,
            ]);

            foreach ($request->items as $item) {
                $product = \App\Models\Product::find($item['product_id']);
                $itemBase = (float) ($product ? $product->price : 0);
                $optionsToAttach = [];
                if (!empty($item['options'])) {
                    foreach ($item['options'] as $opt) {
                        $optId = is_array($opt) ? ($opt['id'] ?? null) : $opt;
                        if ($optId) {
                            $optModel = \App\Models\Option::find($optId);
                            if ($optModel) {
                                $itemBase += (float) $optModel->additional_price;
                                $optionsToAttach[] = $optModel;
                            }
                        }
                    }
                }

                $orderItem = OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'unit_price' => $itemBase,
                    'total_price' => $itemBase * $item['quantity'],
                    'special_instructions' => $item['special_instructions'] ?? null,
                ]);

                foreach ($optionsToAttach as $optModel) {
                    \App\Models\OrderItemOption::create([
                        'order_item_id' => $orderItem->id,
                        'option_id' => $optModel->id,
                        'price' => $optModel->additional_price,
                    ]);
                }
            }

            // Dispatch event for WebSockets
            try {
                event(new \App\Events\OrderCreated($order));
            } catch (\Exception $e) {
                // Ignore event broadcast error if Reverb is not configured/running
            }

            return response()->json([
                'success' => true,
                'message' => 'Order placed successfully',
                'order_number' => $order->order_number,
            ]);
        });
    }

    public function status($order_number)
    {
        $order = Order::with(['items.product', 'items.options.option', 'table', 'vehicle'])
            ->where('order_number', $order_number)
            ->first();

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        }

        return response()->json([
            'success' => true,
            'status' => $order->status,
            'payment_status' => $order->payment_status,
            'payment_method' => $order->payment_method,
            'order' => $order,
        ]);
    }

    public function index(Request $request)
    {
        $user = $request->user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated'
            ], 401);
        }

        // Fetch orders for this customer (excluding unpaid abandoned checkouts)
        $orders = Order::with(['items.product', 'items.options.option', 'table', 'vehicle'])
            ->where('customer_id', $user->id)
            ->where('status', '!=', 'payment_pending')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'orders' => $orders
        ]);
    }
}
