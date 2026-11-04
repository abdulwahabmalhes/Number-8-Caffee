<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $admin = User::firstOrCreate(
            ['email' => 'admin@numbereight.com'],
            [
                'name' => 'Admin User',
                'password' => Hash::make('12345678'),
            ]
        );
        
        // Note: In Phase 1 we mentioned Spatie Permission, if we haven't assigned a role, 
        // they can at least log in if Filament allows all Users by default. 
        // Filament allows all by default unless User implements FilamentUser.
    }
}
