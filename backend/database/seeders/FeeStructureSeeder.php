<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\FeeStructure;

class FeeStructureSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $feeStructures = [
            [
                'grade' => 'Grade 10',
                'monthly_fee' => 5000.00,
                'registration_fee' => 2000.00,
                'description' => 'Monthly fee for Grade 10 students',
            ],
            [
                'grade' => 'Grade 11',
                'monthly_fee' => 6000.00,
                'registration_fee' => 2500.00,
                'description' => 'Monthly fee for Grade 11 students (A/L First Year)',
            ],
            [
                'grade' => 'Grade 12',
                'monthly_fee' => 7000.00,
                'registration_fee' => 2500.00,
                'description' => 'Monthly fee for Grade 12 students (A/L Second Year)',
            ],
            [
                'grade' => 'Grade 13',
                'monthly_fee' => 8000.00,
                'registration_fee' => 3000.00,
                'description' => 'Monthly fee for Grade 13 students (A/L Final Year)',
            ],
        ];

        foreach ($feeStructures as $fee) {
            FeeStructure::create(array_merge($fee, [
                'institute_id' => 1,
                'is_active' => true,
            ]));
        }
    }
}
