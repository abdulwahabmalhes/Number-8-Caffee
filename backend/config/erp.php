<?php

return [
    'enabled' => env('ERP_ENABLED', false),
    'demo_mode' => env('ERP_DEMO_MODE', true),
    'permissions' => [
        'dashboard.view',
        'pos.use',
        'orders.void',
        'orders.refund',
        'discounts.override',
        'kitchen.view',
        'inventory.view',
        'inventory.receive',
        'inventory.adjust',
        'purchasing.approve',
        'accounting.view',
        'accounting.post',
        'accounting.close_period',
        'employees.manage',
        'reports.view',
        'reports.financial',
        'integrations.manage',
    ],
];
