<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\RfidCard;
use App\Models\GateDevice;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create Admin User for Institute 1
        $admin = User::create([
            'name' => 'Admin User',
            'email' => 'admin@royaltech.lk',
            'password' => Hash::make('password123'),
            'phone' => '+94771234567',
            'role' => 'admin',
            'institute_id' => 1,
        ]);

        // Create Teachers for Institute 1
        $teacher1 = User::create([
            'name' => 'Nimal Perera',
            'email' => 'nimal@royaltech.lk',
            'password' => Hash::make('password123'),
            'phone' => '+94772345678',
            'role' => 'teacher',
            'institute_id' => 1,
        ]);

        Teacher::create([
            'user_id' => $teacher1->id,
            'institute_id' => 1,
            'subject_specialization' => 'Mathematics',
            'qualification' => 'BSc in Mathematics, MSc in Applied Mathematics',
            'is_active' => true,
        ]);

        $teacher2 = User::create([
            'name' => 'Kumari Silva',
            'email' => 'kumari@royaltech.lk',
            'password' => Hash::make('password123'),
            'phone' => '+94773456789',
            'role' => 'teacher',
            'institute_id' => 1,
        ]);

        Teacher::create([
            'user_id' => $teacher2->id,
            'institute_id' => 1,
            'subject_specialization' => 'Physics',
            'qualification' => 'BSc in Physics, PhD in Quantum Physics',
            'is_active' => true,
        ]);

        // Create Students for Institute 1
        $students = [
            [
                'name' => 'Kasun Rajapaksa',
                'email' => 'kasun@example.com',
                'phone' => '+94774567890',
                'student_id_number' => 'STU001',
                'grade' => 'Grade 11',
                'parent_name' => 'Mr. Rajapaksa',
                'parent_phone' => '+94775678901',
                'rfid_uid' => 'RFID001',
            ],
            [
                'name' => 'Sanduni Fernando',
                'email' => 'sanduni@example.com',
                'phone' => '+94776789012',
                'student_id_number' => 'STU002',
                'grade' => 'Grade 11',
                'parent_name' => 'Mrs. Fernando',
                'parent_phone' => '+94777890123',
                'rfid_uid' => 'RFID002',
            ],
            [
                'name' => 'Tharindu Wickramasinghe',
                'email' => 'tharindu@example.com',
                'phone' => '+94778901234',
                'student_id_number' => 'STU003',
                'grade' => 'Grade 12',
                'parent_name' => 'Mr. Wickramasinghe',
                'parent_phone' => '+94779012345',
                'rfid_uid' => 'RFID003',
            ],
            [
                'name' => 'Nethmi Gunasekara',
                'email' => 'nethmi@example.com',
                'phone' => '+94770123456',
                'student_id_number' => 'STU004',
                'grade' => 'Grade 12',
                'parent_name' => 'Mrs. Gunasekara',
                'parent_phone' => '+94771234560',
                'rfid_uid' => 'RFID004',
            ],
            [
                'name' => 'Dilan Abeysekara',
                'email' => 'dilan@example.com',
                'phone' => '+94772345670',
                'student_id_number' => 'STU005',
                'grade' => 'Grade 10',
                'parent_name' => 'Mr. Abeysekara',
                'parent_phone' => '+94773456701',
                'rfid_uid' => 'RFID005',
            ],
        ];

        foreach ($students as $studentData) {
            $user = User::create([
                'name' => $studentData['name'],
                'email' => $studentData['email'],
                'password' => Hash::make('password123'),
                'phone' => $studentData['phone'],
                'role' => 'student',
                'institute_id' => 1,
            ]);

            $student = Student::create([
                'user_id' => $user->id,
                'institute_id' => 1,
                'student_id_number' => $studentData['student_id_number'],
                'grade' => $studentData['grade'],
                'parent_name' => $studentData['parent_name'],
                'parent_phone' => $studentData['parent_phone'],
                'is_active' => true,
            ]);

            // Create RFID card for student
            RfidCard::create([
                'student_id' => $student->id,
                'card_uid' => $studentData['rfid_uid'],
                'status' => 'active',
                'issued_date' => now(),
            ]);
        }

        // Create Gate Device for Institute 1
        GateDevice::create([
            'institute_id' => 1,
            'device_name' => 'Main Entrance Gate',
            'device_id' => 'GATE001',
            'api_key' => 'gate_' . bin2hex(random_bytes(16)),
            'is_active' => true,
            'last_seen' => now(),
        ]);
    }
}
