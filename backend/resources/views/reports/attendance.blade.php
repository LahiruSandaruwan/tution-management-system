<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Attendance Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.6;
            color: #333;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #4A5568;
            padding-bottom: 20px;
        }
        .header h1 {
            color: #2D3748;
            margin: 0;
            font-size: 24px;
        }
        .header h2 {
            color: #4A5568;
            margin: 5px 0;
            font-size: 18px;
            font-weight: normal;
        }
        .info-section {
            margin-bottom: 20px;
        }
        .info-section p {
            margin: 5px 0;
        }
        .stats-section {
            background-color: #F7FAFC;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
        .stats-grid {
            display: table;
            width: 100%;
            margin-top: 10px;
        }
        .stat-item {
            display: table-cell;
            padding: 10px;
            text-align: center;
            width: 25%;
        }
        .stat-label {
            font-size: 10px;
            color: #718096;
            text-transform: uppercase;
            margin-bottom: 5px;
        }
        .stat-value {
            font-size: 18px;
            font-weight: bold;
            color: #2D3748;
        }
        .attendance-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .attendance-table th {
            background-color: #4A5568;
            color: white;
            padding: 10px;
            text-align: left;
            font-size: 11px;
        }
        .attendance-table td {
            padding: 8px;
            border-bottom: 1px solid #E2E8F0;
            font-size: 11px;
        }
        .attendance-table tr:nth-child(even) {
            background-color: #F7FAFC;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            display: inline-block;
        }
        .status-present {
            background-color: #C6F6D5;
            color: #22543D;
        }
        .status-absent {
            background-color: #FED7D7;
            color: #742A2A;
        }
        .status-late {
            background-color: #FED7AA;
            color: #7C2D12;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #E2E8F0;
            text-align: center;
            font-size: 10px;
            color: #718096;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ $institute->name }}</h1>
        <h2>Attendance Report</h2>
        <p style="color: #718096;">{{ \Carbon\Carbon::parse($start_date)->format('F j, Y') }} - {{ \Carbon\Carbon::parse($end_date)->format('F j, Y') }}</p>
    </div>

    <div class="info-section">
        <p><strong>Institute:</strong> {{ $institute->name }}</p>
        <p><strong>Report Period:</strong> {{ \Carbon\Carbon::parse($start_date)->format('F j, Y') }} - {{ \Carbon\Carbon::parse($end_date)->format('F j, Y') }}</p>
        <p><strong>Generated:</strong> {{ $generated_at }}</p>
        <p><strong>Total Records:</strong> {{ $stats['total_records'] }}</p>
    </div>

    <div class="stats-section">
        <strong>Attendance Summary</strong>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-label">Total Records</div>
                <div class="stat-value">{{ $stats['total_records'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Present</div>
                <div class="stat-value" style="color: #38A169;">{{ $stats['present'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Absent</div>
                <div class="stat-value" style="color: #E53E3E;">{{ $stats['absent'] }}</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Late</div>
                <div class="stat-value" style="color: #DD6B20;">{{ $stats['late'] }}</div>
            </div>
        </div>
        <div style="text-align: center; padding: 10px; margin-top: 10px;">
            <strong>Attendance Rate:</strong> <span style="font-size: 18px; color: #3182CE;">{{ $stats['attendance_rate'] }}%</span>
        </div>
    </div>

    <table class="attendance-table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Student</th>
                <th>Class</th>
                <th>Status</th>
                <th>Check-in Time</th>
                <th>Notes</th>
            </tr>
        </thead>
        <tbody>
            @forelse($attendances as $attendance)
                <tr>
                    <td>{{ \Carbon\Carbon::parse($attendance->date)->format('M j, Y') }}</td>
                    <td>{{ $attendance->student->user->name ?? 'N/A' }}</td>
                    <td>{{ $attendance->class->name ?? 'N/A' }}</td>
                    <td>
                        <span class="status-badge status-{{ $attendance->status }}">
                            {{ ucfirst($attendance->status) }}
                        </span>
                    </td>
                    <td>{{ $attendance->check_in_time ?? '-' }}</td>
                    <td>{{ $attendance->notes ?? '-' }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" style="text-align: center; padding: 20px; color: #718096;">
                        No attendance records found for this period.
                    </td>
                </tr>
            @endforelse
        </tbody>
    </table>

    <div class="footer">
        <p>Tuition Management System - Automated Report Generation</p>
        <p>This report was automatically generated on {{ $generated_at }}</p>
    </div>
</body>
</html>
