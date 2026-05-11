// ✅ FIX: Removed duplicate AuthException class definition.
//         AuthException lives in auth_service.dart — import it from there.
//         Having two definitions causes a clash when both files are imported
//         in the same page (e.g. register_page.dart imports both).
import '../../../../core/services/auth_service.dart';

export '../../../../core/services/auth_service.dart' show AuthException;

class AuthController {
  final AuthService _service;

  AuthController({AuthService? service}) : _service = service ?? AuthService();

  Future<void> login(String email, String password) async {
    _validateCredentials(email, password);
    try {
      await _service.login(email, password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}', code: 'LOGIN_ERROR');
    }
  }

  Future<void> register(String email, String password) async {
    _validateCredentials(email, password);
    try {
      await _service.register(email, password);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(
          'Registration failed: ${e.toString()}', code: 'REGISTER_ERROR');
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (e) {
      throw AuthException('Logout failed: ${e.toString()}',
          code: 'LOGOUT_ERROR');
    }
  }

  void _validateCredentials(String email, String password) {
    if (email.isEmpty || !email.contains('@')) {
      throw AuthException('Invalid email format', code: 'INVALID_EMAIL');
    }
    if (password.length < 8) {
      throw AuthException('Password must be at least 8 characters',
          code: 'WEAK_PASSWORD');
    }
  }
}