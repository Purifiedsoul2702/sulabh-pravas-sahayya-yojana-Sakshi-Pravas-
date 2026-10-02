import '../models/app_models.dart';

class TripPlanResult {
  final BusSchedule schedule;
  final int walkMinutes;
  final int boardingBufferMinutes;
  final DateTime leaveHome;
  final DateTime expectedArrival;
  final int collegeBufferMinutes;

  TripPlanResult({
    required this.schedule,
    required this.walkMinutes,
    required this.boardingBufferMinutes,
    required this.leaveHome,
    required this.expectedArrival,
    required this.collegeBufferMinutes,
  });
}

class TripPlannerService {
  // ============================================================
  // SAFE TIME PARSER
  // ============================================================

  DateTime? _at(DateTime date, String time) {
    String value = time.trim();

    if (value.isEmpty) {
      return null;
    }

    // Accept common separators:
    // 07:30
    // 07.30
    // 07-30
    value = value
        .replaceAll('.', ':')
        .replaceAll('-', ':');

    final parts = value.split(':');

    // A valid time must contain hour and minute.
    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());

    if (hour == null || minute == null) {
      return null;
    }

    // Validate time range.
    if (hour < 0 || hour > 23) {
      return null;
    }

    if (minute < 0 || minute > 59) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  // ============================================================
  // RECOMMEND BEST JOURNEY
  // ============================================================

  TripPlanResult? recommend({
    required List<BusSchedule> schedules,
    required DateTime requiredArrival,
    required int walkMinutes,
    int boardingBufferMinutes = 10,
  }) {
    // No schedules available.
    if (schedules.isEmpty) {
      return null;
    }

    // ==========================================================
    // STEP 1: REMOVE SCHEDULES WITH INVALID TIME VALUES
    // ==========================================================

    final validSchedules = schedules.where((schedule) {
      final departure = _at(
        requiredArrival,
        schedule.departureTime,
      );

      final arrival = _at(
        requiredArrival,
        schedule.expectedArrivalTime,
      );

      return departure != null && arrival != null;
    }).toList();

    if (validSchedules.isEmpty) {
      return null;
    }

    // ==========================================================
    // STEP 2: FIND SCHEDULES THAT REACH COLLEGE ON TIME
    // ==========================================================

    final viable = validSchedules.where((schedule) {
      final arrival = _at(
        requiredArrival,
        schedule.expectedArrivalTime,
      );

      if (arrival == null) {
        return false;
      }

      // Bus must arrive on or before the student's
      // required college arrival time.
      return !arrival.isAfter(requiredArrival);
    }).toList();

    if (viable.isEmpty) {
      return null;
    }

    // ==========================================================
    // STEP 3: CHOOSE THE LATEST SUITABLE ARRIVAL
    // ==========================================================

    viable.sort((a, b) {
      final aArrival = _at(
        requiredArrival,
        a.expectedArrivalTime,
      );

      final bArrival = _at(
        requiredArrival,
        b.expectedArrivalTime,
      );

      if (aArrival == null && bArrival == null) {
        return 0;
      }

      if (aArrival == null) {
        return 1;
      }

      if (bArrival == null) {
        return -1;
      }

      // Latest suitable arrival comes first.
      return bArrival.compareTo(aArrival);
    });

    final best = viable.first;

    // ==========================================================
    // STEP 4: CONVERT SELECTED SCHEDULE TIMES
    // ==========================================================

    final departure = _at(
      requiredArrival,
      best.departureTime,
    );

    final arrival = _at(
      requiredArrival,
      best.expectedArrivalTime,
    );

    if (departure == null || arrival == null) {
      return null;
    }

    // ==========================================================
    // STEP 5: CALCULATE WHEN STUDENT SHOULD LEAVE HOME
    // ==========================================================

    final leaveHome = departure.subtract(
      Duration(
        minutes:
        walkMinutes + boardingBufferMinutes,
      ),
    );

    // ==========================================================
    // STEP 6: CALCULATE COLLEGE ARRIVAL BUFFER
    // ==========================================================

    final collegeBufferMinutes =
        requiredArrival
            .difference(arrival)
            .inMinutes;

    // ==========================================================
    // RETURN RECOMMENDED JOURNEY
    // ==========================================================

    return TripPlanResult(
      schedule: best,
      walkMinutes: walkMinutes,
      boardingBufferMinutes:
      boardingBufferMinutes,
      leaveHome: leaveHome,
      expectedArrival: arrival,
      collegeBufferMinutes:
      collegeBufferMinutes,
    );
  }
}