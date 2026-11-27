<?php

namespace Tests\Unit\ERP;

use App\ERP\Domain\Accounting\JournalEntry;
use App\ERP\Domain\Accounting\JournalLine;
use DomainException;
use PHPUnit\Framework\TestCase;

class JournalEntryTest extends TestCase
{
    public function test_accepts_balanced_double_entry_journal(): void
    {
        $entry = new JournalEntry('SALE-1001', [
            new JournalLine('1000-CASH', debitMinor: 10_500),
            new JournalLine('4000-SALES', creditMinor: 10_000),
            new JournalLine('2100-VAT', creditMinor: 500),
        ]);

        $this->assertCount(3, $entry->lines);
    }

    public function test_rejects_unbalanced_journal(): void
    {
        $this->expectException(DomainException::class);
        new JournalEntry('SALE-1002', [
            new JournalLine('1000-CASH', debitMinor: 10_000),
            new JournalLine('4000-SALES', creditMinor: 9_999),
        ]);
    }
}
