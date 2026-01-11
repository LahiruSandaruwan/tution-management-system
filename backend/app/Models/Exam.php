<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Exam extends Model
{
    use HasFactory;

    protected $fillable = [
        'institute_id',
        'class_id',
        'subject_id',
        'name',
        'exam_type',
        'description',
        'exam_date',
        'start_time',
        'end_time',
        'duration_minutes',
        'total_marks',
        'pass_marks',
        'status',
        'instructions',
    ];

    protected $casts = [
        'exam_date' => 'date',
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
        'total_marks' => 'decimal:2',
        'pass_marks' => 'decimal:2',
    ];

    // Relationships

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function classModel(): BelongsTo
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function grades(): HasMany
    {
        return $this->hasMany(Grade::class);
    }

    // Scopes

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled');
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', 'completed');
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', 'scheduled')
                     ->where('exam_date', '>=', now());
    }

    public function scopePast($query)
    {
        return $query->where('exam_date', '<', now());
    }

    public function scopeForClass($query, int $classId)
    {
        return $query->where('class_id', $classId);
    }

    public function scopeForSubject($query, int $subjectId)
    {
        return $query->where('subject_id', $subjectId);
    }

    // Helper methods

    public function isScheduled(): bool
    {
        return $this->status === 'scheduled';
    }

    public function isCompleted(): bool
    {
        return $this->status === 'completed';
    }

    public function isOngoing(): bool
    {
        return $this->status === 'ongoing';
    }

    public function isCancelled(): bool
    {
        return $this->status === 'cancelled';
    }

    public function isUpcoming(): bool
    {
        return $this->isScheduled() && $this->exam_date >= now();
    }

    public function isPast(): bool
    {
        return $this->exam_date < now();
    }

    /**
     * Get pass percentage
     */
    public function getPassPercentageAttribute(): float
    {
        if ($this->total_marks > 0 && $this->pass_marks) {
            return ($this->pass_marks / $this->total_marks) * 100;
        }

        return 0;
    }

    /**
     * Get total students appeared
     */
    public function getTotalStudentsAttribute(): int
    {
        return $this->grades()->distinct('student_id')->count();
    }

    /**
     * Get passed students count
     */
    public function getPassedStudentsAttribute(): int
    {
        if (!$this->pass_marks) {
            return 0;
        }

        return $this->grades()->where('marks', '>=', $this->pass_marks)->count();
    }

    /**
     * Get average marks
     */
    public function getAverageMarksAttribute(): float
    {
        return $this->grades()->avg('marks') ?? 0;
    }
}
