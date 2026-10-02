import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/profile_service.dart';
import '../../services/location_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});
  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final age = TextEditingController();
  final className = TextEditingController();
  final college = TextEditingController();
  final village = TextEditingController();
  final nearestStop = TextEditingController();
  final distance = TextEditingController();
  final guardian = TextEditingController();
  final emergency = TextEditingController();

  double? homeLat;
  double? homeLng;
  bool busy = false;

  Future<void> useLocation() async {
    try {
      final p = await LocationService().currentPosition();
      setState(() {
        homeLat = p.latitude;
        homeLng = p.longitude;
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location captured.')),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => busy = true);

    await ProfileService().saveProfile(uid, {
      'age': int.tryParse(age.text),
      'className': className.text.trim(),
      'collegeName': college.text.trim(),
      'village': village.text.trim(),
      'nearestStopName': nearestStop.text.trim(),
      'busStopDistanceKm': double.tryParse(distance.text) ?? 1.0,
      'guardianPhone': guardian.text.trim(),
      'emergencyPhone': emergency.text.trim(),
      'homeLat': homeLat,
      'homeLng': homeLng,
    });

    if (mounted) context.go('/college-schedule');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
          const SizedBox(height: 10),
          TextField(controller: className, decoration: const InputDecoration(labelText: 'Class')),
          const SizedBox(height: 10),
          TextField(controller: college, decoration: const InputDecoration(labelText: 'College')),
          const SizedBox(height: 10),
          TextField(controller: village, decoration: const InputDecoration(labelText: 'Village')),
          const SizedBox(height: 10),
          TextField(controller: nearestStop, decoration: const InputDecoration(labelText: 'Nearest Bus Stop')),
          const SizedBox(height: 10),
          TextField(controller: distance, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Home-to-stop distance (km)')),
          const SizedBox(height: 10),
          TextField(controller: guardian, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Guardian Phone')),
          const SizedBox(height: 10),
          TextField(controller: emergency, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Emergency Phone')),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: useLocation, icon: const Icon(Icons.my_location), label: const Text('Use My Location')),
          const SizedBox(height: 12),
          FilledButton(onPressed: busy ? null : save, child: const Text('Save & Continue')),
        ],
      ),
    );
  }
}
