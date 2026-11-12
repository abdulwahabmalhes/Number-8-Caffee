<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Offer extends Model
{
    use HasFactory;

    protected $fillable = [
        'title_ar',
        'title_en',
        'description_ar',
        'description_en',
        'image',
        'coupon_code',
        'discount_type',
        'discount_value',
        'min_order_amount',
        'is_active',
        'expires_at',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'discount_value' => 'float',
        'min_order_amount' => 'float',
        'expires_at' => 'date',
    ];
}

