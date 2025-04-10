import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/constants.dart';
import '../../../core/localization/string_extensions.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../student/screens/student_dashboard.dart';
import '../../supervisor/screens/supervisor_dashboard.dart';
import '../../admin/screens/admin_dashboard.dart';
import '../../labor/screens/labor_dashboard.dart';
import '../../restaurant/screens/restaurant_dashboard.dart';

enum AuthScreenType { login, register }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthScreenType _currentScreenType = AuthScreenType.login;
  bool _isRefreshing = false;

  void _toggleScreen() {
    if (mounted) {
      setState(() {
        _currentScreenType = _currentScreenType == AuthScreenType.login
            ? AuthScreenType.register
            : AuthScreenType.login;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Schedule refresh role check after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshUserRole();
    });
  }

  Future<void> _refreshUserRole() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.status == AuthStatus.authenticated) {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }

      try {
        await authProvider.refreshUserRole();
      } catch (e) {
        debugPrint('Error refreshing user role: $e');
      }

      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If still initializing or refreshing role, show a loading screen
    if (authProvider.status == AuthStatus.initial || _isRefreshing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If still loading, show a loading indicator
    if (authProvider.status == AuthStatus.loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'loading'.tr(context),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // If there was an error during initialization
    if (authProvider.status == AuthStatus.error) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'auth_error'.tr(context),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.errorMessage ?? 'unknown_error'.tr(context),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    // Show loading indicator when signing out
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('signing_out'.tr(context)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    authProvider.signOut();
                  }
                },
                child: Text('back_to_login'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    // If authenticated, navigate to the appropriate dashboard based on role
    if (authProvider.status == AuthStatus.authenticated) {
      // Debug output to check role
      debugPrint('Current user role: ${authProvider.role}');

      // If role is null or empty, refresh it and show loading
      if (authProvider.role == null || authProvider.role!.isEmpty) {
        if (!_isRefreshing) {
          // Schedule a role refresh
          Future.microtask(() {
            if (mounted) {
              _refreshUserRole();
            }
          });

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'loading_profile'.tr(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
      }

      // Use WidgetsBinding.instance.addPostFrameCallback to handle navigation properly
      // This ensures navigation happens after the current build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          _navigateToDashboard(context, authProvider.role);
        }
      });

      // Return a loading screen that will be replaced by the dashboard
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'loading_dashboard'
                    .tr(context, defaultValue: 'Loading dashboard...'),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // If not authenticated, show login or register screen
    if (_currentScreenType == AuthScreenType.login) {
      return LoginScreen(onSignUpPressed: _toggleScreen);
    } else {
      return RegisterScreen(onLoginPressed: _toggleScreen);
    }
  }

  // Helper method to navigate to the appropriate dashboard based on role
  void _navigateToDashboard(BuildContext context, String? role) {
    if (!mounted || !context.mounted) return;

    Widget dashboard;
    String dashboardTitle = '';

    // Determine which dashboard to show based on role
    switch (role) {
      case AppConstants.roleStudent:
        dashboard = const StudentDashboard();
        dashboardTitle = 'Student Dashboard';
        break;
      case AppConstants.roleSupervisor:
        dashboard = const SupervisorDashboard();
        dashboardTitle = 'Supervisor Dashboard';
        break;
      case AppConstants.roleAdmin:
        dashboard = const AdminDashboard();
        dashboardTitle = 'Admin Dashboard';
        break;
      case AppConstants.roleLabor:
        dashboard = const LaborDashboard();
        dashboardTitle = 'Labor Dashboard';
        break;
      case AppConstants.roleRestaurant:
        dashboard = const RestaurantDashboard();
        dashboardTitle = 'Restaurant Dashboard';
        break;
      default:
        // If role not recognized, show error and log out
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid role: "$role". Please contact the administrator.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );

        // Show loading indicator when signing out
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('signing_out'.tr(context)),
            duration: const Duration(seconds: 1),
          ),
        );

        // Sign out and return to prevent navigation
        Future.microtask(() {
          if (mounted && context.mounted) {
            Provider.of<AuthProvider>(context, listen: false).signOut();
          }
        });
        return;
    }

    // Use pushAndRemoveUntil to clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => dashboard),
      (Route<dynamic> route) => false, // Remove all routes
    );

    // Show welcome message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome to $dashboardTitle'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }
}
