import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/auth_provider.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/config/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user != null) {
        _userId = user.id;
        final userData = await _supabaseService.getUserProfile(user.id);

        // Refresh the user role in auth provider to ensure consistency
        await authProvider.refreshUserRole();

        setState(() {
          _profileData = userData;
          _isLoading = false;
        });
      } else {
        // Handle case where user is not logged in
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return AppLocalizations.of(context)!.translate('student');
      case 'supervisor':
        return AppLocalizations.of(context)!.translate('supervisor');
      case 'admin':
        return AppLocalizations.of(context)!.translate('admin');
      case 'labor':
        return AppLocalizations.of(context)!.translate('labor');
      case 'restaurant':
        return AppLocalizations.of(context)!.translate('restaurant');
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (user == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.translate('not_logged_in')),
      );
    }

    // Get user role from profile data
    final String userRole =
        _profileData?['user_role'] as String? ?? authProvider.role ?? 'unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(userRole),
            const SizedBox(height: 24),
            _buildPersonalInfo(),
            const SizedBox(height: 24),
            _buildAdditionalInfo(userRole),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userRole) {
    final fullName = _profileData?['full_name'] as String? ?? '';
    final email = _profileData?['email'] as String? ?? '';
    final userId = _userId;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.8),
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getRoleColor(userRole).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getRoleColor(userRole),
                ),
              ),
              child: Text(
                _getRoleDisplayName(userRole),
                style: TextStyle(
                  color: _getRoleColor(userRole),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('user_id'),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    userId,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    // Copy user ID to clipboard
                    // Implement clipboard functionality
                  },
                  tooltip: AppLocalizations.of(context)!.translate('copy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final fullName = _profileData?['full_name'] as String? ?? '';
    final email = _profileData?['email'] as String? ?? '';
    final phone = _profileData?['phone'] as String? ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              AppLocalizations.of(context)!.translate('full_name'),
              fullName,
              Icons.person,
            ),
            const Divider(),
            _buildInfoItem(
              AppLocalizations.of(context)!.translate('email'),
              email,
              Icons.email,
            ),
            const Divider(),
            _buildInfoItem(
              AppLocalizations.of(context)!.translate('phone'),
              phone.isEmpty
                  ? AppLocalizations.of(context)!.translate('not_provided')
                  : phone,
              Icons.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(String userRole) {
    // Different fields based on user role
    List<Widget> fields = [];

    // Fields for all users
    final createdAt = _profileData?['created_at'] as String? ?? '';
    final formattedCreatedAt = createdAt.isNotEmpty
        ? DateTime.parse(createdAt).toString().substring(0, 19)
        : '';

    fields.add(
      _buildInfoItem(
        AppLocalizations.of(context)!.translate('account_created'),
        formattedCreatedAt,
        Icons.calendar_today,
      ),
    );
    fields.add(const Divider());

    // Add role-specific fields
    switch (userRole.toLowerCase()) {
      case 'student':
        final studentId = _profileData?['student_id'] as String? ?? '';
        final roomNumber = _profileData?['room_number'] as String? ?? '';
        final program = _profileData?['program'] as String? ?? '';

        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('student_id'),
            studentId.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : studentId,
            Icons.badge,
          ),
        );
        fields.add(const Divider());
        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('room_number'),
            roomNumber.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : roomNumber,
            Icons.home,
          ),
        );
        fields.add(const Divider());
        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('program'),
            program.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : program,
            Icons.school,
          ),
        );
        break;

      case 'supervisor':
      case 'admin':
      case 'labor':
        final employeeId = _profileData?['employee_id'] as String? ?? '';
        final department = _profileData?['department'] as String? ?? '';
        final position = _profileData?['position'] as String? ?? '';

        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('employee_id'),
            employeeId.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : employeeId,
            Icons.badge,
          ),
        );
        fields.add(const Divider());
        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('department'),
            department.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : department,
            Icons.business,
          ),
        );
        fields.add(const Divider());
        fields.add(
          _buildInfoItem(
            AppLocalizations.of(context)!.translate('position'),
            position.isEmpty
                ? AppLocalizations.of(context)!.translate('not_provided')
                : position,
            Icons.work,
          ),
        );
        break;

      default:
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...fields,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                // Navigate to edit profile
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child:
                  Text(AppLocalizations.of(context)!.translate('edit_profile')),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Navigate to change password
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                  AppLocalizations.of(context)!.translate('change_password')),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // Sign out
                final authProvider =
                    Provider.of<AuthProvider>(context, listen: false);
                authProvider.signOut();
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.translate('logout')),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return AppTheme.studentColor;
      case 'supervisor':
        return AppTheme.supervisorColor;
      case 'admin':
        return AppTheme.adminColor;
      case 'labor':
        return AppTheme.laborColor;
      case 'restaurant':
        return AppTheme.restaurantColor;
      default:
        return Colors.grey;
    }
  }
}
