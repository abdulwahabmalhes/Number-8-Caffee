<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class OrderForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('order_number')
                    ->required(),
                TextInput::make('branch_id')
                    ->required()
                    ->numeric(),
                TextInput::make('table_id')
                    ->numeric()
                    ->default(null),
                TextInput::make('customer_id')
                    ->numeric()
                    ->default(null),
                TextInput::make('vehicle_id')
                    ->numeric()
                    ->default(null),
                TextInput::make('order_type')
                    ->required()
                    ->default('table'),
                TextInput::make('subtotal')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('tax_amount')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('discount_amount')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('grand_total')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('status')
                    ->required()
                    ->default('new'),
                TextInput::make('payment_method')
                    ->default(null),
                TextInput::make('payment_status')
                    ->required()
                    ->default('pending'),
                Textarea::make('notes')
                    ->default(null)
                    ->columnSpanFull(),
                DateTimePicker::make('expected_arrival_time'),
                DateTimePicker::make('customer_arrived_at'),
                DateTimePicker::make('delivered_at'),
                TextInput::make('delivered_by')
                    ->numeric()
                    ->default(null),
                TextInput::make('session_id')
                    ->default(null),
            ]);
    }
}
