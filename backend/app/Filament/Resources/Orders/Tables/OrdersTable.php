<?php

namespace App\Filament\Resources\Orders\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class OrdersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('order_number')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                TextColumn::make('order_type')
                    ->label('Type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'table' => 'primary',
                        'car' => 'warning',
                        default => 'gray',
                    }),
                TextColumn::make('branch.name_en')
                    ->label('Branch')
                    ->sortable(),
                TextColumn::make('table.table_number')
                    ->label('Table')
                    ->sortable()
                    ->badge(),
                TextColumn::make('vehicle.plate_number')
                    ->label('Vehicle')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'pending' => 'warning',
                        'preparing' => 'primary',
                        'ready' => 'success',
                        'completed' => 'gray',
                        'cancelled' => 'danger',
                        default => 'gray',
                    })
                    ->searchable(),
                TextColumn::make('grand_total')
                    ->numeric()
                    ->money('AED')
                    ->sortable(),
                TextColumn::make('payment_status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'unpaid' => 'danger',
                        'paid' => 'success',
                        default => 'gray',
                    }),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: false),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->recordActions([
                \Filament\Actions\Action::make('accept')
                    ->label('Accept')
                    ->color('primary')
                    ->icon('heroicon-o-check-circle')
                    ->visible(fn (\App\Models\Order $record) => $record->status === 'pending')
                    ->action(function (\App\Models\Order $record) {
                        $record->update(['status' => 'preparing']);
                        event(new \App\Events\OrderStatusUpdated($record));
                    }),
                \Filament\Actions\Action::make('ready')
                    ->label('Mark Ready')
                    ->color('success')
                    ->icon('heroicon-o-sparkles')
                    ->visible(fn (\App\Models\Order $record) => $record->status === 'preparing')
                    ->action(function (\App\Models\Order $record) {
                        $record->update(['status' => 'ready']);
                        event(new \App\Events\OrderStatusUpdated($record));
                    }),
                \Filament\Actions\Action::make('complete')
                    ->label('Complete')
                    ->color('gray')
                    ->icon('heroicon-o-check')
                    ->visible(fn (\App\Models\Order $record) => $record->status === 'ready')
                    ->action(function (\App\Models\Order $record) {
                        $record->update(['status' => 'delivered']);
                        event(new \App\Events\OrderStatusUpdated($record));
                    }),
                \Filament\Actions\ViewAction::make(),
                \Filament\Actions\EditAction::make(),
            ])
            ->toolbarActions([
                \Filament\Actions\BulkActionGroup::make([
                    \Filament\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}
