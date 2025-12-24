<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Models\Institute;
use App\Models\Teacher;
use App\Models\Student;
use App\Models\ClassModel;
use App\Models\Payment;
use App\Models\RfidCard;
use Illuminate\Support\Facades\Hash;

echo "Creating Test Data...\n\n";

// Get existing institute
$institute = Institute::first();
if (!$institute) {
    $institute = Institute::create([
        'name' => 'Demo Institute',
        'address' => '123 Main Street, Colombo',
        'phone' => '+94112345678',
        'email' => 'info@demo.institute.lk',
        'is_active' => true,
    ]);
}
echo "✓ Institute ready\n";

// Recreate admin if needed
$admin = User::where('email', 'admin@institute.com')->first();
if (!$admin) {
    $admin = User::create([
        'name' => 'Admin User',
        'email' => 'admin@institute.com',
        'password' => Hash::make('admin123'),
        'role' => 'admin',
        'phone' => '+94771234567',
        'institute_id' => $institute->id,
    ]);
}
echo "✓ Admin user ready\n";

// Create Teachers
echo "\nCreating Teachers...\n";
$subjects = ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'ICT'];
$teachers = [];

for ($i = 1; $i <= 5; $i++) {
    $teacherUser = User::where('email', "teacher{$i}@institute.com")->first();
    if (!$teacherUser) {
        $teacherUser = User::create([
            'name' => "Mr. Teacher {$i}",
            'email' => "teacher{$i}@institute.com",
            'password' => Hash::make('teacher123'),
            'role' => 'teacher',
            'phone' => '+9477' . str_pad($i, 7, '0', STR_PAD_LEFT),
            'institute_id' => $institute->id,
        ]);

        $teacher = Teacher::create([
            'user_id' => $teacherUser->id,
            'institute_id' => $institute->id,
            'employee_id' => 'T' . str_pad($i, 4, '0', STR_PAD_LEFT),
            'subject' => $subjects[$i - 1],
            'qualification' => 'BSc in ' . $subjects[$i - 1],
            'joined_date' => now()->subMonths(rand(1, 24))->format('Y-m-d'),
            'is_active' => true,
        ]);

        $teachers[] = $teacher;
        echo "  ✓ Created {$teacherUser->name} ({$subjects[$i - 1]})\n";
    }
}

// Create Classes
echo "\nCreating Classes...\n";
$grades = ['Grade 10', 'Grade 11', 'Grade 12', 'Grade 13'];
$classes = [];

foreach ($subjects as $index => $subject) {
    foreach ($grades as $grade) {
        $className = "{$subject} - {$grade}";
        $class = ClassModel::where('name', $className)->where('institute_id', $institute->id)->first();

        if (!$class) {
            $teacher = Teacher::where('subject', $subject)->where('institute_id', $institute->id)->first();

            $class = ClassModel::create([
                'name' => $className,
                'subject' => $subject,
                'grade' => $grade,
                'teacher_id' => $teacher ? $teacher->id : null,
                'institute_id' => $institute->id,
                'day_of_week' => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][rand(0, 4)],
                'start_time' => ['08:00', '10:00', '14:00', '16:00'][rand(0, 3)],
                'end_time' => ['09:30', '11:30', '15:30', '17:30'][rand(0, 3)],
                'monthly_fee' => rand(2000, 5000),
                'max_students' => rand(20, 30),
                'is_active' => true,
            ]);

            $classes[] = $class;
            echo "  ✓ Created {$className}\n";
        }
    }
}

// Create Students
echo "\nCreating Students...\n";
for ($i = 1; $i <= 20; $i++) {
    $studentUser = User::where('email', "student{$i}@test.com")->first();
    if (!$studentUser) {
        $studentUser = User::create([
            'name' => "Student {$i}",
            'email' => "student{$i}@test.com",
            'password' => Hash::make('student123'),
            'role' => 'student',
            'phone' => '+9476' . str_pad($i, 7, '0', STR_PAD_LEFT),
            'institute_id' => $institute->id,
        ]);

        $grade = $grades[array_rand($grades)];
        $student = Student::create([
            'user_id' => $studentUser->id,
            'institute_id' => $institute->id,
            'student_id_number' => 'S' . str_pad($i, 5, '0', STR_PAD_LEFT),
            'grade' => $grade,
            'date_of_birth' => now()->subYears(rand(15, 18))->format('Y-m-d'),
            'address' => "Address {$i}, Colombo",
            'parent_name' => "Parent of Student {$i}",
            'parent_phone' => '+9471' . str_pad($i, 7, '0', STR_PAD_LEFT),
            'enrolled_date' => now()->subMonths(rand(1, 12))->format('Y-m-d'),
            'is_active' => rand(0, 9) > 0, // 90% active
        ]);

        // Create RFID card
        RfidCard::create([
            'card_number' => str_pad($i, 10, '0', STR_PAD_LEFT),
            'student_id' => $student->id,
            'institute_id' => $institute->id,
            'is_active' => true,
            'issued_date' => now()->subMonths(rand(1, 12))->format('Y-m-d'),
        ]);

        // Enroll in 2-3 random classes of their grade
        $gradeClasses = ClassModel::where('grade', $grade)->where('institute_id', $institute->id)->get();
        $selectedClasses = $gradeClasses->random(min(rand(2, 3), $gradeClasses->count()));

        foreach ($selectedClasses as $class) {
            $student->classes()->attach($class->id, [
                'enrolled_date' => now()->subMonths(rand(1, 6))->format('Y-m-d'),
            ]);
        }

        echo "  ✓ Created {$studentUser->name} ({$grade})\n";
    }
}

// Create Payments
echo "\nCreating Payments...\n";
$students = Student::with('classes')->where('institute_id', $institute->id)->get();
$paymentCount = 0;

foreach ($students as $student) {
    foreach ($student->classes as $class) {
        // Create payments for last 3 months
        for ($month = 2; $month >= 0; $month--) {
            $date = now()->subMonths($month);
            $status = $month == 0 ? (rand(0, 1) ? 'paid' : 'pending') : 'paid';

            Payment::create([
                'student_id' => $student->id,
                'class_id' => $class->id,
                'institute_id' => $institute->id,
                'amount' => $class->monthly_fee,
                'month' => $date->format('F'),
                'year' => $date->year,
                'due_date' => $date->startOfMonth()->addDays(10)->format('Y-m-d'),
                'paid_date' => $status == 'paid' ? $date->startOfMonth()->addDays(rand(1, 15))->format('Y-m-d') : null,
                'status' => $status,
                'payment_method' => $status == 'paid' ? ['cash', 'bank_transfer', 'online'][rand(0, 2)] : null,
            ]);

            $paymentCount++;
        }
    }
}
echo "  ✓ Created {$paymentCount} payment records\n";

echo "\n==============================================\n";
echo "✅ Test Data Creation Complete!\n";
echo "==============================================\n\n";
echo "Summary:\n";
echo "  - Institute: {$institute->name}\n";
echo "  - Teachers: " . Teacher::where('institute_id', $institute->id)->count() . "\n";
echo "  - Students: " . Student::where('institute_id', $institute->id)->count() . "\n";
echo "  - Classes: " . ClassModel::where('institute_id', $institute->id)->count() . "\n";
echo "  - Payments: {$paymentCount}\n";
echo "\nLogin Credentials:\n";
echo "  Admin: admin@institute.com / admin123\n";
echo "  Teachers: teacher1@institute.com / teacher123 (teacher1-5)\n";
echo "  Students: student1@test.com / student123 (student1-20)\n";
echo "\n";
