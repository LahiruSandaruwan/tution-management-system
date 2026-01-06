<?php

namespace Database\Factories;

use App\Models\ClassModel;
use App\Models\Teacher;
use App\Models\Institute;
use Illuminate\Database\Eloquent\Factories\Factory;

class ClassModelFactory extends Factory
{
    protected $model = ClassModel::class;

    public function definition(): array
    {
        $subjects = ['Mathematics', 'Science', 'English', 'Sinhala', 'History', 'ICT', 'Commerce'];
        $grades = ['Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10', 'Grade 11', 'A/L'];

        return [
            'institute_id' => Institute::factory(),
            'teacher_id' => Teacher::factory(),
            'subject' => fake()->randomElement($subjects),
            'grade' => fake()->randomElement($grades),
            'class_fee' => fake()->randomFloat(2, 500, 5000),
            'schedule_day' => fake()->randomElement(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']),
            'schedule_time' => fake()->time('H:i:s'),
            'duration_minutes' => fake()->randomElement([60, 90, 120, 180]),
            'max_students' => fake()->numberBetween(10, 50),
            'room_number' => 'Room ' . fake()->numberBetween(1, 20),
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
            'teacher_id' => Teacher::factory()->withInstitute($institute),
        ]);
    }
}
