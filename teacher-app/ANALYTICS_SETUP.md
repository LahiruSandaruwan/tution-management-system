# Teacher Analytics Setup Guide

## Overview

The Teacher Mobile App can be enhanced with an Advanced Analytics Dashboard similar to the Student App implementation. This guide outlines the recommended analytics features for teachers.

## Recommended Analytics Features

### 1. Teaching Performance Metrics

**Overview Dashboard:**
- Total classes conducted vs scheduled
- Average attendance rate across all classes
- Student engagement metrics
- Completion rate of scheduled sessions

**Visualizations:**
- Line chart: Classes conducted over time
- Bar chart: Attendance rate by class
- Pie chart: Class distribution by subject
- Heatmap: Teaching schedule occupancy

### 2. Student Performance Analytics

**Metrics to Track:**
- Average grades by class
- Grade distribution across subjects
- Performance trends over time
- Top performers and struggling students

**Visualizations:**
- Bar chart: Average grade by subject
- Line chart: Performance trends
- Distribution chart: Grade ranges
- Comparison chart: Class-to-class performance

### 3. Attendance Analytics

**Key Metrics:**
- Overall attendance rate
- Attendance trends by class
- Punctuality metrics (late arrivals)
- Absence patterns

**Visualizations:**
- Line chart: Attendance trend over time
- Bar chart: Attendance by class
- Heatmap: Weekly attendance patterns
- Pie chart: Present/Absent/Late distribution

### 4. Class-Specific Analytics

**Per-Class Metrics:**
- Student count and enrollment trends
- Class average performance
- Attendance rate
- Completion status

**Visualizations:**
- Table view: Class comparison
- Bar chart: Student count by class
- Trend lines: Enrollment changes

## Implementation Guide

### Option 1: Copy from Student App

The Student App already has a complete analytics implementation at:
- `student-app/lib/features/analytics/screens/analytics_screen.dart`
- `student-app/lib/features/analytics/providers/analytics_provider.dart`

**Steps:**
1. Copy the analytics folder to teacher app
2. Modify the data provider to fetch teacher-specific metrics
3. Update visualizations for teacher context
4. Add navigation from dashboard

### Option 2: Custom Implementation

**Create new analytics screen:**

```dart
// lib/features/analytics/screens/teacher_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TeacherAnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary Cards
            _buildSummarySection(),

            // Class Performance Chart
            _buildClassPerformanceChart(),

            // Attendance Trends
            _buildAttendanceTrends(),

            // Student Performance
            _buildStudentPerformance(),
          ],
        ),
      ),
    );
  }
}
```

### Backend API Requirements

**Required Endpoints:**

```
GET /api/teachers/{id}/analytics
Response:
{
  "summary": {
    "total_classes": 12,
    "classes_conducted": 11,
    "avg_attendance_rate": 87.5,
    "avg_class_performance": 78.2
  },
  "class_performance": [
    {"class_name": "Math A", "avg_grade": 85.2, "attendance_rate": 92},
    {"class_name": "Science B", "avg_grade": 78.5, "attendance_rate": 85}
  ],
  "attendance_trends": [
    {"date": "2024-01-01", "rate": 88.5},
    {"date": "2024-01-02", "rate": 91.2}
  ],
  "student_performance": {
    "excellent": 15,
    "good": 25,
    "average": 30,
    "poor": 5
  }
}
```

## Quick Start

1. **Enable Analytics in Navigation:**

```dart
// Add to home screen quick actions
_buildActionItem(
  icon: FontAwesomeIcons.chartBar,
  title: 'View Analytics',
  subtitle: 'Teaching performance insights',
  onTap: () => context.push('/analytics'),
),
```

2. **Add Route:**

```dart
// In app_router.dart
GoRoute(
  path: '/analytics',
  builder: (context, state) => const TeacherAnalyticsScreen(),
),
```

3. **Create Provider:**

```dart
// lib/features/analytics/providers/teacher_analytics_provider.dart
final teacherAnalyticsProvider = FutureProvider((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Fetch analytics data from backend
  return await apiService.getTeacherAnalytics();
});
```

## Chart Libraries

Already included in pubspec.yaml:
- `fl_chart: ^0.65.0` - For beautiful charts and graphs

## Sample Visualizations

### 1. Attendance Trend (Line Chart)

```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: attendanceData.map((data) =>
          FlSpot(data.x, data.y)
        ).toList(),
        isCurved: true,
        color: Colors.blue,
      ),
    ],
  ),
)
```

### 2. Class Performance (Bar Chart)

```dart
BarChart(
  BarChartData(
    barGroups: classData.map((data) =>
      BarChartGroupData(
        x: data.index,
        barRods: [
          BarChartRodData(
            toY: data.performance,
            color: Colors.green,
          ),
        ],
      )
    ).toList(),
  ),
)
```

### 3. Grade Distribution (Pie Chart)

```dart
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(value: excellent, title: 'A', color: Colors.green),
      PieChartSectionData(value: good, title: 'B', color: Colors.blue),
      PieChartSectionData(value: average, title: 'C', color: Colors.orange),
      PieChartSectionData(value: poor, title: 'D', color: Colors.red),
    ],
  ),
)
```

## Data Export Feature

Add export functionality to download analytics as PDF or CSV:

```dart
Future<void> exportAnalytics() async {
  // Generate CSV
  final csv = convertToCSV(analyticsData);

  // Save file
  final file = File('analytics_${DateTime.now()}.csv');
  await file.writeAsString(csv);

  // Share file
  Share.shareFiles([file.path]);
}
```

## Period Filters

Implement date range selection:

```dart
// Period selector chips
Row(
  children: [
    ChoiceChip(label: Text('Week'), selected: period == 'week'),
    ChoiceChip(label: Text('Month'), selected: period == 'month'),
    ChoiceChip(label: Text('Quarter'), selected: period == 'quarter'),
    ChoiceChip(label: Text('Year'), selected: period == 'year'),
  ],
)
```

## Insights & Recommendations

Add AI-powered insights:

```dart
Card(
  child: ListTile(
    leading: Icon(Icons.lightbulb, color: Colors.orange),
    title: Text('Insight'),
    subtitle: Text('Math A attendance dropped 15% this week'),
  ),
)
```

## Testing

Test analytics with mock data:

```dart
final mockAnalytics = {
  'summary': {
    'total_classes': 12,
    'classes_conducted': 11,
    'avg_attendance_rate': 87.5,
  },
  // ... more data
};
```

## Performance Optimization

- Cache analytics data for quick loading
- Implement pagination for large datasets
- Use lazy loading for charts
- Optimize chart rendering

## Future Enhancements

- Real-time analytics updates via WebSocket
- Predictive analytics (attendance predictions)
- Comparative analytics (vs other teachers)
- Downloadable reports (PDF/Excel)
- Email analytics summaries
- Mobile notifications for insights

## Resources

- fl_chart documentation: https://pub.dev/packages/fl_chart
- Student App analytics implementation (reference)
- Material Design charts guidelines

---

**Note:** Analytics implementation is optional but highly recommended for data-driven teaching insights.
