<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $guarded = [];

    public function getImageAttribute($value)
    {
        if ($value && str_starts_with($value, '/uploads/')) {
            return url($value);
        }
        return $value;
    }

    public function getImageUrlAttribute()
    {
        return $this->image;
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
