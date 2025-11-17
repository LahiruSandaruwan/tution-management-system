import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../providers/api_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final apiService = ref.read(apiProvider);
      final response = await apiService.uploadProfilePhoto(image.path);

      if (response['success'] == true) {
        // Refresh user data to get updated photo URL
        await ref.read(authProvider.notifier).refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to upload photo'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _isUploading = true;
      });

      final apiService = ref.read(apiProvider);
      final response = await apiService.uploadProfilePhoto(image.path);

      if (response['success'] == true) {
        // Refresh user data to get updated photo URL
        await ref.read(authProvider.notifier).refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to upload photo'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deletePhoto() async {
    try {
      setState(() {
        _isUploading = true;
      });

      final apiService = ref.read(apiProvider);
      final response = await apiService.deleteProfilePhoto();

      if (response['success'] == true) {
        // Refresh user data to remove photo URL
        await ref.read(authProvider.notifier).refreshUser();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo removed successfully'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Failed to delete photo'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showPhotoOptions() {
    final authState = ref.read(authProvider);
    final hasPhoto = authState.user?.profilePhoto != null;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text('Remove photo', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLocales.map((locale) {
            final currentLocale = ref.read(localeProvider);
            final isSelected = currentLocale.languageCode == locale.languageCode;
            final languageName = ref.read(localeProvider.notifier).getLanguageName(locale);

            return RadioListTile<Locale>(
              title: Text(languageName),
              value: locale,
              groupValue: currentLocale,
              activeColor: AppTheme.primaryColor,
              onChanged: (Locale? value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final student = authState.student;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        _isUploading
                            ? const CircleAvatar(
                                radius: 50,
                                backgroundColor: AppTheme.primaryColor,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : user?.profilePhoto != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(user!.profilePhoto!),
                                    onBackgroundImageError: (_, __) {},
                                    child: user.profilePhoto == null
                                        ? Text(
                                            user.name.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppTheme.primaryColor,
                                    child: Text(
                                      user?.name.substring(0, 1).toUpperCase() ?? 'S',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _showPhotoOptions,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Student Name',
                      style: AppTheme.headingMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student?.studentIdNumber ?? 'N/A',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student?.grade ?? 'N/A',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Personal Information
            Text(
              'Personal Information',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.email,
                    label: 'Email',
                    value: user?.email ?? 'N/A',
                  ),
                  const Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.phone,
                    label: 'Phone',
                    value: user?.phone ?? 'N/A',
                  ),
                  if (student?.dateOfBirth != null) ...[
                    const Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.cake,
                      label: 'Date of Birth',
                      value: student!.dateOfBirth!,
                    ),
                  ],
                  if (student?.address != null) ...[
                    const Divider(height: 1),
                    _buildInfoItem(
                      icon: Icons.location_on,
                      label: 'Address',
                      value: student!.address!,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Parent Information
            if (student?.parentName != null || student?.parentPhone != null) ...[
              Text(
                'Parent/Guardian Information',
                style: AppTheme.headingSmall,
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    if (student?.parentName != null)
                      _buildInfoItem(
                        icon: Icons.person,
                        label: 'Parent Name',
                        value: student!.parentName!,
                      ),
                    if (student?.parentPhone != null) ...[
                      const Divider(height: 1),
                      _buildInfoItem(
                        icon: Icons.phone,
                        label: 'Parent Phone',
                        value: student!.parentPhone!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Settings/Actions
            Text(
              'Settings',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  // Dark Mode Toggle
                  ListTile(
                    leading: Icon(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppTheme.primaryColor,
                    ),
                    title: Text('Dark Mode', style: AppTheme.titleMedium),
                    trailing: Switch(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (value) {
                        ref.read(themeModeProvider.notifier).toggleTheme();
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  const Divider(height: 1),
                  // Language Selector
                  ListTile(
                    leading: const Icon(Icons.language, color: AppTheme.primaryColor),
                    title: Text('Language', style: AppTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ref.read(localeProvider.notifier).getLanguageName(
                            ref.watch(localeProvider),
                          ),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
                      ],
                    ),
                    onTap: () => _showLanguageDialog(),
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.lock,
                    label: 'Change Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.help,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildActionItem(
                    icon: Icons.info,
                    label: 'About',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),

            const SizedBox(height: 16),

            // App Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: AppTheme.bodySmall),
      subtitle: Text(value, style: AppTheme.titleMedium),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(label, style: AppTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondaryColor),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
