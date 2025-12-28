<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ClassModel extends Model
{
    protected $table = 'classes';

    protected $fillable = [
        'institute_id',
        'subject_id',
        'teacher_id',
        'name',
        'grade',
        'section',
        'room_number',
        'capacity',
        'day_of_week',
        'start_time',
        'end_time',
        'monthly_fee',
        'description',
        'is_active',
    ];

    protected $casts = [
        'capacity' => 'integer',
        'monthly_fee' => 'decimal:2',
        'is_active' => 'boolean',
    ];

    protected $appends = ['students_count', 'max_students'];

    public function getStudentsCountAttribute()
    {
        return $this->students()->count();
    }

    public function getMaxStudentsAttribute()
    {
        return $this->capacity;
    }

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function teacher(): BelongsTo
    {
        return $this->belongsTo(Teacher::class);
    }

    public function students(): BelongsToMany
    {
        return $this->belongsToMany(Student::class, 'class_student', 'class_id', 'student_id')
            ->withPivot('enrolled_date');
    }

    public function attendances(): HasMany
    {
        return $this->hasMany(Attendance::class, 'class_id');
    }

    public function schedules(): HasMany
    {
        return $this->hasMany(Schedule::class, 'class_id');
    }

    public function grades(): HasMany
    {
        return $this->hasMany(Grade::class, 'class_id');
    }

    public function announcements(): HasMany
    {
        return $this->hasMany(Announcement::class, 'class_id');
    }

    public function scopeByGrade($query, string $grade)
    {
        return $query->where('grade', $grade);
    }

    public function isFull(): bool
    {
        return $this->students()->count() >= $this->capacity;
    }
}
