import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/constants.dart';
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
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // If still initializing, show a loading screen
    if (authProvider.status == AuthStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
              const Text(
                'Authentication Error',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                authProvider.errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    authProvider.signOut();
                  }
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      );
    }

    // If authenticated, navigate to the appropriate dashboard based on role
    if (authProvider.status == AuthStatus.authenticated) {
      switch (authProvider.role) {
        case AppConstants.roleStudent:
          return const StudentDashboard();
        case AppConstants.roleSupervisor:
          return const SupervisorDashboard();
        case AppConstants.roleAdmin:
          return const AdminDashboard();
        case AppConstants.roleLabor:
          return const LaborDashboard();
        case AppConstants.roleRestaurant:
          return const RestaurantDashboard();
        default:
          // If role not recognized, show error and log out
          Future.microtask(() {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Invalid role. Please contact the administrator.'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
              authProvider.signOut();
            }
          });

          return const Scaffold(
            body: Center(
              child: Text('Invalid role. Logging out...'),
            ),
          );
      }
    }

    // If not authenticated, show login or register screen
    if (_currentScreenType == AuthScreenType.login) {
      return LoginScreen(onSignUpPressed: _toggleScreen);
    } else {
      return RegisterScreen(onLoginPressed: _toggleScreen);
    }
  }
}
