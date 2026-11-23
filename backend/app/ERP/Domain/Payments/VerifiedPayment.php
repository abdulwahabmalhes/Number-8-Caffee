<?php

namespace App\ERP\Domain\Payments;

use App\ERP\Domain\Shared\Money;

final readonly class VerifiedPayment
{
    public function __construct(
        public string $providerReference,
        public string $orderReference,
        public Money $amount,
        public string $status,
    ) {}
}
