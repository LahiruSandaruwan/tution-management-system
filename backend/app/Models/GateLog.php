<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GateLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'institute_id',
        'rfid_card_id',
        'student_id',
        'action',
        'status',
        'reason',
        'timestamp',
        'created_at',
    ];

    protected $casts = [
        'timestamp' => 'datetime',
        'created_at' => 'datetime',
    ];

    public function institute(): BelongsTo
    {
        return $this->belongsTo(Institute::class);
    }

    public function rfidCard(): BelongsTo
    {
        return $this->belongsTo(RfidCard::class);
    }

    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    public function scopeSuccessful($query)
    {
        return $query->where('status', 'success');
    }

    public function scopeDenied($query)
    {
        return $query->where('status', 'denied');
    }

    public function scopeToday($query)
    {
        return $query->whereDate('timestamp', today());
    }
}
