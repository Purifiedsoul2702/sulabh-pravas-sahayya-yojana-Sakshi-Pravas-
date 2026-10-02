import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/profile_service.dart';
import '../../services/safety_service.dart';
import '../../widgets/app_shell.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});
  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  String guardian = '';
  String emergency = '';
  final service = SafetyService();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final p = await ProfileService().getProfile(uid);
    setState(() {
      guardian = p?['guardianPhone'] ?? '';
      emergency = p?['emergencyPhone'] ?? '';
    });
  }

  Future<void> confirmAndCall(String number) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Call'),
        content: Text('Open phone dialer for $number?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue')),
        ],
      ),
    );
    if (ok == true) await service.call(number);
  }

  Future<void> shareLocation() async {
    try {
      final text = await service.currentLocationMessage();
      final phone = emergency.isNotEmpty ? emergency : guardian;
      if (phone.isEmpty) throw Exception('Add an emergency contact in your profile.');
      await service.openSms(phone, text);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      child: Scaffold(
        appBar: AppBar(title: const Text('Safety Help')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.shield_outlined, size: 90),
            const SizedBox(height: 18),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => confirmAndCall(emergency.isNotEmpty ? emergency : '112'),
              icon: const Icon(Icons.sos),
              label: const Text('Emergency SOS'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: shareLocation,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Share My Current Location'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: guardian.isEmpty ? null : () => confirmAndCall(guardian),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('Call Parent / Guardian'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => confirmAndCall('112'),
              icon: const Icon(Icons.emergency_outlined),
              label: const Text('Emergency 112'),
            ),
            const SizedBox(height: 16),
            const Text(
              'The app does not automatically send messages or place emergency calls. The student confirms the action first.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
