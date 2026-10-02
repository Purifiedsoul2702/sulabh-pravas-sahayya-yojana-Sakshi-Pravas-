import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/trip_service.dart';

class TravelProblemScreen extends StatefulWidget {
  const TravelProblemScreen({super.key, required this.data});
  final Map<String, String> data;

  @override
  State<TravelProblemScreen> createState() => _TravelProblemScreenState();
}

class _TravelProblemScreenState extends State<TravelProblemScreen> {
  final problems = [
    'Bus delayed','Bus cancelled','Bus did not stop','Bus overcrowded',
    'No seat','Long waiting time','Long distance to stop',
    'Unsafe waiting area','Harassment / safety concern','Road problem','Other'
  ];
  final impacts = ['No','Reached Late','Missed One Lecture','Missed Multiple Lectures','Could Not Attend'];

  String problem = 'Bus delayed';
  String impact = 'No';
  final comment = TextEditingController();

  Future<void> submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await TripService().reportProblem(
      userId: uid,
      tripId: widget.data['tripId'] ?? '',
      busId: widget.data['busId'] ?? '',
      routeId: widget.data['routeId'] ?? '',
      problemType: problem,
      attendanceImpact: impact,
      comment: comment.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Problem')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: problem,
            decoration: const InputDecoration(labelText: 'Problem'),
            items: problems.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => problem = v!),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: impact,
            decoration: const InputDecoration(labelText: 'Attendance Impact'),
            items: impacts.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) => setState(() => impact = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(labelText: 'Comment (optional)')),
          const SizedBox(height: 14),
          FilledButton(onPressed: submit, child: const Text('Submit')),
        ],
      ),
    );
  }
}
