<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class OrderInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('order_number'),
                TextEntry::make('branch_id')
                    ->numeric(),
                TextEntry::make('table_id')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('customer_id')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('order_type')->badge(),
                TextEntry::make('vehicle.plate_number')
                    ->label('Plate Number')
                    ->placeholder('-'),
                TextEntry::make('vehicle.vehicle_model')
                    ->label('Vehicle Model')
                    ->placeholder('-'),
                TextEntry::make('vehicle.vehicle_color')
                    ->label('Vehicle Color')
                    ->placeholder('-'),
                TextEntry::make('subtotal')
                    ->numeric(),
                TextEntry::make('tax_amount')
                    ->numeric(),
                TextEntry::make('discount_amount')
                    ->numeric(),
                TextEntry::make('grand_total')
                    ->numeric(),
                TextEntry::make('status'),
                TextEntry::make('payment_method')
                    ->placeholder('-'),
                TextEntry::make('payment_status'),
                TextEntry::make('notes')
                    ->placeholder('-')
                    ->columnSpanFull(),
                TextEntry::make('expected_arrival_time')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('customer_arrived_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('delivered_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('delivered_by')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('session_id')
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
