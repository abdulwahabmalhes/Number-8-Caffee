<?php

namespace App\ERP\Domain\Orders;

use App\ERP\Domain\Shared\Money;
use InvalidArgumentException;

final class PricingCalculator
{
    /** @param list<PricingLine> $lines */
    public function calculate(array $lines, int $taxBasisPoints = 0, ?Money $serviceCharge = null): PricingResult
    {
        if ($lines === []) {
            throw new InvalidArgumentException('An order requires at least one line.');
        }

        if ($taxBasisPoints < 0 || $taxBasisPoints > 10_000) {
            throw new InvalidArgumentException('Tax basis points must be between 0 and 10000.');
        }

        $currency = $lines[0]->unitPrice->currency;
        $subtotal = new Money(0, $currency);

        foreach ($lines as $line) {
            $unit = $line->unitPrice;
            foreach ($line->modifiers as $modifier) {
                $unit = $unit->add($modifier);
            }
            $subtotal = $subtotal->add($unit->multiply($line->quantity));
        }

        $serviceCharge ??= new Money(0, $currency);
        $tax = new Money((int) round($subtotal->minorAmount * $taxBasisPoints / 10_000), $currency);
        $total = $subtotal->add($tax)->add($serviceCharge);

        return new PricingResult($subtotal, $tax, $serviceCharge, $total);
    }
}
