import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpPressed;

  const LoginScreen({
    Key? key,
    required this.onSignUpPressed,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _needsEmailVerification = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final success = await authProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;

        if (success) {
          // Show success message and ensure proper navigation happens
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful! Welcome back.'),
              backgroundColor: Colors.green,
            ),
          );

          // Ensure the user's role is properly set
          if (authProvider.role == null || authProvider.role!.isEmpty) {
            await authProvider.refreshUser();
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
            }
          }

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
      } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // University Logo
                  Container(
                    height: 120,
                    width: 120,
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/university_logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'University Housing',
                    style: AppTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Email Field
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
                  const SizedBox(height: 24),

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    textInputAction: TextInputAction.done,
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
                  const SizedBox(height: 8),

                  // Email Verification Message
                  if (_needsEmailVerification)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16, top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email not verified',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Please check your inbox for a verification email',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                isLoading ? null : _resendVerificationEmail,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              backgroundColor: Colors.amber,
                            ),
                            child: Text(
                              'Resend Verification Email',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_needsEmailVerification)
                        const SizedBox.shrink()
                      else
                        TextButton(
                          onPressed:
                              isLoading ? null : _resendVerificationEmail,
                          child: Text(
                            'Resend Verification',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.amber[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                // TODO: Implement forgot password
                              },
                        child: Text(
                          'Forgot Password?',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  CustomButton(
                    text: 'Login',
                    onPressed: isLoading ? () {} : _login,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: isLoading ? null : widget.onSignUpPressed,
                        child: Text(
                          'Sign Up',
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
      ),
    );
  }
}
