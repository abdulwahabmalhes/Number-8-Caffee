<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpJournal extends Model
{
    protected $table = 'erp_journals';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'journal_number',
        'period',
        'description',
        'posted_at',
        'created_by',
    ];

    protected $casts = [
        'posted_at' => 'datetime',
    ];

    public function lines(): HasMany
    {
        return $this->hasMany(ErpJournalLine::class, 'journal_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }
}
