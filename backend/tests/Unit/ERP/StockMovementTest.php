<?php

namespace Tests\Unit\ERP;

use App\ERP\Domain\Inventory\StockMovement;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

class StockMovementTest extends TestCase
{
    public function test_movement_requires_non_zero_quantity_and_idempotency_key(): void
    {
        $movement = new StockMovement('beans', 'main-store', 'receipt', 1_000_000, 'grn-1001-line-1');
        $this->assertSame('grn-1001-line-1', $movement->idempotencyKey);

        $this->expectException(InvalidArgumentException::class);
        new StockMovement('beans', 'main-store', 'receipt', 0, 'bad');
    }
}
