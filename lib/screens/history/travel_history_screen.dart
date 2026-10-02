import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TravelHistoryScreen extends StatelessWidget {
  const TravelHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Travel History')),
      body: uid == null
          ? const Center(child: Text('Please login.'))
          : StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('trips')
                  .where('userId', isEqualTo: uid).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs.reversed.toList();
                if (docs.isEmpty) return const Center(child: Text('No trips recorded yet.'));
                return ListView(
                  padding: const EdgeInsets.all(14),
                  children: docs.map((d) {
                    final m = d.data();
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.route_outlined),
                        title: Text(m['routeId'] ?? 'Trip'),
                        subtitle: Text('Status: ${m['status'] ?? '-'}\nAttendance: ${m['attendanceOutcome'] ?? '-'}'),
                        isThreeLine: true,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
