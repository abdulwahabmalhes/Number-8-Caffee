<?php

namespace App\ERP\Domain\Accounting;

use InvalidArgumentException;

final readonly class JournalLine
{
    public function __construct(
        public string $accountCode,
        public int $debitMinor = 0,
        public int $creditMinor = 0,
    ) {
        if ($accountCode === '' || $debitMinor < 0 || $creditMinor < 0) {
            throw new InvalidArgumentException('Journal line values are invalid.');
        }

        if (($debitMinor === 0) === ($creditMinor === 0)) {
            throw new InvalidArgumentException('A journal line must contain exactly one positive side.');
        }
    }
}
