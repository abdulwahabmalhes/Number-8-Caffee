<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpKitchenTicket extends Model
{
    protected $table = 'erp_kitchen_tickets';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'order_id',
        'ticket_number',
        'station_code',
        'status',
        'notes',
        'started_at',
        'ready_at',
        'completed_at',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'ready_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function items(): HasMany
    {
        return $this->hasMany(ErpTicketItem::class, 'ticket_id');
    }

    public function order(): BelongsTo
    {
        return $this->belongsTo(ErpOrder::class, 'order_id');
    }
}
