<?php

namespace App\ERP\Domain\Payments;

use App\ERP\Domain\Shared\Money;
use DomainException;

final class PaymentVerifier
{
    public function assertMatches(
        VerifiedPayment $payment,
        string $expectedOrderReference,
        Money $expectedAmount,
    ): void {
        if ($payment->status !== 'paid') {
            throw new DomainException('Provider has not confirmed payment.');
        }

        if (! hash_equals($expectedOrderReference, $payment->orderReference)) {
            throw new DomainException('Payment order reference mismatch.');
        }

        if ($payment->amount != $expectedAmount) {
            throw new DomainException('Payment amount or currency mismatch.');
        }
    }
}
