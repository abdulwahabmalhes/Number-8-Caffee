<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Option extends Model
{
    protected $guarded = [];

    protected $casts = [
        'additional_price' => 'float',
        'is_available' => 'boolean',
    ];

    public function optionGroup()
    {
        return $this->belongsTo(OptionGroup::class);
    }

    public function orderItemOptions()
    {
        return $this->hasMany(OrderItemOption::class);
    }
}
