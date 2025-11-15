<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\ClassModel;
use App\Models\Student;

class ClassSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create classes
        $mathClass = ClassModel::create([
            'institute_id' => 1,
            'name' => 'Advanced Mathematics - Grade 11',
            'subject_id' => 1, // Mathematics
            'teacher_id' => 1, // Nimal Perera
            'grade' => 'Grade 11',
            'schedule' => 'Monday & Wednesday 4:00 PM - 6:00 PM',
            'max_students' => 30,
            'is_active' => true,
        ]);

        $physicsClass = ClassModel::create([
            'institute_id' => 1,
            'name' => 'Physics - Grade 11',
            'subject_id' => 2, // Physics
            'teacher_id' => 2, // Kumari Silva
            'grade' => 'Grade 11',
            'schedule' => 'Tuesday & Thursday 4:00 PM - 6:00 PM',
            'max_students' => 30,
            'is_active' => true,
        ]);

        $mathClassG12 = ClassModel::create([
            'institute_id' => 1,
            'name' => 'Advanced Mathematics - Grade 12',
            'subject_id' => 1, // Mathematics
            'teacher_id' => 1, // Nimal Perera
            'grade' => 'Grade 12',
            'schedule' => 'Tuesday & Friday 6:00 PM - 8:00 PM',
            'max_students' => 25,
            'is_active' => true,
        ]);

        // Enroll students in classes
        $students = Student::where('institute_id', 1)->get();

        foreach ($students as $student) {
            if ($student->grade === 'Grade 11') {
                // Enroll Grade 11 students in Math and Physics
                $mathClass->students()->attach($student->id, ['enrolled_date' => now()]);
                $physicsClass->students()->attach($student->id, ['enrolled_date' => now()]);
            } elseif ($student->grade === 'Grade 12') {
                // Enroll Grade 12 students in Math G12
                $mathClassG12->students()->attach($student->id, ['enrolled_date' => now()]);
            }
        }
    }
}
