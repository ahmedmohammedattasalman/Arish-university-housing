import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../../core/widgets/language_toggle_button.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/config/constants.dart';
import '../../student/screens/student_dashboard.dart';
import '../../supervisor/screens/supervisor_dashboard.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../labor/screens/labor_dashboard.dart';
import '../../restaurant/screens/restaurant_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpPressed;

  const LoginScreen({
    super.key,
    required this.onSignUpPressed,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _needsEmailVerification = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  Future<void> _resendVerificationEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your email address first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final success = await authProvider.resendConfirmationEmail(email);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Verification email sent. Please check your inbox.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ??
                  'Failed to send verification email'),
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
    }
  }

  Future<void> _login() async {
    if (!mounted) return;

    if (_formKey.currentState?.validate() ?? false) {
      try {
        setState(() {
          _needsEmailVerification = false;
        });

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text('signing_in'.tr(context)),
              ],
            ),
          ),
        );

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Close loading dialog
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (!mounted) return;

        if (success) {
          // Show loading profile dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Text('loading_profile'.tr(context)),
                ],
              ),
            ),
          );

          // Ensure the user's role is properly set and synchronized
          await authProvider.refreshUserRole();

          // Close loading dialog
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // Navigate to appropriate dashboard based on the user's role
          if (mounted) {
            _navigateToDashboard(authProvider.role);
          }
        } else {
          // Check if the error is about email confirmation
          final errorMsg = authProvider.errorMessage ?? '';
          if (errorMsg.contains('verify your email') ||
              errorMsg.contains('email_not_confirmed') ||
              errorMsg.contains('Email not confirmed')) {
            if (mounted) {
              setState(() {
                _needsEmailVerification = true;
              });
              _showVerificationDialog();
            }
          } else {
            // Show error message
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMsg != ''
                      ? errorMsg
                      : 'Login failed. Please check your credentials.'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          }
        }
      } catch (e) {
        // Close loading dialog if it's showing
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        if (mounted) {
          // Show generic error message if exception is thrown
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  // Helper method to navigate to the appropriate dashboard based on role
  void _navigateToDashboard(String? role) {
    if (!mounted) return;

    Widget dashboard;
    String dashboardTitle = '';

    switch (role) {
      case AppConstants.roleStudent:
        dashboard = const StudentDashboard();
        dashboardTitle = 'student_dashboard'.tr(context);
        break;
      case AppConstants.roleSupervisor:
        dashboard = const SupervisorDashboard();
        dashboardTitle = 'supervisor_dashboard'.tr(context);
        break;
      case AppConstants.roleAdmin:
        dashboard = const AdminDashboard();
        dashboardTitle = 'admin_dashboard'.tr(context);
        break;
      case AppConstants.roleLabor:
        dashboard = const LaborDashboard();
        dashboardTitle = 'labor_dashboard'.tr(context);
        break;
      case AppConstants.roleRestaurant:
        dashboard = const RestaurantDashboard();
        dashboardTitle = 'restaurant_dashboard'.tr(context);
        break;
      default:
        // If role is not recognized, show an error and don't navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Unable to determine user role. Please contact the administrator.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
    }

    // Use pushAndRemoveUntil to remove all previous screens from the stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboard),
      (Route<dynamic> route) => false, // Remove all routes
    );

    // Show welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to $dashboardTitle'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language toggle button at the top
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: LanguageToggleButton(),
                      ),
                    ),
                    // University Logo with Animation
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: Container(
                        height: 100,
                        width: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/university_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Welcome Text
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'app_name'.tr(context),
                        style: AppTheme.headlineMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'welcome'.tr(context),
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Card Container for Login Form
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 500),
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
                                // Email Field
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 600),
                                  child: _buildEmailField(isLoading, context),
                                ),
                                const SizedBox(height: 20),

                                // Password Field
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 700),
                                  child:
                                      _buildPasswordField(isLoading, context),
                                ),
                                const SizedBox(height: 8),

                                // Email Verification Message
                                if (_needsEmailVerification)
                                  FadeInUp(
                                    duration: const Duration(milliseconds: 400),
                                    child: _buildVerificationBox(
                                        isLoading, context),
                                  ),

                                // Forgot Password
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 800),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: TextButton(
                                          onPressed: isLoading
                                              ? null
                                              : () {
                                                  // TODO: Implement forgot password
                                                },
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppTheme.primaryColor,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                          ),
                                          child: Text(
                                            'forget_password'.tr(context),
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Login Button
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 900),
                                  child: _buildLoginButton(isLoading, context),
                                ),

                                // Divider
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 1000),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24.0),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Divider(
                                            thickness: 1,
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Text(
                                            'or'.tr(context),
                                            style: TextStyle(
                                              color:
                                                  AppTheme.textSecondaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const Expanded(
                                          child: Divider(
                                            thickness: 1,
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Sign Up Option
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 1100),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'no_account'.tr(context),
                                          style: AppTheme.bodyMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Flexible(
                                        child: TextButton(
                                          onPressed: isLoading
                                              ? null
                                              : widget.onSignUpPressed,
                                          child: Text(
                                            'register'.tr(context),
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Terms and Policy
                                FadeInUp(
                                  duration: const Duration(milliseconds: 800),
                                  delay: const Duration(milliseconds: 1200),
                                  child: Text(
                                    'terms_policy'.tr(context),
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildEmailField(bool isLoading, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'email'.tr(context),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          validator: Validators.validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'email'.tr(context),
            prefixIcon: const Icon(Icons.email_outlined),
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

  Widget _buildPasswordField(bool isLoading, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'password'.tr(context),
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          validator: Validators.validatePassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,
          style: AppTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'password'.tr(context),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed: _togglePasswordVisibility,
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

  Widget _buildVerificationBox(bool isLoading, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'email_not_verified'.tr(context),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'check_inbox'.tr(context),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _resendVerificationEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                'resend_verification'.tr(context),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 12),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.login_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isLoading ? 'loading'.tr(context) : 'login'.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
            const SizedBox(width: 8),
            Text('email_not_verified'.tr(context)),
          ],
        ),
        content: Text('check_inbox'.tr(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr(context)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _resendVerificationEmail();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: Text('resend_verification'.tr(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
