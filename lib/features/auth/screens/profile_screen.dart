import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/string_extensions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId != null) {
        final profile = await _supabaseService.getUserProfile(userId);

        if (profile != null) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'could_not_retrieve_profile'.tr(context);
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'user_not_authenticated'.tr(context);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Profile error: $e');
      setState(() {
        _error = 'error_loading_profile'.tr(context) + ': ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildProfileField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? 'not_provided'.tr(context),
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = _userProfile?['user_role'] ??
        authProvider.role ??
        'unknown'.tr(context);
    final theme = AppTheme.getThemeForRole(role);

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr(context)),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
            tooltip: 'refresh_profile'.tr(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'error'.tr(context) + ': $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: Text('retry'.tr(context)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              // Profile avatar (use avatar_url if available)
                              _userProfile?['avatar_url'] != null &&
                                      _userProfile!['avatar_url']
                                          .toString()
                                          .isNotEmpty
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                          _userProfile!['avatar_url']),
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundColor:
                                          theme.primaryColor.withOpacity(0.2),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                              const SizedBox(height: 16),
                              // Full name if available, otherwise email
                              Text(
                                _userProfile?['full_name'] != null &&
                                        _userProfile!['full_name']
                                            .toString()
                                            .isNotEmpty
                                    ? _userProfile!['full_name']
                                    : _userProfile?['email'] ??
                                        'unknown_user'.tr(context),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Email
                              Text(
                                _userProfile?['email'] ??
                                    'no_email_provided'.tr(context),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Role badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getUserRoleTranslated(
                                      context,
                                      _userProfile?['user_role'] ??
                                          _userProfile?['role'] ??
                                          'unknown'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Personal Information Section
                        _buildSectionHeader('personal_info'.tr(context)),
                        _buildProfileField(
                            'id'.tr(context), _userProfile?['id']),
                        _buildProfileField(
                            'name'.tr(context), _userProfile?['full_name']),
                        _buildProfileField(
                            'email'.tr(context), _userProfile?['email']),
                        _buildProfileField(
                            'phone'.tr(context), _userProfile?['phone']),
                        _buildProfileField('created_at'.tr(context),
                            _formatDate(_userProfile?['created_at'])),
                        _buildProfileField('last_updated'.tr(context),
                            _formatDate(_userProfile?['updated_at'])),

                        // Role-specific information based on user role
                        if (role == 'student') _buildStudentSection(),
                        if (role == 'supervisor') _buildSupervisorSection(),
                        if (role == 'admin') _buildAdminSection(),
                        if (role == 'labor') _buildLaborSection(),
                        if (role == 'restaurant') _buildRestaurantSection(),

                        const SizedBox(height: 24),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 45),
                            ),
                            onPressed: () {
                              // Edit profile action
                            },
                            child: Text('edit_profile'.tr(context)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Logout Button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 45),
                            ),
                            onPressed: () {
                              // Show confirmation dialog
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title:
                                        Text('logout_confirmation'.tr(context)),
                                    content: Text('logout_confirmation_message'
                                        .tr(context)),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                        },
                                        child: Text('cancel'.tr(context)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          // Logout user
                                          Provider.of<AuthProvider>(context,
                                                  listen: false)
                                              .signOut();
                                        },
                                        child: Text(
                                          'logout'.tr(context),
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('logout'.tr(context)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Helper methods for formatting and building sections
  String? _formatDate(String? dateString) {
    if (dateString == null) return null;

    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Helper to get translated role name
  String _getUserRoleTranslated(BuildContext context, String role) {
    return 'role_title_$role'.tr(context).toUpperCase();
  }

  // Role-specific sections
  Widget _buildStudentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('student_info'.tr(context)),
        _buildProfileField(
            'student_id'.tr(context), _userProfile?['student_id']),
        _buildProfileField(
            'room_number'.tr(context), _userProfile?['room_number']),
        _buildProfileField('program'.tr(context), _userProfile?['program']),
        _buildProfileField('enrollment_date'.tr(context),
            _formatDate(_userProfile?['enrollment_date'])),
        _buildProfileField('graduation_year'.tr(context),
            _userProfile?['graduation_year']?.toString()),
      ],
    );
  }

  Widget _buildSupervisorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('supervisor_info'.tr(context)),
        _buildProfileField(
            'employee_id'.tr(context), _userProfile?['employee_id']),
        _buildProfileField(
            'department'.tr(context), _userProfile?['department']),
        _buildProfileField('building_assigned'.tr(context),
            _userProfile?['building_assigned']),
        _buildProfileField(
            'hire_date'.tr(context), _formatDate(_userProfile?['hire_date'])),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('admin_info'.tr(context)),
        _buildProfileField(
            'employee_id'.tr(context), _userProfile?['employee_id']),
        _buildProfileField(
            'department'.tr(context), _userProfile?['department']),
        _buildProfileField(
            'access_level'.tr(context), _userProfile?['access_level']),
        _buildProfileField(
            'hire_date'.tr(context), _formatDate(_userProfile?['hire_date'])),
      ],
    );
  }

  Widget _buildLaborSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('labor_staff_info'.tr(context)),
        _buildProfileField(
            'employee_id'.tr(context), _userProfile?['employee_id']),
        _buildProfileField(
            'department'.tr(context), _userProfile?['department']),
        _buildProfileField('specialty'.tr(context), _userProfile?['specialty']),
        _buildProfileField('building_assigned'.tr(context),
            _userProfile?['building_assigned']),
      ],
    );
  }

  Widget _buildRestaurantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('restaurant_staff_info'.tr(context)),
        _buildProfileField(
            'employee_id'.tr(context), _userProfile?['employee_id']),
        _buildProfileField('position'.tr(context), _userProfile?['position']),
        _buildProfileField(
            'dining_hall'.tr(context), _userProfile?['dining_hall']),
        _buildProfileField(
            'shift_hours'.tr(context), _userProfile?['shift_hours']),
      ],
    );
  }
}
