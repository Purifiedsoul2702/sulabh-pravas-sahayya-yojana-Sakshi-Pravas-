import 'package:cloud_firestore/cloud_firestore.dart';

class BusStop {
  final String id;
  final String stopName;
  final String village;
  final double latitude;
  final double longitude;
  final bool active;

  const BusStop({
    required this.id,
    required this.stopName,
    required this.village,
    required this.latitude,
    required this.longitude,
    required this.active,
  });

  factory BusStop.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return BusStop(
      id: doc.id,
      stopName: m['stopName'] ?? '',
      village: m['village'] ?? '',
      latitude: (m['latitude'] ?? 0).toDouble(),
      longitude: (m['longitude'] ?? 0).toDouble(),
      active: m['active'] ?? true,
    );
  }
}

class BusRoute {
  final String id;
  final String routeName;
  final String sourceStopId;
  final String destinationStopId;
  final List<String> stopIds;
  final int estimatedDurationMinutes;
  final bool active;

  const BusRoute({
    required this.id,
    required this.routeName,
    required this.sourceStopId,
    required this.destinationStopId,
    required this.stopIds,
    required this.estimatedDurationMinutes,
    required this.active,
  });

  factory BusRoute.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return BusRoute(
      id: doc.id,
      routeName: m['routeName'] ?? '',
      sourceStopId: m['sourceStopId'] ?? '',
      destinationStopId: m['destinationStopId'] ?? '',
      stopIds: List<String>.from(m['stopIds'] ?? const []),
      estimatedDurationMinutes: m['estimatedDurationMinutes'] ?? 0,
      active: m['active'] ?? true,
    );
  }
}

class BusSchedule {
  final String id;
  final String busId;
  final String routeId;
  final String departureTime;
  final String expectedArrivalTime;
  final List<String> daysOfWeek;
  final bool active;

  const BusSchedule({
    required this.id,
    required this.busId,
    required this.routeId,
    required this.departureTime,
    required this.expectedArrivalTime,
    required this.daysOfWeek,
    required this.active,
  });

  factory BusSchedule.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return BusSchedule(
      id: doc.id,
      busId: m['busId'] ?? '',
      routeId: m['routeId'] ?? '',
      departureTime: m['departureTime'] ?? '',
      expectedArrivalTime: m['expectedArrivalTime'] ?? '',
      daysOfWeek: List<String>.from(m['daysOfWeek'] ?? const []),
      active: m['active'] ?? true,
    );
  }
}
