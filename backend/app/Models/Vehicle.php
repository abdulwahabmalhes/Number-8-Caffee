<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Vehicle extends Model
{
    protected $fillable = [
        'plate_number',
        'plate_emirate',
        'vehicle_type',
        'vehicle_model',
        'vehicle_color',
    ];

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
