import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/bus_repository.dart';

class BusDetailsScreen extends StatefulWidget {
  const BusDetailsScreen({super.key, required this.data});
  final Map<String, String> data;

  @override
  State<BusDetailsScreen> createState() => _BusDetailsScreenState();
}

class _BusDetailsScreenState extends State<BusDetailsScreen> {
  Map<String, dynamic>? bus;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    bus = await BusRepository().getBus(widget.data['busId'] ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bus Details')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bus?['busName'] ?? 'Bus', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Bus no.: ${bus?['busNumber'] ?? '-'}'),
                  Text('Departure: ${widget.data['departure'] ?? '-'}'),
                  Text('Expected arrival: ${widget.data['arrival'] ?? '-'}'),
                  const SizedBox(height: 8),
                  const Text('Status: Scheduled / admin-maintained data'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/plan-trip'),
            child: const Text('Use This Route'),
          ),
        ],
      ),
    );
  }
}
