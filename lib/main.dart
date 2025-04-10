import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/auth_wrapper.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'features/requests/providers/request_provider.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'core/services/local_storage_service.dart';

// Preload web fonts to avoid CORS issues
Future<void> preloadWebFonts(BuildContext context) async {
  if (kIsWeb) {
    try {
      // Use a simpler approach that doesn't rely on font files directly
      debugPrint('Preloading fonts for web...');

      // Create a hidden container with text in different fonts
      // This forces Flutter to preload the fonts from Google CDN
      final fontPreloader = Container(
        width: 0,
        height: 0,
        child: Column(
          children: [
            // Roboto is included with Material Design
            Text('', style: TextStyle(fontFamily: 'Roboto')),
            // For UI elements that might use system fonts
            Text('', style: TextStyle(fontFamily: 'Arial')),
            Text('', style: TextStyle(fontFamily: 'Segoe UI')),
            // Wait a brief moment to ensure fonts are processed
          ],
        ),
      );

      // Add the invisible widget to the widget tree
      if (context.mounted) {
        Overlay.of(context).insert(
          OverlayEntry(builder: (context) => fontPreloader),
        );
      }

      // Brief delay to allow any font loading to start
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('Fonts preloaded for web');
    } catch (e) {
      // Just log errors, don't crash
      debugPrint('Font preloading error (non-fatal): $e');
    }
  }
}

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

    // Initialize LocalStorageService (particularly important for web)
    await LocalStorageService.initialize();

    // Initialize Supabase
    final supabaseService = SupabaseService();
    await supabaseService.initialize();

    // Run the app with all services initialized
    runApp(const MyApp());
  } catch (e) {
    // Handle initialization errors
    debugPrint('Error during initialization: $e');

    // Special handling for asset loading errors
    String errorMsg = e.toString();
    if (errorMsg.contains('AssetManifest.json') ||
        errorMsg.contains('Failed to fetch') ||
        errorMsg.contains('assets/lang')) {
      errorMsg =
          'Failed to load application assets. If running in web mode, please make sure your server is configured correctly for Flutter web assets.';
    }

    // Run app with error state
    runApp(ErrorApp(error: errorMsg));
  }
}

// Utility function to handle web font loading errors
void logFontLoadingError(Object error) {
  if (kIsWeb && error.toString().contains('Failed to load font')) {
    // In web mode, just log the error but don't crash
    debugPrint('Font loading error (non-fatal): $error');
  } else {
    // In other platforms, rethrow
    throw error;
  }
}

class LoadingApp extends StatelessWidget {
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
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

    // Add error handlers for web mode
    if (kIsWeb) {
      FlutterError.onError = (FlutterErrorDetails details) {
        // Only handle font loading errors in a special way
        if (details.exception.toString().contains('Failed to load font')) {
          logFontLoadingError(details.exception);
        } else {
          // For other errors, use the default handler
          FlutterError.presentError(details);
        }
      };
    }
  }

  Future<void> _initLanguage() async {
    await _languageProvider.initLanguage();
  }

  @override
  Widget build(BuildContext context) {
    // Preload web fonts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      preloadWebFonts(context);
    });

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: _languageProvider),
        ChangeNotifierProvider(
          create: (_) => RequestProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
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
