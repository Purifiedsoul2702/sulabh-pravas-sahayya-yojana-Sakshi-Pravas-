import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/app_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return AppShell(
      currentIndex: 4,
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: uid == null
            ? const Center(child: Text('Please login.'))
            : FutureBuilder<Map<String,dynamic>?>(
                future: ProfileService().getProfile(uid),
                builder: (context, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                  final p = snap.data ?? {};
                  return ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 44)),
                      const SizedBox(height: 14),
                      Center(child: Text(p['fullName'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                      Center(child: Text(p['className'] ?? '')),
                      const SizedBox(height: 20),
                      Card(child: ListTile(title: const Text('Village'), trailing: Text(p['village'] ?? '-'))),
                      Card(child: ListTile(title: const Text('Nearest Stop'), trailing: Text(p['nearestStopName'] ?? '-'))),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => context.push('/college-schedule'),
                        child: const Text('Edit College Schedule'),
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          await AuthService().logout();
                          if (context.mounted) context.go('/login');
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
