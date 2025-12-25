import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/class_model.dart';
import '../../../models/teacher.dart';
import '../providers/classes_provider.dart';
import '../../../providers/api_provider.dart';

class ClassFormDialog extends ConsumerStatefulWidget {
  final ClassModel? classData;

  const ClassFormDialog({
    super.key,
    this.classData,
  });

  @override
  ConsumerState<ClassFormDialog> createState() => _ClassFormDialogState();
}

class _ClassFormDialogState extends ConsumerState<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Form controllers
  final _nameController = TextEditingController();
  final _monthlyFeeController = TextEditingController();
  final _maxStudentsController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown values
  int? _selectedSubjectId;
  int? _selectedTeacherId;
  String? _selectedGrade;
  String? _selectedDayOfWeek;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isActive = true;

  // Options
  List<Subject> _subjects = [];
  List<Teacher> _teachers = [];
  final List<String> _grades = [
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
    'Grade 13',
  ];
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  bool get isEditing => widget.classData != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final apiService = ref.read(apiProvider);

      // Load subjects and teachers
      final subjects = await apiService.getSubjects();
      final teachers = await apiService.getTeachers();

      setState(() {
        _subjects = subjects;
        _teachers = teachers;
      });

      // Populate form if editing
      if (isEditing) {
        _populateFormData();
      }

      setState(() => _isLoadingData = false);
    } catch (e) {
      setState(() => _isLoadingData = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _populateFormData() {
    final data = widget.classData!;
    _nameController.text = data.name;
    _selectedGrade = data.grade;
    _monthlyFeeController.text = data.monthlyFee?.toString() ?? '';
    _maxStudentsController.text = data.maxStudents?.toString() ?? '';
    _descriptionController.text = data.description ?? '';

    _selectedSubjectId = data.subjectId;
    _selectedTeacherId = data.teacherId;
    _selectedDayOfWeek = data.day;
    _isActive = data.isActive;

    // Parse time strings
    if (data.startTime != null) {
      final parts = data.startTime!.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    if (data.endTime != null) {
      final parts = data.endTime!.split(':');
      _endTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a grade')),
      );
      return;
    }

    if (_selectedDayOfWeek == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day of week')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text,
        'subject_id': _selectedSubjectId,
        'grade': _selectedGrade,
        'teacher_id': _selectedTeacherId,
        'day': _selectedDayOfWeek,
        'start_time': _formatTimeOfDay(_startTime!),
        'end_time': _formatTimeOfDay(_endTime!),
        'monthly_fee': double.parse(_monthlyFeeController.text),
        'max_students': int.parse(_maxStudentsController.text),
        'description': _descriptionController.text,
        'is_active': _isActive,
      };

      if (isEditing) {
        await ref.read(classesProvider.notifier).updateClass(
          widget.classData!.id,
          data,
        );
      } else {
        await ref.read(classesProvider.notifier).createClass(data);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing
                ? 'Class updated successfully'
                : 'Class created successfully'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyFeeController.dispose();
    _maxStudentsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Class' : 'Add New Class',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Class Name
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Class Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter class name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Subject & Grade Row
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedSubjectId,
                                    decoration: const InputDecoration(
                                      labelText: 'Subject',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _subjects.map((subject) {
                                      return DropdownMenuItem<int>(
                                        value: subject.id,
                                        child: Text(subject.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedSubjectId = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGrade,
                                    decoration: const InputDecoration(
                                      labelText: 'Grade',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _grades.map((grade) {
                                      return DropdownMenuItem<String>(
                                        value: grade,
                                        child: Text(grade),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedGrade = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Teacher & Day of Week Row
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: _selectedTeacherId,
                                    decoration: const InputDecoration(
                                      labelText: 'Teacher (Optional)',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _teachers.map((teacher) {
                                      return DropdownMenuItem<int>(
                                        value: teacher.id,
                                        child: Text(teacher.user.name),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedTeacherId = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDayOfWeek,
                                    decoration: const InputDecoration(
                                      labelText: 'Day of Week',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: _daysOfWeek.map((day) {
                                      return DropdownMenuItem<String>(
                                        value: day,
                                        child: Text(day),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() => _selectedDayOfWeek = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Start Time & End Time Row
                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, true),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Start Time',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        _startTime != null
                                            ? _formatTimeOfDay(_startTime!)
                                            : 'Select time',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => _selectTime(context, false),
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'End Time',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        _endTime != null
                                            ? _formatTimeOfDay(_endTime!)
                                            : 'Select time',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Monthly Fee & Max Students Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _monthlyFeeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Monthly Fee',
                                      border: OutlineInputBorder(),
                                      prefixText: 'Rs. ',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter monthly fee';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _maxStudentsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Max Students',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter max students';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),

                            // Is Active Checkbox
                            SwitchListTile(
                              title: const Text('Active'),
                              value: _isActive,
                              onChanged: (value) {
                                setState(() => _isActive = value);
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
