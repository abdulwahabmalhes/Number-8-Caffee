<?php

namespace Tests\Unit\ERP;

use App\ERP\Domain\Orders\PricingCalculator;
use App\ERP\Domain\Orders\PricingLine;
use App\ERP\Domain\Shared\Money;
use PHPUnit\Framework\TestCase;

class PricingCalculatorTest extends TestCase
{
    public function test_prices_products_modifiers_tax_and_service_charge_in_minor_units(): void
    {
        $result = (new PricingCalculator)->calculate([
            new PricingLine('latte', new Money(1_500), 2, [new Money(300)]),
            new PricingLine('cookie', new Money(800), 1),
        ], taxBasisPoints: 500, serviceCharge: new Money(200));

        $this->assertSame(4_400, $result->subtotal->minorAmount);
        $this->assertSame(220, $result->tax->minorAmount);
        $this->assertSame(4_820, $result->total->minorAmount);
    }
}
