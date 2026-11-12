<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Offer;

class OfferApiController extends Controller
{
    public function index()
    {
        $offers = Offer::where('is_active', true)
            ->where(function($q) {
                $q->whereNull('expires_at')
                  ->orWhere('expires_at', '>=', now()->toDateString());
            })
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $offers
        ]);
    }

    public function validateCoupon(Request $request)
    {
        $request->validate([
            'code' => 'required|string',
            'subtotal' => 'nullable|numeric',
        ]);

        $code = strtoupper(trim($request->code));
        $subtotal = (float)($request->subtotal ?? 0);

        $offer = Offer::where('is_active', true)
            ->whereRaw('UPPER(coupon_code) = ?', [$code])
            ->first();

        if (!$offer) {
            return response()->json([
                'success' => false,
                'message' => 'كود الخصم غير صالح أو منتهي الصلاحية'
            ], 422);
        }

        if ($offer->min_order_amount > 0 && $subtotal < $offer->min_order_amount) {
            return response()->json([
                'success' => false,
                'message' => "الحد الأدنى لتطبيق هذا الكوبون هو {$offer->min_order_amount} درهم"
            ], 422);
        }

        $discount = 0.0;
        if ($offer->discount_type === 'percentage') {
            $discount = round(($subtotal * $offer->discount_value) / 100, 2);
        } else {
            $discount = min($subtotal, (float)$offer->discount_value);
        }

        return response()->json([
            'success' => true,
            'message' => 'تم تطبيق كود الخصم بنجاح',
            'coupon_code' => $offer->coupon_code,
            'discount_type' => $offer->discount_type,
            'discount_value' => $offer->discount_value,
            'discount_amount' => $discount,
            'offer_title' => $offer->title_ar ?: $offer->title_en,
        ]);
    }
}
