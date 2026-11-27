<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;

class ErpStation extends Model
{
    protected $table = 'erp_stations';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'code',
        'name_en',
        'name_ar',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];
}
