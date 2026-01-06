<?php

namespace Tests\Unit\Models;

use App\Models\Teacher;
use App\Models\User;
use App\Models\Institute;
use App\Models\ClassModel;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TeacherTest extends TestCase
{
    use RefreshDatabase;

    public function test_teacher_belongs_to_user(): void
    {
        $teacher = Teacher::factory()->create();

        $this->assertInstanceOf(User::class, $teacher->user);
    }

    public function test_teacher_belongs_to_institute(): void
    {
        $teacher = Teacher::factory()->create();

        $this->assertInstanceOf(Institute::class, $teacher->institute);
    }

    public function test_teacher_can_have_many_classes(): void
    {
        $teacher = Teacher::factory()->create();
        $class = ClassModel::factory()->create([
            'institute_id' => $teacher->institute_id,
            'teacher_id' => $teacher->id
        ]);

        $this->assertCount(1, $teacher->classes);
        $this->assertInstanceOf(ClassModel::class, $teacher->classes->first());
    }

    public function test_teacher_has_fillable_attributes(): void
    {
        $fillable = [
            'user_id',
            'institute_id',
            'subject_specialization',
            'qualification',
            'date_of_birth',
            'address',
            'photo',
            'is_active',
        ];

        $teacher = new Teacher();

        $this->assertEquals($fillable, $teacher->getFillable());
    }

    public function test_teacher_can_be_active_or_inactive(): void
    {
        $activeTeacher = Teacher::factory()->create(['is_active' => true]);
        $inactiveTeacher = Teacher::factory()->inactive()->create();

        $this->assertTrue($activeTeacher->is_active);
        $this->assertFalse($inactiveTeacher->is_active);
    }

    public function test_teacher_has_subject_specialization(): void
    {
        $teacher = Teacher::factory()->create(['subject_specialization' => 'Mathematics']);

        $this->assertEquals('Mathematics', $teacher->subject_specialization);
    }
}
