<?php

namespace Tests\Feature;

use App\Models\Institute;
use App\Models\Payment;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaymentTest extends TestCase
{
    use RefreshDatabase;

    protected $admin;
    protected $student;
    protected $institute;

    protected function setUp(): void
    {
        parent::setUp();

        $this->institute = Institute::create([
            'name' => 'Test Institute',
            'code' => 'TEST001',
            'address' => 'Test Address',
            'phone' => '0771234567',
            'email' => 'test@institute.com',
            'status' => 'active',
        ]);

        $adminUser = User::create([
            'name' => 'Admin User',
            'email' => 'admin@test.com',
            'password' => bcrypt('password'),
            'role' => 'admin',
            'institute_id' => $this->institute->id,
        ]);

        $this->admin = $adminUser;

        $studentUser = User::create([
            'name' => 'Test Student',
            'email' => 'student@test.com',
            'password' => bcrypt('password'),
            'role' => 'student',
            'institute_id' => $this->institute->id,
        ]);

        $this->student = Student::create([
            'user_id' => $studentUser->id,
            'institute_id' => $this->institute->id,
            'student_id_number' => 'STU001',
            'grade' => 'Grade 10',
            'date_of_birth' => '2005-01-01',
            'status' => 'active',
        ]);
    }

    /** @test */
    public function admin_can_create_payment_record()
    {
        $token = $this->admin->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/payments', [
                'student_id' => $this->student->id,
                'amount' => 5000.00,
                'payment_type' => 'monthly_fee',
                'payment_method' => 'cash',
                'payment_date' => now()->format('Y-m-d'),
                'month' => now()->format('m'),
                'year' => now()->format('Y'),
                'status' => 'paid',
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'id',
                    'student_id',
                    'amount',
                    'status',
                ],
            ]);

        $this->assertDatabaseHas('payments', [
            'student_id' => $this->student->id,
            'amount' => 5000.00,
            'status' => 'paid',
        ]);
    }

    /** @test */
    public function can_get_student_payment_history()
    {
        Payment::create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'amount' => 5000.00,
            'payment_type' => 'monthly_fee',
            'payment_method' => 'cash',
            'payment_date' => now(),
            'due_date' => now()->addDays(30),
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
            'status' => 'paid',
        ]);

        $token = $this->admin->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson("/api/payments/student/{$this->student->id}");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['id', 'amount', 'status', 'payment_date'],
                ],
            ]);
    }

    /** @test */
    public function can_get_payment_defaulters_list()
    {
        // Create overdue payment
        Payment::create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'amount' => 5000.00,
            'payment_type' => 'monthly_fee',
            'payment_method' => 'cash',
            'payment_date' => now(),
            'due_date' => now()->subDays(5), // Overdue
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
            'status' => 'pending',
        ]);

        $token = $this->admin->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/payments/defaulters');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => ['student_id', 'pending_amount'],
                ],
            ]);
    }

    /** @test */
    public function can_get_payment_statistics()
    {
        Payment::create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'amount' => 5000.00,
            'payment_type' => 'monthly_fee',
            'payment_method' => 'cash',
            'payment_date' => now(),
            'due_date' => now()->addDays(30),
            'month' => now()->format('m'),
            'year' => now()->format('Y'),
            'status' => 'paid',
        ]);

        $token = $this->admin->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->getJson('/api/payments/statistics');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'total_collected',
                    'total_pending',
                    'total_overdue',
                ],
            ]);
    }

    /** @test */
    public function payment_creation_requires_valid_data()
    {
        $token = $this->admin->createToken('test-token')->plainTextToken;

        $response = $this->withHeader('Authorization', 'Bearer ' . $token)
            ->postJson('/api/payments', [
                'student_id' => 999999, // Invalid student
                'amount' => -100, // Negative amount
            ]);

        $response->assertStatus(422);
    }
}
