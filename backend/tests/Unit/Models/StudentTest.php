<?php

namespace Tests\Unit\Models;

use App\Models\ClassModel;
use App\Models\Institute;
use App\Models\Student;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class StudentTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_belongs_to_user(): void
    {
        $student = Student::factory()->create();

        $this->assertInstanceOf(User::class, $student->user);
    }

    public function test_student_belongs_to_institute(): void
    {
        $student = Student::factory()->create();

        $this->assertInstanceOf(Institute::class, $student->institute);
    }

    public function test_student_can_have_many_classes(): void
    {
        $student = Student::factory()->create();
        $class = ClassModel::factory()->create(['institute_id' => $student->institute_id]);

        $student->classes()->attach($class->id);

        $this->assertCount(1, $student->classes);
        $this->assertInstanceOf(ClassModel::class, $student->classes->first());
    }

    public function test_student_has_fillable_attributes(): void
    {
        $fillable = [
            'user_id',
            'institute_id',
            'student_id_number',
            'grade',
            'date_of_birth',
            'address',
            'parent_name',
            'parent_phone',
            'photo',
            'is_active',
        ];

        $student = new Student();

        $this->assertEquals($fillable, $student->getFillable());
    }

    public function test_student_can_be_active_or_inactive(): void
    {
        $activeStudent = Student::factory()->create(['is_active' => true]);
        $inactiveStudent = Student::factory()->inactive()->create();

        $this->assertTrue($activeStudent->is_active);
        $this->assertFalse($inactiveStudent->is_active);
    }

    public function test_student_id_number_is_unique(): void
    {
        $student1 = Student::factory()->create(['student_id_number' => 'STU001']);

        $this->expectException(\Illuminate\Database\QueryException::class);
        Student::factory()->create(['student_id_number' => 'STU001']);
    }
}
