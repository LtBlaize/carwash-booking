class Validators {
  static String? email(String? value) {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? password(String? value) {
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');

    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Password must be 8+ chars, include uppercase, number, symbol';
    }
    return null;
  }

  static String? phone(String? value) {
    final regex = RegExp(r'^\+63\d{10}$');

    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (!regex.hasMatch(value)) {
      return 'Use format +639XXXXXXXXX';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter valid name';
    }
    return null;
  }
}