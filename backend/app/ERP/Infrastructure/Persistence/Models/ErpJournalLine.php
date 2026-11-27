<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpJournalLine extends Model
{
    protected $table = 'erp_journal_lines';

    protected $fillable = [
        'journal_id',
        'account_id',
        'debit_minor',
        'credit_minor',
        'memo',
    ];

    protected $casts = [
        'debit_minor' => 'integer',
        'credit_minor' => 'integer',
    ];

    public function journal(): BelongsTo
    {
        return $this->belongsTo(ErpJournal::class, 'journal_id');
    }

    public function account(): BelongsTo
    {
        return $this->belongsTo(ErpAccount::class, 'account_id');
    }
}
