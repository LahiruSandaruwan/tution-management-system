<?php

namespace Database\Seeders;

use App\Models\Institute;
use Illuminate\Database\Seeder;

class InstituteSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Institute::create([
            'name' => 'Royal Institute of Technology',
            'address' => '123 Galle Road, Colombo 03, Sri Lanka',
            'phone' => '+94112345678',
            'email' => 'info@royaltech.lk',
            'website' => 'https://royaltech.lk',
            'logo' => null,
            'subscription_tier' => 'professional',
            'subscription_expires_at' => now()->addYear(),
            'is_active' => true,
        ]);

        Institute::create([
            'name' => 'Colombo Science Academy',
            'address' => '456 Kandy Road, Colombo 07, Sri Lanka',
            'phone' => '+94118765432',
            'email' => 'contact@scienceacademy.lk',
            'website' => 'https://scienceacademy.lk',
            'logo' => null,
            'subscription_tier' => 'growth',
            'subscription_expires_at' => now()->addMonths(6),
            'is_active' => true,
        ]);
    }
}
