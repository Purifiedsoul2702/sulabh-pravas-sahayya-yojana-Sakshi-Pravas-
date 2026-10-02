import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_models.dart';

class BusRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<BusStop>> getActiveStops() async {
    final q = await _db.collection('busStops').where('active', isEqualTo: true).get();
    return q.docs.map(BusStop.fromDoc).toList();
  }

  Future<List<BusRoute>> getActiveRoutes() async {
    final q = await _db.collection('routes').where('active', isEqualTo: true).get();
    return q.docs.map(BusRoute.fromDoc).toList();
  }

  Future<List<BusSchedule>> getSchedulesForRoute(String routeId) async {
    final q = await _db
        .collection('busSchedules')
        .where('routeId', isEqualTo: routeId)
        .where('active', isEqualTo: true)
        .get();
    return q.docs.map(BusSchedule.fromDoc).toList();
  }

  Future<Map<String, dynamic>?> getBus(String busId) async {
    final d = await _db.collection('buses').doc(busId).get();
    return d.data();
  }
}
