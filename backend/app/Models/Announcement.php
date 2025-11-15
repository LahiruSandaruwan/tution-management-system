<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Announcement extends Model
{
    protected $fillable = [
        'institute_id',
        'title',
        'content',
        'target_audience',
        'class_id',
        'priority',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function classModel(): BelongsTo
    {
        return $this->belongsTo(ClassModel::class, 'class_id');
    }

    public function scopeForAudience($query, string $audience)
    {
        return $query->where('target_audience', $audience);
    }

    public function scopeHighPriority($query)
    {
        return $query->where('priority', 'high');
    }

    public function scopeRecent($query)
    {
        return $query->latest('created_at')->limit(10);
    }
}
