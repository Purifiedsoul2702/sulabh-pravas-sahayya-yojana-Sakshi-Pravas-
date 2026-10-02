import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: uid == null
          ? const Center(child: Text('Please login.'))
          : StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
              stream: FirebaseFirestore.instance.collection('notifications')
                  .where('userId', isEqualTo: uid).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs.reversed.toList();
                if (docs.isEmpty) return const Center(child: Text('No notifications yet.'));
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: docs.map((d) {
                    final m = d.data();
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.notifications_none),
                        title: Text(m['title'] ?? ''),
                        subtitle: Text(m['message'] ?? ''),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
