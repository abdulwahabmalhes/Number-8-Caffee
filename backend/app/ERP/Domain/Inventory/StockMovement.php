<?php

namespace App\ERP\Domain\Inventory;

use InvalidArgumentException;

final readonly class StockMovement
{
    public const TYPES = ['receipt', 'sale', 'waste', 'adjustment', 'transfer_in', 'transfer_out'];

    public function __construct(
        public string $ingredientId,
        public string $locationId,
        public string $type,
        public int $quantityMicrounits,
        public string $idempotencyKey,
    ) {
        if ($ingredientId === '' || $locationId === '' || $idempotencyKey === '') {
            throw new InvalidArgumentException('Stock movement identifiers are required.');
        }

        if (! in_array($type, self::TYPES, true) || $quantityMicrounits === 0) {
            throw new InvalidArgumentException('Invalid stock movement.');
        }
    }
}
