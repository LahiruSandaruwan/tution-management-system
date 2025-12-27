import 'package:flutter/material.dart';
import '../../../models/student.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class StudentFormDialog extends StatefulWidget {
  final Student? student;
  final Function(Map<String, dynamic>) onSubmit;

  const StudentFormDialog({
    super.key,
    this.student,
    required this.onSubmit,
  });

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedGrade = 'Grade 10';
  DateTime? _dateOfBirth;
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _nameController.text = widget.student!.displayName;
      _emailController.text = widget.student!.user?.email ?? '';
      _phoneController.text = widget.student!.user?.phone ?? '';
      _studentIdController.text = widget.student!.studentIdNumber;
      _addressController.text = widget.student!.address ?? '';
      _parentNameController.text = widget.student!.parentName ?? '';
      _parentPhoneController.text = widget.student!.parentPhone ?? '';
      _selectedGrade = widget.student!.grade;
      _dateOfBirth = widget.student!.dateOfBirth;
      _isActive = widget.student!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _studentIdController.dispose();
    _addressController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.student != null;

    return Dialog(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit : Icons.person_add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Student' : 'Add New Student',
                    style: AppTheme.headingMedium.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      Text('Personal Information',
                          style: AppTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Name and Email
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter name';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter valid email';
                                }
                                return null;
                              },
                              enabled: !isEdit, // Email cannot be changed
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Phone and Student ID
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number *',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter phone';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _studentIdController,
                              decoration: const InputDecoration(
                                labelText: 'Student ID *',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter student ID';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grade and Date of Birth
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGrade,
                              decoration: const InputDecoration(
                                labelText: 'Grade *',
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: [
                                'Grade 6',
                                'Grade 7',
                                'Grade 8',
                                'Grade 9',
                                'Grade 10',
                                'Grade 11',
                                'Grade 12',
                                'Grade 13'
                              ].map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedGrade = value!);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dateOfBirth ?? DateTime(2010),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _dateOfBirth = date);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _dateOfBirth != null
                                      ? DateFormat('yyyy-MM-dd')
                                          .format(_dateOfBirth!)
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          prefixIcon: Icon(Icons.home),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Parent Information Section
                      Text('Parent/Guardian Information',
                          style: AppTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Parent Name and Phone
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _parentNameController,
                              decoration: const InputDecoration(
                                labelText: 'Parent/Guardian Name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _parentPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Parent/Guardian Phone',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account Settings Section
                      if (!isEdit) ...[
                        Text('Account Settings', style: AppTheme.titleLarge),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password *',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Status
                      Row(
                        children: [
                          const Text('Status:', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 16),
                          Switch(
                            value: _isActive,
                            onChanged: (value) {
                              setState(() => _isActive = value);
                            },
                            activeColor: AppTheme.successColor,
                          ),
                          Text(
                            _isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: _isActive
                                  ? AppTheme.successColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(
                      isEdit ? 'Update Student' : 'Add Student',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final data = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'student_id_number': _studentIdController.text,
      'grade': _selectedGrade,
      'is_active': _isActive,
      if (_addressController.text.isNotEmpty)
        'address': _addressController.text,
      if (_parentNameController.text.isNotEmpty)
        'parent_name': _parentNameController.text,
      if (_parentPhoneController.text.isNotEmpty)
        'parent_phone': _parentPhoneController.text,
      if (_dateOfBirth != null)
        'date_of_birth': DateFormat('yyyy-MM-dd').format(_dateOfBirth!),
    };

    // Add fields specific to create
    if (widget.student == null) {
      data['email'] = _emailController.text;
      data['password'] = _passwordController.text;
    }

    await widget.onSubmit(data);

    setState(() => _isSubmitting = false);
  }
}
