<?php

namespace Database\Factories;

use App\Models\Teacher;
use App\Models\User;
use App\Models\Institute;
use Illuminate\Database\Eloquent\Factories\Factory;

class TeacherFactory extends Factory
{
    protected $model = Teacher::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->teacher(),
            'institute_id' => Institute::factory(),
            'subject_specialization' => fake()->randomElement([
                'Mathematics',
                'Science',
                'English',
                'Sinhala',
                'History',
                'ICT',
                'Commerce'
            ]),
            'qualification' => fake()->randomElement([
                'B.Sc. in Mathematics',
                'B.A. in English',
                'M.Sc. in Physics',
                'B.Ed. in Science',
                'Diploma in Teaching'
            ]),
            'date_of_birth' => fake()->dateTimeBetween('-50 years', '-25 years'),
            'address' => fake()->address(),
            'photo' => null,
            'is_active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }

    public function withInstitute(Institute $institute): static
    {
        return $this->state(fn (array $attributes) => [
            'institute_id' => $institute->id,
            'user_id' => User::factory()->teacher()->state(['institute_id' => $institute->id]),
        ]);
    }
}
