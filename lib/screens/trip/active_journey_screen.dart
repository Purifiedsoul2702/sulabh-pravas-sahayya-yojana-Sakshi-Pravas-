import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveJourneyScreen extends StatelessWidget {
  const ActiveJourneyScreen({super.key, required this.data});
  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Journey')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Journey in progress', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Text('Departure: ${data['departure'] ?? '-'}'),
                  Text('Expected arrival: ${data['arrival'] ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => context.push('/report-delay', extra: data),
            icon: const Icon(Icons.schedule),
            label: const Text('Report Delay'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.push('/travel-problem', extra: data),
            icon: const Icon(Icons.report_problem_outlined),
            label: const Text('Travel Problem'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.push('/safety'),
            icon: const Icon(Icons.shield_outlined),
            label: const Text('Safety Help'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => context.push('/reached-college', extra: data),
            icon: const Icon(Icons.school_outlined),
            label: const Text('Reached College'),
          ),
        ],
      ),
    );
  }
}
