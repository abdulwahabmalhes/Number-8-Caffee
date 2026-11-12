<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OptionGroup extends Model
{
    protected $guarded = [];

    protected $casts = [
        'is_required' => 'boolean',
        'is_multiple' => 'boolean',
        'min_choices' => 'integer',
        'max_choices' => 'integer',
    ];

    public function options()
    {
        return $this->hasMany(Option::class)->orderBy('id');
    }

    public function products()
    {
        return $this->belongsToMany(Product::class, 'product_option_group');
    }
}
