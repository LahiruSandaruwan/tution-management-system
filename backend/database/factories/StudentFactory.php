<?php

namespace Database\Factories;

use App\Models\Institute;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory()->student(),
            'institute_id' => Institute::factory(),
            'student_id_number' => 'STU' . fake()->unique()->numerify('######'),
            'grade' => fake()->randomElement(['Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'A/L']),
            'section' => fake()->randomElement(['A', 'B', 'C', 'D']),
            'admission_date' => fake()->dateTimeBetween('-2 years', 'now'),
            'address' => fake()->address(),
            'parent_name' => fake()->name(),
            'parent_phone' => fake()->phoneNumber(),
            'parent_email' => fake()->safeEmail(),
            'emergency_contact' => fake()->phoneNumber(),
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
            'user_id' => User::factory()->student()->state(['institute_id' => $institute->id]),
        ]);
    }
}
