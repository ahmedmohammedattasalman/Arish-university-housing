import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';

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
            _error = 'Could not retrieve user profile data';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Profile error: $e');
      setState(() {
        _error = 'Error loading profile: ${e.toString()}';
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
            value ?? 'Not provided',
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
    final role = _userProfile?['user_role'] ?? authProvider.role ?? 'Unknown';
    final theme = AppTheme.getThemeForRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
            tooltip: 'Refresh Profile',
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
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: const Text('Retry'),
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
                                    : _userProfile?['email'] ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Email
                              Text(
                                _userProfile?['email'] ?? 'No email provided',
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
                                  (_userProfile?['user_role'] ??
                                          _userProfile?['role'] ??
                                          'Unknown')
                                      .toUpperCase(),
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
                        _buildSectionHeader('Personal Information'),
                        _buildProfileField('ID', _userProfile?['id']),
                        _buildProfileField(
                            'Full Name', _userProfile?['full_name']),
                        _buildProfileField('Email', _userProfile?['email']),
                        _buildProfileField('Phone', _userProfile?['phone']),
                        _buildProfileField('Created At',
                            _formatDate(_userProfile?['created_at'])),
                        _buildProfileField('Last Updated',
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
                              // Navigate to edit profile screen (to be implemented)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Edit Profile functionality coming soon'),
                                ),
                              );
                            },
                            child: const Text('Edit Profile'),
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

  // Role-specific sections
  Widget _buildStudentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Student Information'),
        _buildProfileField('Student ID', _userProfile?['student_id']),
        _buildProfileField('Room Number', _userProfile?['room_number']),
        _buildProfileField('Program', _userProfile?['program']),
        _buildProfileField(
            'Enrollment Date', _formatDate(_userProfile?['enrollment_date'])),
        _buildProfileField(
            'Graduation Year', _userProfile?['graduation_year']?.toString()),
      ],
    );
  }

  Widget _buildSupervisorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Supervisor Information'),
        _buildProfileField('Employee ID', _userProfile?['employee_id']),
        _buildProfileField('Department', _userProfile?['department']),
        _buildProfileField(
            'Building Assigned', _userProfile?['building_assigned']),
        _buildProfileField(
            'Hire Date', _formatDate(_userProfile?['hire_date'])),
      ],
    );
  }

  Widget _buildAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Admin Information'),
        _buildProfileField('Employee ID', _userProfile?['employee_id']),
        _buildProfileField('Department', _userProfile?['department']),
        _buildProfileField('Access Level', _userProfile?['access_level']),
        _buildProfileField(
            'Hire Date', _formatDate(_userProfile?['hire_date'])),
      ],
    );
  }

  Widget _buildLaborSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Labor Staff Information'),
        _buildProfileField('Employee ID', _userProfile?['employee_id']),
        _buildProfileField('Department', _userProfile?['department']),
        _buildProfileField('Specialty', _userProfile?['specialty']),
        _buildProfileField(
            'Building Assigned', _userProfile?['building_assigned']),
      ],
    );
  }

  Widget _buildRestaurantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        _buildSectionHeader('Restaurant Staff Information'),
        _buildProfileField('Employee ID', _userProfile?['employee_id']),
        _buildProfileField('Position', _userProfile?['position']),
        _buildProfileField('Dining Hall', _userProfile?['dining_hall']),
        _buildProfileField('Shift Hours', _userProfile?['shift_hours']),
      ],
    );
  }
}
