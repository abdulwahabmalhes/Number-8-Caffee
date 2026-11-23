<?php

namespace Tests\Unit\ERP;

use App\ERP\Domain\Payments\PaymentVerifier;
use App\ERP\Domain\Payments\VerifiedPayment;
use App\ERP\Domain\Shared\Money;
use DomainException;
use PHPUnit\Framework\TestCase;

class PaymentVerifierTest extends TestCase
{
    public function test_accepts_only_provider_confirmed_matching_payment(): void
    {
        (new PaymentVerifier)->assertMatches(
            new VerifiedPayment('pi_123', 'ERP-1001', new Money(2_500), 'paid'),
            'ERP-1001',
            new Money(2_500),
        );

        $this->addToAssertionCount(1);
    }

    public function test_rejects_client_or_provider_amount_mismatch(): void
    {
        $this->expectException(DomainException::class);
        (new PaymentVerifier)->assertMatches(
            new VerifiedPayment('pi_123', 'ERP-1001', new Money(1), 'paid'),
            'ERP-1001',
            new Money(2_500),
        );
    }
}
