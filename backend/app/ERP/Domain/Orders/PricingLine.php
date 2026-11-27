<?php

namespace App\ERP\Domain\Orders;

use App\ERP\Domain\Shared\Money;
use InvalidArgumentException;

final readonly class PricingLine
{
    /** @param list<Money> $modifiers */
    public function __construct(
        public string $productId,
        public Money $unitPrice,
        public int $quantity,
        public array $modifiers = [],
    ) {
        if ($productId === '' || $quantity < 1) {
            throw new InvalidArgumentException('A pricing line requires a product and positive quantity.');
        }
    }
}
