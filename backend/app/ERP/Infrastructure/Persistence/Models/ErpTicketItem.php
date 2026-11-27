<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpTicketItem extends Model
{
    protected $table = 'erp_ticket_items';

    protected $fillable = [
        'ticket_id',
        'order_line_id',
        'item_name',
        'quantity',
        'modifiers',
        'status',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'modifiers' => 'array',
    ];

    public function ticket(): BelongsTo
    {
        return $this->belongsTo(ErpKitchenTicket::class, 'ticket_id');
    }
}
