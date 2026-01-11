<?php

namespace Database\Factories;

use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

class PaymentFactory extends Factory
{
    protected $model = Payment::class;

    public function definition(): array
    {
        $dueDate = fake()->dateTimeBetween('-2 months', '+1 month');
        $paidDate = fake()->boolean(70) ? fake()->dateTimeBetween($dueDate, 'now') : null;

        return [
            'student_id' => Student::factory(),
            'class_id' => ClassModel::factory(),
            'institute_id' => Institute::factory(),
            'amount' => fake()->randomFloat(2, 500, 5000),
            'due_date' => $dueDate,
            'paid_date' => $paidDate,
            'payment_method' => $paidDate ? fake()->randomElement(['cash', 'card', 'bank_transfer', 'online']) : null,
            'status' => $paidDate ? 'paid' : 'pending',
            'month' => $dueDate->format('m'),
            'year' => $dueDate->format('Y'),
            'received_by' => $paidDate ? User::factory()->admin() : null,
            'remarks' => fake()->optional()->sentence(),
        ];
    }

    public function pending(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'paid_date' => null,
            'payment_method' => null,
            'received_by' => null,
        ]);
    }

    public function paid(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'paid',
            'paid_date' => fake()->dateTimeBetween('-1 month', 'now'),
            'payment_method' => fake()->randomElement(['cash', 'card', 'bank_transfer', 'online']),
            'received_by' => User::factory()->admin(),
        ]);
    }

    public function overdue(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'pending',
            'due_date' => fake()->dateTimeBetween('-2 months', '-1 day'),
            'paid_date' => null,
            'payment_method' => null,
            'received_by' => null,
        ]);
    }
}
