import 'package:flutter/material.dart';
import 'auth_controller.dart';
import 'validators.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthController();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.login(_email.text.trim(), _password.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showError(_mapErrorCode(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapErrorCode(String? code) => switch (code) {
    'invalid_credentials' => 'Incorrect email or password.',
    'email_not_confirmed' => 'Please confirm your email first.',
    'too_many_requests'   => 'Too many attempts. Try again later.',
    _                     => 'Login failed. Please try again.',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
  }
  

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _BrandHeader(),
                  const SizedBox(height: 32),
                  if (_loading)
                    LinearProgressIndicator(
                      borderRadius: BorderRadius.circular(2),
                      minHeight: 3,
                      color: scheme.onSurface,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  if (_loading) const SizedBox(height: 16),
                  _AuthField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 12),
                  _AuthField(
                    label: 'Password',
                    controller: _password,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    autofillHints: const [AutofillHints.password],
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                      child: const Text('Forgot password?',
                        style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _PrimaryButton(
                    label: _loading ? 'Signing in...' : 'Sign in',
                    onPressed: _loading ? null : _login,
                  ),
                  const SizedBox(height: 16),
                  _Divider(),
                  const SizedBox(height: 12),
                  _GoogleButton(),
                  const SizedBox(height: 24),
                  _FooterLink(
                    text: "Don't have an account? ",
                    linkText: 'Create one',
                    onTap: () =>
                      Navigator.pushReplacementNamed(context, '/register'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          child: const Icon(Icons.add, size: 26),
        ),
        const SizedBox(height: 14),
        Text('Welcome back',
          style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text('Sign in to your account',
          style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.autofillHints,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.error),
        ),
        errorStyle: TextStyle(fontSize: 12, color: scheme.error),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500),
        ),
        child: Text(label),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('or continue with',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () { /* wire up Supabase Google OAuth */ },
        icon: _GoogleLogo(),
        label: const Text('Continue with Google',
          style: TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 11),
          side: BorderSide(color: scheme.outlineVariant, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
            
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 16;
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height),
      -1.39, 5.58, false,
      Paint()..color = const Color(0xFF4285F4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s);
    canvas.drawRect(
      Rect.fromLTWH(size.width / 2, size.height / 2 - 1.5 * s, size.width / 2, 3 * s),
      Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 13,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(text: text),
          WidgetSpan(
            child: GestureDetector(
              onTap: onTap,
              child: Text(linkText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                )),
            ),
          ),
        ],
      ),
    );
  }
}