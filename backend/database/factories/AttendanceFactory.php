<?php

namespace Database\Factories;

use App\Models\Attendance;
use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

class AttendanceFactory extends Factory
{
    protected $model = Attendance::class;

    public function definition(): array
    {
        return [
            'student_id' => Student::factory(),
            'class_id' => ClassModel::factory(),
            'institute_id' => Institute::factory(),
            'date' => fake()->dateTimeBetween('-1 month', 'now'),
            'status' => fake()->randomElement(['present', 'absent', 'late']),
            'remarks' => fake()->optional()->sentence(),
        ];
    }

    public function present(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'present',
        ]);
    }

    public function absent(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'absent',
        ]);
    }

    public function late(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'late',
        ]);
    }
}
