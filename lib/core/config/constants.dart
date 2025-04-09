class AppConstants {
  // Supabase Configuration
  // Replace these with your Supabase project values from Project Settings > API
  static const String supabaseUrl =
      'https://cfttjlcwenszhwulszou.supabase.co'; // e.g. https://yourproject.supabase.co
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmdHRqbGN3ZW5zemh3dWxzem91Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNTE0ODcsImV4cCI6MjA1OTYyNzQ4N30.IxL1EoIuJVQZ0ON_eJlGXwATN5EYzuCsGBFMO0wQdlk'; // anon/public key

  // Role Constants
  static const String roleStudent = 'student';
  static const String roleSupervisor = 'supervisor';
  static const String roleAdmin = 'admin';
  static const String roleLabor = 'labor';
  static const String roleRestaurant = 'restaurant';

  // Collection Names for Supabase
  static const String profilesCollection = 'profiles';
  static const String usersCollection = 'users';
  static const String requestsCollection = 'requests';
  static const String notificationsCollection = 'notifications';
  static const String attendanceCollection = 'attendance';
  static const String qrCodesCollection = 'qr_codes';
  static const String paymentsCollection = 'payments';
  static const String cleaningRequestsCollection = 'cleaning_requests';
}
