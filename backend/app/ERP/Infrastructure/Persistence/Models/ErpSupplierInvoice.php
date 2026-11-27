<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpSupplierInvoice extends Model
{
    protected $table = 'erp_supplier_invoices';

    protected $fillable = [
        'tenant_id',
        'supplier_id',
        'po_id',
        'goods_receipt_id',
        'invoice_number',
        'invoice_date',
        'subtotal_minor',
        'tax_minor',
        'total_minor',
        'currency',
        'status',
        'posted_journal_id',
    ];

    protected $casts = [
        'subtotal_minor' => 'integer',
        'tax_minor' => 'integer',
        'total_minor' => 'integer',
        'invoice_date' => 'date',
    ];

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(ErpSupplier::class, 'supplier_id');
    }

    public function journal(): BelongsTo
    {
        return $this->belongsTo(ErpJournal::class, 'posted_journal_id');
    }
}
