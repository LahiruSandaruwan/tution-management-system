<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GateDevice extends Model
{
    protected $fillable = [
        'institute_id',
        'device_id',
        'name',
        'location',
        'api_key',
        'is_active',
        'last_seen',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'last_seen' => 'datetime',
    ];

    protected $hidden = [
        'api_key',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function isOnline(): bool
    {
        return $this->last_seen && $this->last_seen->diffInMinutes(now()) < 5;
    }
}
