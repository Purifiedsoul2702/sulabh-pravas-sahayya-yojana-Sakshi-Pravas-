import 'package:cloud_firestore/cloud_firestore.dart';

import 'offline_queue_service.dart';

class TripService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  final OfflineQueueService _queue =
  OfflineQueueService();

  // ===========================================================
  // START TRIP
  // ===========================================================

  Future<String> startTrip({
    required String userId,
    required String busId,
    required String routeId,
    required DateTime expectedArrival,
  }) async {
    final doc =
    await _db.collection('trips').add({
      'userId': userId,
      'busId': busId,
      'routeId': routeId,

      'startTime':
      FieldValue.serverTimestamp(),

      'expectedArrival':
      Timestamp.fromDate(expectedArrival),

      'actualArrival': null,

      'status': 'active',

      'attendanceOutcome': '',

      'createdAt':
      FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // ===========================================================
  // REPORT DELAY
  // ===========================================================

  Future<void> reportDelay({
    required String userId,
    required String tripId,
    required String busId,
    required String routeId,
    required int delayMinutes,
    String comment = '',
    double? latitude,
    double? longitude,
  }) async {
    final data = {
      'userId': userId,
      'tripId': tripId,
      'busId': busId,
      'routeId': routeId,
      'delayMinutes': delayMinutes,
      'comment': comment,
      'latitude': latitude,
      'longitude': longitude,

      'createdAtMs':
      DateTime.now()
          .millisecondsSinceEpoch,
    };

    try {
      await _db
          .collection('delayReports')
          .add({
        ...data,

        'createdAt':
        FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _queue.enqueue(
        'delayReports',
        data,
      );
    }
  }

  // ===========================================================
  // REPORT TRAVEL PROBLEM
  // ===========================================================

  Future<void> reportProblem({
    required String userId,
    required String tripId,
    required String busId,
    required String routeId,
    required String problemType,
    required String attendanceImpact,
    String comment = '',
  }) async {
    final data = {
      'userId': userId,
      'tripId': tripId,
      'busId': busId,
      'routeId': routeId,

      'problemType': problemType,

      'attendanceImpact':
      attendanceImpact,

      'comment': comment,

      'createdAtMs':
      DateTime.now()
          .millisecondsSinceEpoch,
    };

    try {
      await _db
          .collection('travelProblems')
          .add({
        ...data,

        'createdAt':
        FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await _queue.enqueue(
        'travelProblems',
        data,
      );
    }
  }

  // ===========================================================
  // COMPLETE TRIP
  //
  // IMPORTANT:
  //
  // Attendance document ID = trip ID
  //
  // Example:
  //
  // trips/ABC123
  //
  // attendance/ABC123
  //
  // Therefore the same trip cannot create multiple
  // attendance documents.
  //
  // We intentionally DO NOT read attendance/{tripId}
  // before writing it.
  //
  // This avoids the Firestore permission problem caused by
  // trying to read a document that does not exist yet.
  // ===========================================================

  Future<void> completeTrip({
    required String tripId,
    required String userId,
    required String outcome,
    required String reason,
    required bool transportRelated,
  }) async {
    // ---------------------------------------------------------
    // VALIDATE TRIP ID
    // ---------------------------------------------------------

    final cleanTripId =
    tripId.trim();

    if (cleanTripId.isEmpty) {
      throw ArgumentError(
        'Trip ID cannot be empty.',
      );
    }

    // ---------------------------------------------------------
    // VALIDATE USER ID
    // ---------------------------------------------------------

    final cleanUserId =
    userId.trim();

    if (cleanUserId.isEmpty) {
      throw ArgumentError(
        'User ID cannot be empty.',
      );
    }

    // ---------------------------------------------------------
    // VALIDATE OUTCOME
    // ---------------------------------------------------------

    const allowedOutcomes = {
      'Reached On Time',
      'Reached Late',
      'Could Not Attend',
    };

    if (!allowedOutcomes.contains(outcome)) {
      throw ArgumentError(
        'Invalid attendance outcome.',
      );
    }

    // ---------------------------------------------------------
    // CLEAN / VALIDATE REASON
    // ---------------------------------------------------------

    final cleanReason =
    reason.trim();

    if (outcome != 'Reached On Time' &&
        cleanReason.isEmpty) {
      throw ArgumentError(
        'A reason is required for this outcome.',
      );
    }

    // ---------------------------------------------------------
    // TRANSPORT-RELATED CLASSIFICATION
    //
    // Only "Could Not Attend" can become a
    // transport-related absence.
    //
    // Reached On Time = false
    // Reached Late    = false
    // Could Not Attend = student's explicit Yes/No answer
    // ---------------------------------------------------------

    final bool finalTransportRelated;

    if (outcome == 'Could Not Attend') {
      finalTransportRelated =
          transportRelated;
    } else {
      finalTransportRelated = false;
    }

    // ---------------------------------------------------------
    // FIRESTORE REFERENCES
    // ---------------------------------------------------------

    final tripRef =
    _db
        .collection('trips')
        .doc(cleanTripId);

    // IMPORTANT:
    //
    // We use tripId itself as the attendance document ID.
    //
    // This gives us duplicate protection without first
    // reading the attendance document.
    final attendanceRef =
    _db
        .collection('attendance')
        .doc(cleanTripId);

    // ---------------------------------------------------------
    // TRANSACTION
    // ---------------------------------------------------------

    await _db.runTransaction(
          (transaction) async {
        // -----------------------------------------------------
        // READ ONLY THE TRIP
        // -----------------------------------------------------

        final tripSnapshot =
        await transaction.get(
          tripRef,
        );

        if (!tripSnapshot.exists) {
          throw StateError(
            'Trip record was not found.',
          );
        }

        final tripData =
        tripSnapshot.data();

        if (tripData == null) {
          throw StateError(
            'Trip data is unavailable.',
          );
        }

        // -----------------------------------------------------
        // VERIFY TRIP OWNERSHIP
        // -----------------------------------------------------

        final tripUserId =
            tripData['userId']
                ?.toString() ??
                '';

        if (tripUserId != cleanUserId) {
          throw StateError(
            'This trip does not belong to the current student.',
          );
        }

        // -----------------------------------------------------
        // UPDATE TRIP
        // -----------------------------------------------------

        transaction.update(
          tripRef,
          {
            'actualArrival':
            FieldValue.serverTimestamp(),

            'status':
            'completed',

            'attendanceOutcome':
            outcome,

            'attendanceReason':
            outcome == 'Reached On Time'
                ? ''
                : cleanReason,

            'transportRelatedAbsence':
            finalTransportRelated,

            'completedAt':
            FieldValue.serverTimestamp(),
          },
        );

        // -----------------------------------------------------
        // SAVE ATTENDANCE
        //
        // No transaction.get(attendanceRef) is performed.
        //
        // Because the document ID is always tripId:
        //
        // attendance/{tripId}
        //
        // repeating this operation writes to the same
        // document rather than creating another one.
        // -----------------------------------------------------

        transaction.set(
          attendanceRef,
          {
            'userId':
            cleanUserId,

            'tripId':
            cleanTripId,

            'date':
            FieldValue.serverTimestamp(),

            'status':
            outcome,

            'reason':
            outcome == 'Reached On Time'
                ? ''
                : cleanReason,

            'transportRelated':
            finalTransportRelated,

            'preOrPostIntervention':
            'post',

            'updatedAt':
            FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      },
    );
  }
}