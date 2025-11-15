<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Grade extends Model
{
    protected $fillable = [
        'institute_id',
        'class_id',
        'student_id',
        'exam_type',
        'subject_id',
        'marks',
        'max_marks',
        'grade',
        'remarks',
        'exam_date',
    ];

    protected $casts = [
        'marks' => 'decimal:2',
        'max_marks' => 'decimal:2',
        'exam_date' => 'date',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function classModel(): BelongsTo
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function scopeByExamType($query, string $examType)
    {
        return $query->where('exam_type', $examType);
    }

    public function getPercentageAttribute(): float
    {
        if ($this->max_marks == 0) {
            return 0;
        }
        return ($this->marks / $this->max_marks) * 100;
    }
}
