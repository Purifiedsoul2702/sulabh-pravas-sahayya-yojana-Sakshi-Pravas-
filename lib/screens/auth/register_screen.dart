import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool consent = false;
  bool busy = false;

  Future<void> submit() async {
    if (!consent || password.text != confirm.text || password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check consent and password fields.')),
      );
      return;
    }

    setState(() => busy = true);
    try {
      await AuthService().register(
        name: name.text,
        mobile: mobile.text,
        email: email.text,
        password: password.text,
        consent: consent,
      );
      if (mounted) context.go('/profile-setup');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 10),
          TextField(controller: mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile')),
          const SizedBox(height: 10),
          TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 10),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          const SizedBox(height: 10),
          TextField(controller: confirm, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password')),
          CheckboxListTile(
            value: consent,
            onChanged: (v) => setState(() => consent = v ?? false),
            title: const Text('I consent to participate in the research pilot.'),
            contentPadding: EdgeInsets.zero,
          ),
          FilledButton(onPressed: busy ? null : submit, child: const Text('Register')),
        ],
      ),
    );
  }
}
