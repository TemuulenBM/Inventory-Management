import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Client Singleton
/// Бүх апп дээр нэг л instance ашиглана
class SupabaseClientManager {
  static SupabaseClient? _instance;

  /// Get Supabase client instance
  static SupabaseClient get instance {
    if (_instance == null) {
      throw Exception(
        'SupabaseClientManager not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize Supabase client
  static Future<void> initialize() async {
    // Load environment variables
    await dotenv.load();

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env file',
      );
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: kDebugMode, // Enable debug logging in development
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce, // Use PKCE flow for better security
      ),
    );

    _instance = Supabase.instance.client;

    if (kDebugMode) {
      print('✅ Supabase initialized: $supabaseUrl');
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    return _instance?.auth.currentSession != null;
  }

  /// Get current user
  static User? get currentUser {
    return _instance?.auth.currentUser;
  }

  /// Get current user ID
  static String? get currentUserId {
    return _instance?.auth.currentUser?.id;
  }

  /// Get current user's store ID (from user_metadata)
  static String? get currentUserStoreId {
    final metadata = _instance?.auth.currentUser?.userMetadata;
    return metadata?['store_id'] as String?;
  }

  /// Get current user's role (from user_metadata)
  static String? get currentUserRole {
    final metadata = _instance?.auth.currentUser?.userMetadata;
    return metadata?['app_role'] as String?;
  }

  /// Sign out
  static Future<void> signOut() async {
    await _instance?.auth.signOut();
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    if (_instance == null) {
      throw Exception('SupabaseClientManager not initialized');
    }
    return _instance!.auth.onAuthStateChange;
  }
}

/// Convenience getter for Supabase client
SupabaseClient get supabase => SupabaseClientManager.instance;
