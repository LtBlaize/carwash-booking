import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_service.dart';
import 'validators.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  final _auth = AuthService();

  bool loading = false;

  void register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await _auth.register(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      );

      if (mounted) context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 50),
              const Text("Create Account", style: TextStyle(fontSize: 28)),

              TextFormField(
                controller: _name,
                validator: Validators.name,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),

              TextFormField(
                controller: _email,
                validator: Validators.email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextFormField(
                controller: _phone,
                validator: Validators.phone,
                decoration: const InputDecoration(labelText: "Phone (+63...)"),
              ),

              TextFormField(
                controller: _password,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(labelText: "Password"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: loading ? null : register,
                child: Text(loading ? "Creating..." : "Register"),
              ),

              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text("Back to login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}