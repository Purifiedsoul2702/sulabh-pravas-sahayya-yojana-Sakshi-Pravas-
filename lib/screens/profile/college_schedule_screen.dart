import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/profile_service.dart';

class CollegeScheduleScreen extends StatefulWidget {
  const CollegeScheduleScreen({super.key});
  @override
  State<CollegeScheduleScreen> createState() => _CollegeScheduleScreenState();
}

class _CollegeScheduleScreenState extends State<CollegeScheduleScreen> {
  final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  final Map<String, TimeOfDay> starts = {};
  final Map<String, TimeOfDay> ends = {};

  @override
  void initState() {
    super.initState();
    for (final d in days) {
      starts[d] = const TimeOfDay(hour: 10, minute: 30);
      ends[d] = const TimeOfDay(hour: 16, minute: 0);
    }
  }

  Future<void> pick(String day, bool start) async {
    final current = start ? starts[day]! : ends[day]!;
    final t = await showTimePicker(context: context, initialTime: current);
    if (t != null) {
      setState(() => start ? starts[day] = t : ends[day] = t);
    }
  }

  String fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  Future<void> save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = <String,dynamic>{};

    for (final d in days) {
      data[d.toLowerCase()] = {
        'start': fmt(starts[d]!),
        'end': fmt(ends[d]!),
        'enabled': true,
      };
    }

    await ProfileService().saveCollegeSchedule(uid, data);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Schedule')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...days.map((d) => Card(
            child: ListTile(
              title: Text(d),
              subtitle: Text('${fmt(starts[d]!)} – ${fmt(ends[d]!)}'),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                await pick(d, true);
                if (mounted) await pick(d, false);
              },
            ),
          )),
          const SizedBox(height: 10),
          FilledButton(onPressed: save, child: const Text('Save Schedule')),
        ],
      ),
    );
  }
}
