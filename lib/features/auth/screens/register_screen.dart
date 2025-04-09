import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/localization/string_extensions.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;

  const RegisterScreen({
    super.key,
    required this.onLoginPressed,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _programController = TextEditingController();

  String _selectedRole = AppConstants.roleStudent;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAdminPasswordVisible = false;
  final String _requiredAdminPassword = "20914908@lib";

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'student',
      'value': AppConstants.roleStudent,
      'icon': Icons.school,
    },
    {
      'title': 'supervisor',
      'value': AppConstants.roleSupervisor,
      'icon': Icons.supervisor_account,
    },
    {
      'title': 'admin',
      'value': AppConstants.roleAdmin,
      'icon': Icons.admin_panel_settings,
    },
    {
      'title': 'labor',
      'value': AppConstants.roleLabor,
      'icon': Icons.construction,
    },
    {
      'title': 'restaurant',
      'value': AppConstants.roleRestaurant,
      'icon': Icons.restaurant,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _adminPasswordController.dispose();
    _departmentController.dispose();
    _roomNumberController.dispose();
    _programController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  void _toggleAdminPasswordVisibility() {
    setState(() {
      _isAdminPasswordVisible = !_isAdminPasswordVisible;
    });
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Verify admin password
      if (_adminPasswordController.text.trim() != _requiredAdminPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('incorrect_admin_password'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final userData = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      // Add role-specific fields
      if (_selectedRole == AppConstants.roleStudent) {
        userData['student_id'] = _idController.text.trim();
        userData['room_number'] = _roomNumberController.text.trim();
        userData['program'] = _programController.text.trim();
      } else if (_selectedRole == AppConstants.roleSupervisor) {
        userData['employee_id'] = _idController.text.trim();
        userData['department'] = _departmentController.text.trim();
      } else if (_selectedRole == AppConstants.roleAdmin) {
        userData['employee_id'] = _idController.text.trim();
        userData['department'] = _departmentController.text.trim();
        userData['access_level'] =
            'full_access'.tr(context); // Default for new admins
      } else if (_selectedRole == AppConstants.roleLabor) {
        userData['employee_id'] = _idController.text.trim();
        userData['department'] = _departmentController.text.trim();
        userData['specialty'] = _departmentController.text.trim();
      } else if (_selectedRole == AppConstants.roleRestaurant) {
        userData['employee_id'] = _idController.text.trim();
        userData['position'] = _departmentController.text.trim();
        userData['dining_hall'] = _roomNumberController.text.trim();
      }

      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
        userData,
      );

      if (mounted) {
        if (success) {
          // Show success message with email verification instructions
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text('registration_successful'.tr(context)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('account_created_successfully'.tr(context)),
                  SizedBox(height: 16),
                  Text('verify_email_instructions'.tr(context)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Go to login screen
                    widget.onLoginPressed();
                  },
                  child: Text('go_to_login'.tr(context)),
                ),
              ],
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ??
                  'registration_failed'.tr(context)),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.status == AuthStatus.loading;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.scaffoldBackgroundColor,
              AppTheme.accentColor.withOpacity(0.15),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeIn(
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language toggle button at the top
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: LanguageToggleButton(),
                    ),
                  ),
                  // Header with back button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: isLoading ? null : widget.onLoginPressed,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          'register'.tr(context),
                          style: AppTheme.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Title Card
                  FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'join_housing'.tr(context),
                            style: AppTheme.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'select_role_prompt'.tr(context),
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Selection Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_role'.tr(context),
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _roles.length,
                              itemBuilder: (context, index) {
                                final role = _roles[index];
                                final isSelected =
                                    _selectedRole == role['value'];

                                return GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => _selectRole(role['value']),
                                  child: FadeIn(
                                    duration: const Duration(milliseconds: 600),
                                    delay: Duration(milliseconds: 100 * index),
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                                .withOpacity(0.1)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.dividerColor,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            role['icon'],
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.textSecondaryColor,
                                            size: 36,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _getRoleTitle(
                                                context, role['title']),
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.textPrimaryColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Registration Form
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      width: screenSize.width > 600 ? 500 : double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'personal_info'.tr(context),
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Full Name
                              _buildTextField(
                                label: 'name'.tr(context),
                                hint: 'enter_name'.tr(context),
                                controller: _nameController,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.person_outline,
                                validator: Validators.validateName,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildTextField(
                                label: 'email'.tr(context),
                                hint: 'enter_email'.tr(context),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.email_outlined,
                                validator: Validators.validateEmail,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),

                              // ID (Student ID / Employee ID)
                              _buildTextField(
                                label: _selectedRole == AppConstants.roleStudent
                                    ? 'student_id'.tr(context)
                                    : 'employee_id'.tr(context),
                                hint: 'enter_id'.tr(context),
                                controller: _idController,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.badge_outlined,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'id_required'.tr(context)
                                        : null,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Phone Number
                              _buildTextField(
                                label: 'phone'.tr(context),
                                hint: 'enter_phone'.tr(context),
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icons.phone_outlined,
                                validator: Validators.validatePhone,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 24),

                              const Divider(),
                              const SizedBox(height: 16),

                              Text(
                                'role_info'.tr(context),
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Role-specific fields
                              if (_selectedRole ==
                                  AppConstants.roleStudent) ...[
                                // Room Number
                                _buildTextField(
                                  label: 'room_number'.tr(context),
                                  hint: 'room_prompt'.tr(context),
                                  controller: _roomNumberController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.meeting_room_outlined,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'id_required'.tr(context)
                                      : null,
                                  enabled: !isLoading,
                                ),
                                const SizedBox(height: 16),

                                // Program/Major
                                _buildTextField(
                                  label: 'program'.tr(context),
                                  hint: 'program_prompt'.tr(context),
                                  controller: _programController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.school_outlined,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'id_required'.tr(context)
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ] else if (_selectedRole ==
                                      AppConstants.roleSupervisor ||
                                  _selectedRole == AppConstants.roleAdmin ||
                                  _selectedRole == AppConstants.roleLabor) ...[
                                // Department
                                _buildTextField(
                                  label: 'department'.tr(context),
                                  hint: 'department_prompt'.tr(context),
                                  controller: _departmentController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.business_outlined,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'id_required'.tr(context)
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ] else if (_selectedRole ==
                                  AppConstants.roleRestaurant) ...[
                                // Position
                                _buildTextField(
                                  label: 'position'.tr(context),
                                  hint: 'position_prompt'.tr(context),
                                  controller: _departmentController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.work_outline,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'id_required'.tr(context)
                                      : null,
                                  enabled: !isLoading,
                                ),
                                const SizedBox(height: 16),

                                // Dining Hall
                                _buildTextField(
                                  label: 'dining_hall'.tr(context),
                                  hint: 'dining_hall_prompt'.tr(context),
                                  controller: _roomNumberController,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: Icons.restaurant_outlined,
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'id_required'.tr(context)
                                      : null,
                                  enabled: !isLoading,
                                ),
                              ],
                              const SizedBox(height: 24),

                              const Divider(),
                              const SizedBox(height: 16),

                              Text(
                                'security'.tr(context),
                                style: AppTheme.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Password
                              _buildPasswordField(
                                label: 'password'.tr(context),
                                hint: 'create_password'.tr(context),
                                controller: _passwordController,
                                textInputAction: TextInputAction.next,
                                isPasswordVisible: _isPasswordVisible,
                                toggleVisibility: _togglePasswordVisibility,
                                validator: Validators.validatePassword,
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 16),

                              // Confirm Password
                              _buildPasswordField(
                                label: 'confirm_password'.tr(context),
                                hint: 'confirm_password_hint'.tr(context),
                                controller: _confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                isPasswordVisible: _isConfirmPasswordVisible,
                                toggleVisibility:
                                    _toggleConfirmPasswordVisibility,
                                validator: (value) =>
                                    Validators.validateConfirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                                enabled: !isLoading,
                              ),
                              const SizedBox(height: 24),

                              // Admin Password Field
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 500),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.amber, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.admin_panel_settings,
                                            color: Colors.amber,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'admin_auth_required'.tr(context),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'admin_auth_message'.tr(context),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildPasswordField(
                                        label: 'admin_password'.tr(context),
                                        hint:
                                            'enter_admin_password'.tr(context),
                                        controller: _adminPasswordController,
                                        textInputAction: TextInputAction.done,
                                        isPasswordVisible:
                                            _isAdminPasswordVisible,
                                        toggleVisibility:
                                            _toggleAdminPasswordVisibility,
                                        validator: (value) =>
                                            Validators.validateRequired(
                                          value,
                                          'admin_password'.tr(context),
                                        ),
                                        enabled: !isLoading,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Register Button
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 600),
                                child: SizedBox(
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (isLoading)
                                          Container(
                                            width: 24,
                                            height: 24,
                                            margin: const EdgeInsets.only(
                                                right: 12),
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        else
                                          const Icon(Icons.app_registration,
                                              size: 22, color: Colors.white),
                                        const SizedBox(width: 8),
                                        Text(
                                          isLoading
                                              ? 'creating_account'.tr(context)
                                              : 'create_account'.tr(context),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Sign In Option
                              FadeInUp(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 700),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'have_account'.tr(context),
                                      style: AppTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: isLoading
                                          ? null
                                          : widget.onLoginPressed,
                                      child: Text(
                                        'login'.tr(context),
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    IconData? prefixIcon,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: enabled,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputAction textInputAction = TextInputAction.next,
    required bool isPasswordVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          validator: validator,
          textInputAction: textInputAction,
          enabled: enabled,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  String _getRoleTitle(BuildContext context, String title) {
    // Use a more direct approach to translations
    switch (title) {
      case 'student':
        return 'role_title_student'.tr(context);
      case 'supervisor':
        return 'role_title_supervisor'.tr(context);
      case 'admin':
        return 'role_title_admin'.tr(context);
      case 'labor':
        return 'role_title_labor'.tr(context);
      case 'restaurant':
        return 'role_title_restaurant'.tr(context);
      default:
        return title;
    }
  }
}
