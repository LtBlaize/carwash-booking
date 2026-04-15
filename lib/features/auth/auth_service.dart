import 'package:supabase_flutter/supabase_flutter.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message';
}

class AuthService {
  final SupabaseClient _client;

  // Dependency injection for testability
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // Reactive auth state for the UI layer to listen to
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<User> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Login returned no user', code: 'NO_USER');
      }

      return user;
    } on AuthApiException catch (e) {
      // Supabase error codes: 'invalid_credentials', 'email_not_confirmed', etc.
      throw AuthException(e.message, code: e.statusCode.toString());
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Unexpected login error: $e', code: 'UNKNOWN');
    }
  }

  Future<User> register(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AuthException('Registration returned no user', code: 'NO_USER');
      }

      // session is null when email confirmation is required
      if (response.session == null) {
        throw AuthException(
          'Check your email to confirm your account',
          code: 'EMAIL_CONFIRMATION_REQUIRED',
        );
      }

      return user;
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.statusCode.toString());
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Unexpected registration error: $e', code: 'UNKNOWN');
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } on AuthApiException catch (e) {
      throw AuthException(e.message, code: e.statusCode.toString());
    }
  }
  Future<String> getUserName() async {
  final userId = _client.auth.currentUser?.id;
  if (userId == null) return 'User';

  try {
    final response = await _client
        .from('profiles')
        .select('full_name')
        .eq('id', userId)
        .single();

    final name = response['full_name'];
    if (name != null && name.toString().isNotEmpty) {
      return name.toString();
    }

    return _client.auth.currentUser?.userMetadata?['full_name'] ?? 'User';
  } catch (_) {
    return _client.auth.currentUser?.userMetadata?['full_name'] ?? 'User';
  }
}
}
