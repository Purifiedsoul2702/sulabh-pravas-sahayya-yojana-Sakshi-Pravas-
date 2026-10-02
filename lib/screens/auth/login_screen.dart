import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/notification_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  String? error;

  Future<void> submit() async {
    setState(() { busy = true; error = null; });
    try {
      final cred = await AuthService().login(email.text, password.text);


await NotificationService().registerToken(cred.user!.uid);

      final profile = await ProfileService().getProfile(cred.user!.uid);
      if (!mounted) return;

      if (profile?['role'] == 'admin') {
        context.go('/admin');
      } else if (profile?['profileComplete'] == true) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          TextField(controller: email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
          if (error != null) Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait...' : 'Login')),
          TextButton(onPressed: () => context.go('/register'), child: const Text('Create account')),
        ],
      ),
    );
  }
}
