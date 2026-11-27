<?php

namespace Tests\Unit\ERP;

use App\ERP\Domain\Authorization\BranchAccess;
use PHPUnit\Framework\TestCase;

class BranchAccessTest extends TestCase
{
    public function test_staff_access_is_restricted_to_assigned_branches(): void
    {
        $access = new BranchAccess;
        $this->assertTrue($access->allows(2, [1, 2]));
        $this->assertFalse($access->allows(3, [1, 2]));
        $this->assertTrue($access->allows(3, [], true));
    }
}
