<?php

namespace App\Filament\Resources\Orders\Pages;

use App\Filament\Resources\Orders\OrderResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Schemas\Components\Tabs\Tab;
use Illuminate\Database\Eloquent\Builder;

class ListOrders extends ListRecords
{
    protected static string $resource = OrderResource::class;

    protected function getListeners(): array
    {
        return [
            'echo:orders,OrderCreated' => 'onOrderCreated',
            'echo:orders,OrderStatusUpdated' => '$refresh',
        ];
    }

    public function onOrderCreated()
    {
        \Filament\Notifications\Notification::make()
            ->title('New Order Received!')
            ->success()
            ->send();

        $this->dispatch('play-sound');
        $this->dispatch('$refresh');
    }

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make('All Orders'),
            'cashier' => Tab::make('Cashier (Pending)')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'pending')),
            'barista' => Tab::make('Barista (Preparing)')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'preparing')),
            'handover' => Tab::make('Handover (Ready)')
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', 'ready')),
        ];
    }
}
