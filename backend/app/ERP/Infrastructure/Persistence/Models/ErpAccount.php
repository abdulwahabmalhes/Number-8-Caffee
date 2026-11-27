<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpAccount extends Model
{
    protected $table = 'erp_accounts';

    protected $fillable = [
        'tenant_id',
        'code',
        'name_en',
        'name_ar',
        'type',
        'currency',
    ];

    public function lines(): HasMany
    {
        return $this->hasMany(ErpJournalLine::class, 'account_id');
    }
}
