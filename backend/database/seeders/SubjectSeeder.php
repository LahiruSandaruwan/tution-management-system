<?php

namespace Database\Seeders;

use App\Models\Subject;
use Illuminate\Database\Seeder;

class SubjectSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $subjects = [
            ['name' => 'Mathematics', 'code' => 'MATH', 'description' => 'Advanced Mathematics for A/L'],
            ['name' => 'Physics', 'code' => 'PHY', 'description' => 'Physics for A/L Science Stream'],
            ['name' => 'Chemistry', 'code' => 'CHEM', 'description' => 'Chemistry for A/L Science Stream'],
            ['name' => 'Biology', 'code' => 'BIO', 'description' => 'Biology for A/L Science Stream'],
            ['name' => 'Combined Mathematics', 'code' => 'CMATH', 'description' => 'Combined Mathematics for A/L'],
            ['name' => 'ICT', 'code' => 'ICT', 'description' => 'Information and Communication Technology'],
        ];

        foreach ($subjects as $subject) {
            Subject::create(array_merge($subject, ['institute_id' => 1]));
        }
    }
}
