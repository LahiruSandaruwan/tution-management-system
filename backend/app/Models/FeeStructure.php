<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FeeStructure extends Model
{
    protected $fillable = [
        'institute_id',
        'grade',
        'subject_id',
        'monthly_fee',
        'registration_fee',
    ];

    protected $casts = [
        'monthly_fee' => 'decimal:2',
        'registration_fee' => 'decimal:2',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function subject(): BelongsTo
    {
        return $this->belongsTo(Subject::class);
    }

    public function scopeByGrade($query, string $grade)
    {
        return $query->where('grade', $grade);
    }
}
