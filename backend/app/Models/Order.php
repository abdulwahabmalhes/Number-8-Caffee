<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $guarded = [];

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function branch()
    {
        return $this->belongsTo(Branch::class);
    }

    public function table()
    {
        return $this->belongsTo(Table::class);
    }

    public function vehicle()
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }
}
