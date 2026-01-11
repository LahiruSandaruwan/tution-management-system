<?php

namespace Tests\Feature;

use App\Models\Institute;
use App\Models\Payment;
use App\Models\RfidCard;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RFIDVerificationTest extends TestCase
{
    use RefreshDatabase;

    protected $student;
    protected $institute;
    protected $rfidCard;

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

        $this->rfidCard = RfidCard::create([
            'institute_id' => $this->institute->id,
            'student_id' => $this->student->id,
            'card_uid' => 'RFID001',
            'issued_date' => now(),
            'status' => 'active',
        ]);
    }

    /** @test */
    public function rfid_gate_can_verify_valid_card_with_no_overdue_payments()
    {
        // Create a paid payment
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

        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'RFID001',
                'device_id' => 'GATE001',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'access_granted' => true,
            ])
            ->assertJsonStructure([
                'success',
                'access_granted',
                'student' => [
                    'name',
                    'student_id_number',
                    'grade',
                ],
            ]);
    }

    /** @test */
    public function rfid_gate_denies_access_for_overdue_payments()
    {
        // Create an overdue payment
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

        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'RFID001',
                'device_id' => 'GATE001',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'access_granted' => false,
                'reason' => 'Payment overdue',
            ]);
    }

    /** @test */
    public function rfid_gate_denies_access_for_inactive_card()
    {
        $this->rfidCard->update(['status' => 'inactive']);

        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'RFID001',
                'device_id' => 'GATE001',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'access_granted' => false,
                'reason' => 'Card is not active',
            ]);
    }

    /** @test */
    public function rfid_gate_denies_access_for_inactive_student()
    {
        $this->student->update(['status' => 'inactive']);

        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'RFID001',
                'device_id' => 'GATE001',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'access_granted' => false,
                'reason' => 'Student is not active',
            ]);
    }

    /** @test */
    public function rfid_gate_denies_access_for_invalid_card()
    {
        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'INVALID_CARD',
                'device_id' => 'GATE001',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'access_granted' => false,
                'reason' => 'Card not found',
            ]);
    }

    /** @test */
    public function rfid_gate_requires_valid_api_key()
    {
        $response = $this->withHeader('X-Gate-API-Key', 'invalid-key')
            ->postJson('/api/gate/verify', [
                'card_uid' => 'RFID001',
            ]);

        $response->assertStatus(401);
    }

    /** @test */
    public function rfid_gate_can_log_access()
    {
        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/log', [
                'card_uid' => 'RFID001',
                'action' => 'entry',
                'access_granted' => true,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseHas('gate_logs', [
            'card_uid' => 'RFID001',
            'access_type' => 'entry',
            'access_granted' => true,
        ]);
    }

    /** @test */
    public function rfid_gate_verification_requires_card_uid()
    {
        $response = $this->withHeader('X-Gate-API-Key', 'test-gate-api-key')
            ->postJson('/api/gate/verify', []);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['card_uid']);
    }
}
