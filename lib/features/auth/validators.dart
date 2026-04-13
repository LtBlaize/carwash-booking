import 'package:flutter/material.dart';

class Validators {
  // Matches: local@domain.tld — rejects missing TLD, double dots, etc.
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );

  // E.164-ish: optional +, then 7–15 digits (covers most global formats)
  static final _phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');

  // Rejects digits and most special characters in names
  static final _nameRegex = RegExp(r"^[a-zA-Z\s'\-\.]+$");

  // ── Core validators ────────────────────────────────────────────────────────

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) return 'Include at least one uppercase letter';
    if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
    if (!v.contains(RegExp(r'[!@#\$&*~%^]'))) return 'Include at least one special character';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final base = password(value);
    if (base != null) return base;
    if (value != original) return 'Passwords do not match';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim().replaceAll(RegExp(r'[\s\-()]'), '') ?? '';
    if (v.isEmpty) return 'Phone number is required';
    if (!_phoneRegex.hasMatch(v)) return 'Enter a valid phone number (e.g. +639171234567)';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 2) return 'Name must be at least 2 characters';
    if (!_nameRegex.hasMatch(v)) return 'Name contains invalid characters';
    return null;
  }

  // ── Modifier: makes any validator optional ─────────────────────────────────
  //
  // Usage: Validators.optional(Validators.phone)(value)
  // Returns null if empty, otherwise runs the wrapped validator normally.

  static FormFieldValidator<String> optional(FormFieldValidator<String> validator) {
    return (value) {
      if (value == null || value.trim().isEmpty) return null;
      return validator(value);
    };
  }

  // ── Modifier: chains multiple validators left-to-right ─────────────────────
  //
  // Usage: Validators.compose([Validators.name, noNumbers])(value)
  // Stops and returns the first failure.

  static FormFieldValidator<String> compose(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}