<?php

namespace App\ERP\Domain\Accounting;

use DomainException;
use InvalidArgumentException;

final readonly class JournalEntry
{
    /** @param list<JournalLine> $lines */
    public function __construct(
        public string $reference,
        public array $lines,
        public string $currency = 'AED',
    ) {
        if ($reference === '' || count($lines) < 2) {
            throw new InvalidArgumentException('A journal entry requires a reference and at least two lines.');
        }

        $debits = array_sum(array_map(fn (JournalLine $line) => $line->debitMinor, $lines));
        $credits = array_sum(array_map(fn (JournalLine $line) => $line->creditMinor, $lines));
        if ($debits !== $credits) {
            throw new DomainException('Journal entry is not balanced.');
        }
    }
}
