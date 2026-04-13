import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'auth_controller.dart';
import 'validators.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _name     = TextEditingController();
  final _email    = TextEditingController();
  final _phone    = TextEditingController();
  final _password = TextEditingController();

  final _auth = AuthController();

  bool _loading = false;
  bool _obscurePassword = true;
  double _passwordStrength = 0;
  String _strengthLabel = '';
  Color  _strengthColor = Colors.transparent;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    int score = 0;
    if (value.length >= 8)                        score++;
    if (RegExp(r'[A-Z]').hasMatch(value))         score++;
    if (RegExp(r'[0-9]').hasMatch(value))         score++;
    if (RegExp(r'[!@#\$&*~%^]').hasMatch(value))  score++;

    setState(() {
      _passwordStrength = score / 4;
      final (label, color) = switch (score) {
        1 => ('Weak',   const Color(0xFFE24B4A)),
        2 => ('Fair',   const Color(0xFFEF9F27)),
        3 => ('Good',   const Color(0xFF639922)),
        4 => ('Strong', const Color(0xFF1D9E75)),
        _ => ('',       Colors.transparent),
      };
      _strengthLabel = label;
      _strengthColor = color;
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // 1. Create auth user
      await _auth.register(_email.text.trim(), _password.text);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw AuthException('Signup failed', code: 'NO_USER');

      // 2. Insert profile row
      await Supabase.instance.client.from('profiles').insert({
        'id':         user.id,
        'full_name':  _name.text.trim(),
        'phone':      _phone.text.trim().replaceAll(RegExp(r'[\s\-()]'), ''),
        'role':       'customer',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');

    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(_mapCode(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapCode(String? code) => switch (code) {
    'user_already_exists'  => 'An account with this email already exists.',
    'email_not_confirmed'  => 'Check your inbox to confirm your email.',
    'weak_password'        => 'Please choose a stronger password.',
    _                      => 'Registration failed. Please try again.',
  };

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _Header(),
                const SizedBox(height: 28),

                if (_loading) ...[
                  LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(2),
                    minHeight: 3,
                    color: scheme.onSurface,
                    backgroundColor: scheme.surfaceContainerHighest,
                  ),
                  const SizedBox(height: 16),
                ],

                _AuthField(
                  label: 'Full name',
                  controller: _name,
                  validator: Validators.name,
                  keyboardType: TextInputType.name,
                  autofillHints: const [AutofillHints.name],
                  placeholder: 'Jane Dela Cruz',
                ),
                const SizedBox(height: 12),

                _AuthField(
                  label: 'Email',
                  controller: _email,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  placeholder: 'you@example.com',
                ),
                const SizedBox(height: 12),

                _AuthField(
                  label: 'Phone',
                  controller: _phone,
                  validator: Validators.phone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  placeholder: '+63 917 123 4567',
                ),
                const SizedBox(height: 12),

                _AuthField(
                  label: 'Password',
                  controller: _password,
                  validator: Validators.password,
                  obscureText: _obscurePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  placeholder: 'Min. 8 characters',
                  onChanged: _onPasswordChanged,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                if (_passwordStrength > 0) ...[
                  const SizedBox(height: 8),
                  _StrengthIndicator(
                    strength: _passwordStrength,
                    label: _strengthLabel,
                    color: _strengthColor,
                  ),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _register,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    child: Text(
                      _loading ? 'Creating account...' : 'Create account'),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'Already have an account? '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context, '/login'),
                            child: Text('Sign in',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create account',
          style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Fill in your details to get started',
          style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.validator,
    this.placeholder,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final String? placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        hintStyle: TextStyle(
          fontSize: 13,
          color: scheme.onSurfaceVariant.withOpacity(0.5)),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant),
        suffixIcon: suffix,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: scheme.outlineVariant, width: 0.5)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: scheme.outlineVariant, width: 0.5)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error)),
        errorStyle: TextStyle(fontSize: 11, color: scheme.error),
      ),
    );
  }
}

class _StrengthIndicator extends StatelessWidget {
  const _StrengthIndicator({
    required this.strength,
    required this.label,
    required this.color,
  });

  final double strength;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 3,
            backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
          style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}