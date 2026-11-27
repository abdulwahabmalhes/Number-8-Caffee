<?php

namespace App\ERP\Domain\Shared;

use InvalidArgumentException;

final readonly class Money
{
    public function __construct(
        public int $minorAmount,
        public string $currency = 'AED',
    ) {
        if ($minorAmount < 0) {
            throw new InvalidArgumentException('Money cannot be negative.');
        }

        if (! preg_match('/^[A-Z]{3}$/', $currency)) {
            throw new InvalidArgumentException('Currency must be a three-letter ISO code.');
        }
    }

    public function add(self $other): self
    {
        $this->assertSameCurrency($other);

        return new self($this->minorAmount + $other->minorAmount, $this->currency);
    }

    public function multiply(int $quantity): self
    {
        if ($quantity < 0) {
            throw new InvalidArgumentException('Quantity cannot be negative.');
        }

        return new self($this->minorAmount * $quantity, $this->currency);
    }

    private function assertSameCurrency(self $other): void
    {
        if ($this->currency !== $other->currency) {
            throw new InvalidArgumentException('Currency mismatch.');
        }
    }
}
