import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class CsvExportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================
  // EXPORT ANONYMIZED RESEARCH DATA
  // ===========================================================

  Future<File> exportResearchData() async {
    final query = await _db
        .collection('researchData')
        .orderBy('participantCode')
        .get();

    final buffer = StringBuffer();

    // ---------------------------------------------------------
    // CSV HEADER
    // ---------------------------------------------------------

    buffer.writeln([
      'participantCode',

      // PRE
      'preWorkingDays',
      'preAttendedDays',
      'preAttendancePercentage',
      'preLateArrivals',
      'preTransportAbsences',

      // POST
      'postRecordedDays',
      'postAttendedDays',
      'postAttendancePercentage',
      'postLateArrivals',
      'postTransportAbsences',

      // CHANGE
      'attendanceChangePercentagePoints',
      'lateArrivalChange',
      'transportAbsenceChange',

      // DATA QUALITY / SOURCE
      'postDataSource',
    ].join(','));

    // ---------------------------------------------------------
    // CSV ESCAPE
    // ---------------------------------------------------------

    String escape(dynamic value) {
      if (value == null) {
        return '""';
      }

      final text = value.toString().replaceAll('"', '""');

      return '"$text"';
    }

    // ---------------------------------------------------------
    // FORMAT DECIMAL
    // ---------------------------------------------------------

    String decimal(dynamic value) {
      if (value == null) {
        return '';
      }

      if (value is num) {
        return value.toDouble().toStringAsFixed(2);
      }

      final parsed = double.tryParse(value.toString());

      if (parsed == null) {
        return '';
      }

      return parsed.toStringAsFixed(2);
    }

    // ---------------------------------------------------------
    // WRITE PARTICIPANT ROWS
    // ---------------------------------------------------------

    for (final doc in query.docs) {
      final data = doc.data();

      final row = [
        // Anonymous participant code only
        escape(
          data['participantCode'] ?? doc.id,
        ),

        // PRE
        escape(data['preWorkingDays'] ?? ''),
        escape(data['preAttendedDays'] ?? ''),
        escape(
          decimal(
            data['preAttendancePercentage'],
          ),
        ),
        escape(data['preLateArrivals'] ?? ''),
        escape(
          data['preTransportAbsences'] ?? '',
        ),

        // POST
        //
        // Firestore currently uses postWorkingDays.
        // In the exported research dataset we call it
        // postRecordedDays because these are app-recorded
        // attendance observation days.
        escape(data['postWorkingDays'] ?? ''),
        escape(data['postAttendedDays'] ?? ''),
        escape(
          decimal(
            data['postAttendancePercentage'],
          ),
        ),
        escape(data['postLateArrivals'] ?? ''),
        escape(
          data['postTransportAbsences'] ?? '',
        ),

        // CHANGE
        escape(
          decimal(
            data['attendanceChange'],
          ),
        ),
        escape(data['lateArrivalChange'] ?? ''),
        escape(
          data['transportAbsenceChange'] ?? '',
        ),

        // SOURCE
        escape(data['postDataSource'] ?? ''),
      ];

      buffer.writeln(row.join(','));
    }

    // ---------------------------------------------------------
    // SAVE FILE
    // ---------------------------------------------------------

    final directory =
    await getApplicationDocumentsDirectory();

    final file = File(
      '${directory.path}/sakhi_pravas_research.csv',
    );

    return file.writeAsString(
      buffer.toString(),
      flush: true,
    );
  }
}