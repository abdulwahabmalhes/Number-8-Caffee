<?php

namespace App\ERP\Domain\Orders;

use App\ERP\Domain\Shared\Money;

final readonly class PricingResult
{
    public function __construct(
        public Money $subtotal,
        public Money $tax,
        public Money $serviceCharge,
        public Money $total,
    ) {}
}
