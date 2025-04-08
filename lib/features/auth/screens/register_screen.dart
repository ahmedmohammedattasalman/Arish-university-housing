import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onLoginPressed;

  const RegisterScreen({
    Key? key,
    required this.onLoginPressed,
  }) : super(key: key);

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

  String _selectedRole = AppConstants.roleStudent;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAdminPasswordVisible = false;
  final String _requiredAdminPassword = "20914908@lib";

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Student',
      'value': AppConstants.roleStudent,
      'icon': Icons.school,
    },
    {
      'title': 'Supervisor',
      'value': AppConstants.roleSupervisor,
      'icon': Icons.supervisor_account,
    },
    {
      'title': 'Admin',
      'value': AppConstants.roleAdmin,
      'icon': Icons.admin_panel_settings,
    },
    {
      'title': 'Labor',
      'value': AppConstants.roleLabor,
      'icon': Icons.construction,
    },
    {
      'title': 'Restaurant Staff',
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
          const SnackBar(
            content:
                Text('Incorrect admin password. Registration not allowed.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final userData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      // Add role-specific fields
      if (_selectedRole == AppConstants.roleStudent) {
        userData['student_id'] = _idController.text.trim();
      } else if (_selectedRole == AppConstants.roleSupervisor ||
          _selectedRole == AppConstants.roleAdmin ||
          _selectedRole == AppConstants.roleLabor ||
          _selectedRole == AppConstants.roleRestaurant) {
        userData['employee_id'] = _idController.text.trim();
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
              title: const Text('Registration Successful'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Your account has been created successfully!'),
                  SizedBox(height: 16),
                  Text(
                      'Please check your email to verify your account before logging in.'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Go to login screen
                    widget.onLoginPressed();
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Registration failed'),
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

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : widget.onLoginPressed,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select your role',
                  style: AppTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Role Selection
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final isSelected = _selectedRole == role['value'];

                      return GestureDetector(
                        onTap:
                            isLoading ? null : () => _selectRole(role['value']),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : AppTheme.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                role['icon'],
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                role['title'],
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
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Full Name
                CustomTextField(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.validateName,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.validateEmail,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // ID (Student ID / Employee ID)
                CustomTextField(
                  label: _selectedRole == AppConstants.roleStudent
                      ? 'Student ID'
                      : 'Employee ID',
                  hint: _selectedRole == AppConstants.roleStudent
                      ? 'Enter your student ID'
                      : 'Enter your employee ID',
                  controller: _idController,
                  textInputAction: TextInputAction.next,
                  prefixIcon: _selectedRole == AppConstants.roleStudent
                      ? Icons.badge_outlined
                      : Icons.card_membership_outlined,
                  validator: (value) => Validators.validateRequired(
                    value,
                    _selectedRole == AppConstants.roleStudent
                        ? 'Student ID'
                        : 'Employee ID',
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Phone
                CustomTextField(
                  label: 'Phone',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.validatePhone,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.validatePassword,
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !isLoading,
                  suffix: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: _toggleConfirmPasswordVisibility,
                  ),
                ),
                const SizedBox(height: 24),

                // Admin Password Field
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Authentication Required',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Only authorized administrators can register new users',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        label: 'Admin Password',
                        hint: 'Enter admin password',
                        controller: _adminPasswordController,
                        obscureText: !_isAdminPasswordVisible,
                        textInputAction: TextInputAction.done,
                        prefixIcon: Icons.admin_panel_settings,
                        validator: (value) => Validators.validateRequired(
                          value,
                          'Admin Password',
                        ),
                        enabled: !isLoading,
                        suffix: IconButton(
                          icon: Icon(
                            _isAdminPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                          onPressed: _toggleAdminPasswordVisibility,
                        ),
                      ),
                    ],
                  ),
                ),

                // Register Button
                CustomButton(
                  text: 'Create Account',
                  onPressed: isLoading ? () {} : _register,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),

                // Sign In Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isLoading ? null : widget.onLoginPressed,
                      child: Text(
                        'Sign In',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
