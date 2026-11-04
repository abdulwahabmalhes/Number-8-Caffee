<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Customer extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name',
        'phone',
        'otp_code',
        'otp_expires_at',
    ];

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
