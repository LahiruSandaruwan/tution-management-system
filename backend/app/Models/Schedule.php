<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Schedule extends Model
{
    protected $fillable = [
        'institute_id',
        'class_id',
        'day_of_week',
        'start_time',
        'end_time',
        'room_number',
    ];

    protected $casts = [
        'start_time' => 'datetime:H:i',
        'end_time' => 'datetime:H:i',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function classModel(): BelongsTo
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function scopeForDay($query, string $day)
    {
        return $query->where('day_of_week', $day);
    }

    public function scopeToday($query)
    {
        return $query->where('day_of_week', now()->format('l'));
    }
}
