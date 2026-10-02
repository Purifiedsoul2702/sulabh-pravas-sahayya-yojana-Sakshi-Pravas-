import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueueService {
  static const _key = 'sakhi_offline_queue';

  Future<void> enqueue(String collection, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode({
      'collection': collection,
      'data': data,
      'queuedAtMs': DateTime.now().millisecondsSinceEpoch,
    }));
    await prefs.setStringList(_key, list);
  }

  Future<int> sync() async {
    final c = await Connectivity().checkConnectivity();
    if (c.contains(ConnectivityResult.none)) return 0;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final failed = <String>[];
    int synced = 0;

    for (final raw in list) {
      try {
        final item = jsonDecode(raw) as Map<String, dynamic>;
        final data = Map<String, dynamic>.from(item['data'] as Map);
        data['syncedAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance
            .collection(item['collection'] as String)
            .add(data);
        synced++;
      } catch (_) {
        failed.add(raw);
      }
    }

    await prefs.setStringList(_key, failed);
    return synced;
  }
}
