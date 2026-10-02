import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================
  // COLLECTION STREAM
  // ===========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> collectionStream(
      String name,
      ) {
    return _db.collection(name).snapshots();
  }

  // ===========================================================
  // CRUD
  // ===========================================================

  Future<void> add(
      String collection,
      Map<String, dynamic> data,
      ) async {
    await _db.collection(collection).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update(
      String collection,
      String id,
      Map<String, dynamic> data,
      ) async {
    await _db.collection(collection).doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(
      String collection,
      String id,
      ) {
    return _db.collection(collection).doc(id).delete();
  }

  // ===========================================================
  // GENERAL DASHBOARD SUMMARY
  // ===========================================================

  Future<Map<String, dynamic>> summary() async {
    final students = await _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final routes =
    await _db.collection('routes').get();

    final delays =
    await _db.collection('delayReports').get();

    final problems =
    await _db.collection('travelProblems').get();

    final attendance =
    await _db.collection('attendance').get();

    int late = 0;
    int transportAbsences = 0;

    double delayTotal = 0;
    int validDelayReports = 0;

    // ---------------------------------------------------------
    // ATTENDANCE ANALYSIS
    // ---------------------------------------------------------

    for (final d in attendance.docs) {
      final m = d.data();

      if (m['status'] == 'Reached Late') {
        late++;
      }

      if (m['status'] == 'Could Not Attend' &&
          m['transportRelated'] == true) {
        transportAbsences++;
      }
    }

    // ---------------------------------------------------------
    // DELAY ANALYSIS
    // ---------------------------------------------------------

    for (final d in delays.docs) {
      final value = d.data()['delayMinutes'];

      if (value is num) {
        delayTotal += value.toDouble();
        validDelayReports++;
      } else if (value != null) {
        final parsed =
        double.tryParse(value.toString());

        if (parsed != null) {
          delayTotal += parsed;
          validDelayReports++;
        }
      }
    }

    final averageDelay =
    validDelayReports == 0
        ? 0.0
        : delayTotal / validDelayReports;

    return {
      'students': students.docs.length,
      'routes': routes.docs.length,
      'delayReports': delays.docs.length,
      'travelProblems': problems.docs.length,
      'lateArrivals': late,
      'transportAbsences': transportAbsences,
      'averageDelay': averageDelay,
    };
  }

  // ===========================================================
  // PRE / POST RESEARCH ANALYTICS
  // ===========================================================

  Future<Map<String, dynamic>> prePost() async {
    final q =
    await _db.collection('researchData').get();

    double preAttendanceTotal = 0;
    double postAttendanceTotal = 0;

    double preLateTotal = 0;
    double postLateTotal = 0;

    double preTransportTotal = 0;
    double postTransportTotal = 0;

    int attendanceN = 0;
    int lateN = 0;
    int transportN = 0;

    for (final d in q.docs) {
      final data = d.data();

      // -------------------------------------------------------
      // ATTENDANCE
      // -------------------------------------------------------

      final preAttendance =
      _toDouble(
        data['preAttendancePercentage'],
      );

      final postAttendance =
      _toDouble(
        data['postAttendancePercentage'],
      );

      // Paired complete records only.
      if (preAttendance != null &&
          postAttendance != null) {
        preAttendanceTotal += preAttendance;
        postAttendanceTotal += postAttendance;
        attendanceN++;
      }

      // -------------------------------------------------------
      // LATE ARRIVALS
      // -------------------------------------------------------

      final preLate =
      _toDouble(data['preLateArrivals']);

      final postLate =
      _toDouble(data['postLateArrivals']);

      if (preLate != null &&
          postLate != null) {
        preLateTotal += preLate;
        postLateTotal += postLate;
        lateN++;
      }

      // -------------------------------------------------------
      // TRANSPORT ABSENCES
      // -------------------------------------------------------

      final preTransport =
      _toDouble(
        data['preTransportAbsences'],
      );

      final postTransport =
      _toDouble(
        data['postTransportAbsences'],
      );

      if (preTransport != null &&
          postTransport != null) {
        preTransportTotal += preTransport;
        postTransportTotal += postTransport;
        transportN++;
      }
    }

    // ---------------------------------------------------------
    // MEANS
    // ---------------------------------------------------------

    final preAttendanceMean =
    attendanceN == 0
        ? 0.0
        : preAttendanceTotal / attendanceN;

    final postAttendanceMean =
    attendanceN == 0
        ? 0.0
        : postAttendanceTotal / attendanceN;

    final attendanceChange =
        postAttendanceMean - preAttendanceMean;

    final preLateMean =
    lateN == 0
        ? 0.0
        : preLateTotal / lateN;

    final postLateMean =
    lateN == 0
        ? 0.0
        : postLateTotal / lateN;

    // Positive value means late arrivals decreased.
    final lateReduction =
        preLateMean - postLateMean;

    final preTransportMean =
    transportN == 0
        ? 0.0
        : preTransportTotal / transportN;

    final postTransportMean =
    transportN == 0
        ? 0.0
        : postTransportTotal / transportN;

    // Positive value means transport absences decreased.
    final transportReduction =
        preTransportMean - postTransportMean;

    return {
      // Keep old keys so the current dashboard
      // continues working.
      'pre': preAttendanceMean,
      'post': postAttendanceMean,
      'change': attendanceChange,

      // Extended research analytics.
      'participants': attendanceN,

      'preAttendanceMean':
      preAttendanceMean,
      'postAttendanceMean':
      postAttendanceMean,
      'attendanceChange':
      attendanceChange,

      'preLateMean':
      preLateMean,
      'postLateMean':
      postLateMean,
      'lateReduction':
      lateReduction,
      'lateParticipants':
      lateN,

      'preTransportMean':
      preTransportMean,
      'postTransportMean':
      postTransportMean,
      'transportReduction':
      transportReduction,
      'transportParticipants':
      transportN,
    };
  }

  // ===========================================================
  // TRAVEL PROBLEM ANALYTICS
  // ===========================================================

  Future<Map<String, dynamic>>
  travelProblemAnalytics() async {
    final q =
    await _db.collection('travelProblems').get();

    final counts = <String, int>{};

    for (final d in q.docs) {
      final data = d.data();

      dynamic rawProblem =
      data['problemType'];

      rawProblem ??= data['problem'];

      rawProblem ??= data['reason'];

      if (rawProblem == null) {
        continue;
      }

      final problem =
      rawProblem.toString().trim();

      if (problem.isEmpty) {
        continue;
      }

      counts[problem] =
          (counts[problem] ?? 0) + 1;
    }

    String mostCommonProblem = 'No data';
    int mostCommonCount = 0;

    counts.forEach((problem, count) {
      if (count > mostCommonCount) {
        mostCommonProblem = problem;
        mostCommonCount = count;
      }
    });

    // Sort categories by frequency.
    final sortedEntries =
    counts.entries.toList()
      ..sort(
            (a, b) =>
            b.value.compareTo(a.value),
      );

    final sortedCounts =
    <String, int>{};

    for (final entry in sortedEntries) {
      sortedCounts[entry.key] =
          entry.value;
    }

    return {
      'totalReports': q.docs.length,
      'mostCommonProblem':
      mostCommonProblem,
      'mostCommonCount':
      mostCommonCount,
      'problemCounts':
      sortedCounts,
    };
  }

  // ===========================================================
  // COMPLETE RESEARCH ANALYTICS
  // ===========================================================

  Future<Map<String, dynamic>>
  researchAnalytics() async {
    final general = await summary();
    final prePostData = await prePost();
    final problemData =
    await travelProblemAnalytics();

    return {
      ...general,
      ...prePostData,

      'mostCommonProblem':
      problemData['mostCommonProblem'],

      'mostCommonProblemCount':
      problemData['mostCommonCount'],

      'problemCounts':
      problemData['problemCounts'],
    };
  }

  // ===========================================================
  // SAFE NUMBER CONVERSION
  // ===========================================================

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }
}