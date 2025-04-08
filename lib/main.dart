import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';

void main() {
  // This must be called before any other Flutter code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the app with error handling
  initializeApp();
}

// Separate initialization function for better error handling
Future<void> initializeApp() async {
  try {
    // Run app immediately with loading state
    runApp(const LoadingApp());

    // Initialize services after app is running
    await Future.delayed(const Duration(milliseconds: 100));

    // Pre-initialize SharedPreferences
    await SharedPreferences.getInstance();

    // Initialize Supabase
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Run the app with all services initialized
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    debugPrint('Error during initialization: $e');

    // Run app with error state
    runApp(ErrorApp(error: e.toString()));
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Initializing application...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, this.error = 'Unknown error'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize application',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageProvider _languageProvider = LanguageProvider();

  @override
  void initState() {
    super.initState();
    _initLanguage();
  }

  Future<void> _initLanguage() async {
    await _languageProvider.initLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: _languageProvider),
      ],
      child: Consumer2<AuthProvider, LanguageProvider>(
        builder: (context, authProvider, languageProvider, _) {
          // Get the appropriate theme based on user role
          ThemeData theme = AppTheme.lightTheme;
          if (authProvider.status == AuthStatus.authenticated &&
              authProvider.role != null) {
            theme = AppTheme.getThemeForRole(authProvider.role!);
          }

          return MaterialApp(
            title: 'University Housing',
            theme: theme,
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: AppLocalizations.localeResolutionCallback,
            builder: (context, child) {
              return Directionality(
                textDirection: languageProvider.textDirection,
                child: child!,
              );
            },
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
