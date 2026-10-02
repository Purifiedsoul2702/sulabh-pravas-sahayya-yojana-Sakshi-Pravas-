import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../services/trip_service.dart';

class ReportDelayScreen extends StatefulWidget {
  const ReportDelayScreen({super.key, required this.data});
  final Map<String, String> data;

  @override
  State<ReportDelayScreen> createState() => _ReportDelayScreenState();
}

class _ReportDelayScreenState extends State<ReportDelayScreen> {
  int delay = 10;
  final comment = TextEditingController();
  bool busy = false;

  Future<void> submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => busy = true);

    double? lat, lng;
    try {
      final p = await LocationService().currentPosition();
      lat = p.latitude;
      lng = p.longitude;
    } catch (_) {}

    await TripService().reportDelay(
      userId: uid,
      tripId: widget.data['tripId'] ?? '',
      busId: widget.data['busId'] ?? '',
      routeId: widget.data['routeId'] ?? '',
      delayMinutes: delay,
      comment: comment.text.trim(),
      latitude: lat,
      longitude: lng,
    );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final options = [5,10,15,30,45];
    return Scaffold(
      appBar: AppBar(title: const Text('Report Delay')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('How late is the bus?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: options.map((m) => ChoiceChip(
              label: Text(m == 45 ? '30+ min' : '$m min'),
              selected: delay == m,
              onSelected: (_) => setState(() => delay = m),
            )).toList(),
          ),
          const SizedBox(height: 14),
          TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Comment (optional)')),
          const SizedBox(height: 14),
          FilledButton(onPressed: busy ? null : submit, child: const Text('Submit Delay Report')),
        ],
      ),
    );
  }
}
