import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  // ===========================================================
  // SMALL STAT CARD
  // ===========================================================

  Widget _statCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style:
                      Theme.of(context)
                          .textTheme
                          .bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================
  // PERCENTAGE
  // ===========================================================

  int _percentage(
      int value,
      int total,
      ) {
    if (total <= 0) return 0;

    return ((value / total) * 100).round();
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
        ),
      ),

      body: uid == null
          ? const Center(
        child: Text(
          'Please login.',
        ),
      )
          : StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .where(
          'userId',
          isEqualTo: uid,
        )
            .snapshots(),

        builder: (
            context,
            snapshot,
            ) {
          // =============================================
          // ERROR
          // =============================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load attendance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      snapshot.error.toString(),
                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // =============================================
          // LOADING
          // =============================================

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final allDocs =
              snapshot.data!.docs;

          // =============================================
          // USE POST RECORDS
          //
          // New journey attendance records are explicitly
          // marked as "post".
          //
          // For backward compatibility, records without
          // this field are still included in the overall
          // attendance section below.
          // =============================================

          final postDocs =
          allDocs.where((doc) {
            return doc.data()[
            'preOrPostIntervention'] ==
                'post';
          }).toList();

          // =============================================
          // OVERALL ATTENDANCE
          // =============================================

          final total =
              allDocs.length;

          final present =
              allDocs.where((doc) {
                final status =
                doc.data()['status'];

                return status ==
                    'Reached On Time' ||
                    status ==
                        'Reached Late';
              }).length;

          final onTime =
              allDocs.where((doc) {
                return doc.data()['status'] ==
                    'Reached On Time';
              }).length;

          final late =
              allDocs.where((doc) {
                return doc.data()['status'] ==
                    'Reached Late';
              }).length;

          final absent =
              allDocs.where((doc) {
                return doc.data()['status'] ==
                    'Could Not Attend';
              }).length;

          final transportAbsences =
              allDocs.where((doc) {
                final data = doc.data();

                return data['status'] ==
                    'Could Not Attend' &&
                    data['transportRelated'] ==
                        true;
              }).length;

          final attendancePercentage =
          _percentage(
            present,
            total,
          );

          final onTimePercentage =
          _percentage(
            onTime,
            present,
          );

          // =============================================
          // POST RESEARCH PERIOD
          // =============================================

          final postTotal =
              postDocs.length;

          final postPresent =
              postDocs.where((doc) {
                final status =
                doc.data()['status'];

                return status ==
                    'Reached On Time' ||
                    status ==
                        'Reached Late';
              }).length;

          final postOnTime =
              postDocs.where((doc) {
                return doc.data()['status'] ==
                    'Reached On Time';
              }).length;

          final postLate =
              postDocs.where((doc) {
                return doc.data()['status'] ==
                    'Reached Late';
              }).length;

          final postAbsent =
              postDocs.where((doc) {
                return doc.data()['status'] ==
                    'Could Not Attend';
              }).length;

          final postTransportAbsences =
              postDocs.where((doc) {
                final data = doc.data();

                return data['status'] ==
                    'Could Not Attend' &&
                    data['transportRelated'] ==
                        true;
              }).length;

          final postAttendancePercentage =
          _percentage(
            postPresent,
            postTotal,
          );

          // =============================================
          // EMPTY STATE
          // =============================================

          if (allDocs.isEmpty) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons
                          .calendar_month_outlined,
                      size: 70,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'No Attendance Records Yet',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your attendance information will appear here after you complete a college journey.',
                      textAlign:
                      TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // =============================================
          // MAIN SCREEN
          // =============================================

          return ListView(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              30,
            ),
            children: [
              // =========================================
              // ATTENDANCE PERCENTAGE
              // =========================================

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    22,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Recorded Attendance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      SizedBox(
                        width: 145,
                        height: 145,
                        child: Stack(
                          alignment:
                          Alignment.center,
                          children: [
                            SizedBox(
                              width: 135,
                              height: 135,
                              child:
                              CircularProgressIndicator(
                                value:
                                attendancePercentage /
                                    100,
                                strokeWidth:
                                11,
                                backgroundColor:
                                Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                            ),

                            Column(
                              mainAxisSize:
                              MainAxisSize
                                  .min,
                              children: [
                                Text(
                                  '$attendancePercentage%',
                                  style:
                                  const TextStyle(
                                    fontSize:
                                    32,
                                    fontWeight:
                                    FontWeight
                                        .w900,
                                  ),
                                ),
                                const Text(
                                  'Attendance',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Text(
                        '$present attended out of $total recorded college day(s)',
                        textAlign:
                        TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // =========================================
              // BASIC ATTENDANCE STATISTICS
              // =========================================

              const Padding(
                padding:
                EdgeInsets.fromLTRB(
                  4,
                  8,
                  4,
                  8,
                ),
                child: Text(
                  'Attendance Overview',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              _statCard(
                context: context,
                title:
                'Recorded College Days',
                value: '$total',
                icon:
                Icons.calendar_today_outlined,
                subtitle:
                'Days recorded through the app',
              ),

              _statCard(
                context: context,
                title: 'Present',
                value: '$present',
                icon:
                Icons.check_circle_outline,
                subtitle:
                'On-time and late arrivals',
              ),

              _statCard(
                context: context,
                title: 'Reached On Time',
                value: '$onTime',
                icon:
                Icons.schedule_outlined,
                subtitle:
                '$onTimePercentage% of attended days',
              ),

              _statCard(
                context: context,
                title: 'Late Arrivals',
                value: '$late',
                icon:
                Icons.access_time_outlined,
                subtitle:
                'Attended college but arrived late',
              ),

              _statCard(
                context: context,
                title: 'Could Not Attend',
                value: '$absent',
                icon:
                Icons.event_busy_outlined,
                subtitle:
                'Recorded college absences',
              ),

              const SizedBox(height: 16),

              // =========================================
              // TRANSPORT IMPACT
              // =========================================

              const Padding(
                padding:
                EdgeInsets.fromLTRB(
                  4,
                  8,
                  4,
                  8,
                ),
                child: Text(
                  'Travel Impact',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            child: Icon(
                              Icons
                                  .directions_bus_outlined,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          const Expanded(
                            child: Text(
                              'Transport-Related Absences',
                              style:
                              TextStyle(
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),
                          Text(
                            '$transportAbsences',
                            style:
                            const TextStyle(
                              fontSize: 24,
                              fontWeight:
                              FontWeight
                                  .w900,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        transportAbsences == 0
                            ? 'No transport-related absence has been recorded.'
                            : '$transportAbsences of your $absent recorded absence(s) were marked as transport/travel-related.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =========================================
              // CURRENT POST OBSERVATION
              // =========================================

              const Padding(
                padding:
                EdgeInsets.fromLTRB(
                  4,
                  8,
                  4,
                  8,
                ),
                child: Text(
                  'Current Study Period',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                    FontWeight.w900,
                  ),
                ),
              ),

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons
                                .insights_outlined,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'App-Recorded Journey Summary',
                              style:
                              TextStyle(
                                fontSize:
                                17,
                                fontWeight:
                                FontWeight
                                    .w900,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _summaryRow(
                        'Recorded days',
                        '$postTotal',
                      ),

                      _summaryRow(
                        'Attended',
                        '$postPresent',
                      ),

                      _summaryRow(
                        'Reached on time',
                        '$postOnTime',
                      ),

                      _summaryRow(
                        'Reached late',
                        '$postLate',
                      ),

                      _summaryRow(
                        'Could not attend',
                        '$postAbsent',
                      ),

                      _summaryRow(
                        'Transport-related absences',
                        '$postTransportAbsences',
                      ),

                      const Divider(
                        height: 24,
                      ),

                      _summaryRow(
                        'Attendance rate',
                        '$postAttendancePercentage%',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // =========================================
              // PRIVACY / RESEARCH NOTE
              // =========================================

              Card(
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      const Icon(
                        Icons
                            .privacy_tip_outlined,
                        size: 22,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Text(
                          'This screen shows attendance recorded through your app journeys. Research participant codes and researcher-only baseline data are not displayed here.',
                          style:
                          Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================
  // SUMMARY ROW
  // ===========================================================

  static Widget _summaryRow(
      String label,
      String value, {
        bool bold = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: bold
                    ? FontWeight.w800
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.w900
                  : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}