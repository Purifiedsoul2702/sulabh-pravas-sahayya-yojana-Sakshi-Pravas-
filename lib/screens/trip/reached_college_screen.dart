import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/trip_service.dart';

class ReachedCollegeScreen extends StatefulWidget {
  const ReachedCollegeScreen({
    super.key,
    required this.data,
  });

  final Map<String, String> data;

  @override
  State<ReachedCollegeScreen> createState() =>
      _ReachedCollegeScreenState();
}

class _ReachedCollegeScreenState
    extends State<ReachedCollegeScreen> {
  String outcome = 'Reached On Time';
  String reason = '';

  bool? transportRelated;

  bool saving = false;

  final List<String> reasons = [
    'Bus Delay',
    'Missed Bus',
    'Bus Cancelled',
    'Traffic',
    'Long Waiting Time',
    'Safety Problem',
    'Other',
  ];

  // ===========================================================
  // OUTCOME CHANGE
  // ===========================================================

  void changeOutcome(String value) {
    setState(() {
      outcome = value;

      // On-time arrival requires no reason.
      if (outcome == 'Reached On Time') {
        reason = '';
        transportRelated = false;
      }

      // Late arrival is still recorded with a reason,
      // but it is not an absence.
      if (outcome == 'Reached Late') {
        transportRelated = false;
      }

      // For an absence, the student/research record must
      // explicitly state whether it was transport-related.
      if (outcome == 'Could Not Attend') {
        transportRelated = null;
      }
    });
  }

  // ===========================================================
  // SUBMIT
  // ===========================================================

  Future<void> submit() async {
    if (saving) return;

    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login before saving the journey outcome.',
          ),
        ),
      );
      return;
    }

    // ---------------------------------------------------------
    // REASON VALIDATION
    // ---------------------------------------------------------

    if (outcome != 'Reached On Time' &&
        reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a reason.',
          ),
        ),
      );
      return;
    }

    // ---------------------------------------------------------
    // TRANSPORT-RELATED VALIDATION
    // ---------------------------------------------------------

    if (outcome == 'Could Not Attend' &&
        transportRelated == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please specify whether the absence was transport/travel-related.',
          ),
        ),
      );
      return;
    }

    final tripId =
        widget.data['tripId'] ?? '';

    if (tripId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trip information is missing. Unable to save attendance.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await TripService().completeTrip(
        tripId: tripId,
        userId: uid,
        outcome: outcome,
        reason:
        outcome == 'Reached On Time'
            ? ''
            : reason,

        // Explicit classification.
        transportRelated:
        outcome == 'Could Not Attend'
            ? (transportRelated ?? false)
            : false,
      );

      if (!mounted) return;

      context.go('/attendance');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save journey outcome: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reached College',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ===================================================
          // INTRODUCTION
          // ===================================================

          const Text(
            'Journey Outcome',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Please record what happened during this college journey.',
          ),

          const SizedBox(height: 16),

          // ===================================================
          // OUTCOME
          // ===================================================

          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'Reached On Time',
                  groupValue: outcome,
                  title: const Text(
                    'Reached On Time',
                  ),
                  subtitle: const Text(
                    'I reached college on time.',
                  ),
                  onChanged: saving
                      ? null
                      : (value) {
                    if (value != null) {
                      changeOutcome(value);
                    }
                  },
                ),

                const Divider(height: 1),

                RadioListTile<String>(
                  value: 'Reached Late',
                  groupValue: outcome,
                  title: const Text(
                    'Reached Late',
                  ),
                  subtitle: const Text(
                    'I attended college but arrived late.',
                  ),
                  onChanged: saving
                      ? null
                      : (value) {
                    if (value != null) {
                      changeOutcome(value);
                    }
                  },
                ),

                const Divider(height: 1),

                RadioListTile<String>(
                  value: 'Could Not Attend',
                  groupValue: outcome,
                  title: const Text(
                    'Could Not Attend',
                  ),
                  subtitle: const Text(
                    'I could not attend college today.',
                  ),
                  onChanged: saving
                      ? null
                      : (value) {
                    if (value != null) {
                      changeOutcome(value);
                    }
                  },
                ),
              ],
            ),
          ),

          // ===================================================
          // REASON
          // ===================================================

          if (outcome != 'Reached On Time') ...[
            const SizedBox(height: 18),

            const Text(
              'Reason',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value:
              reason.isEmpty ? null : reason,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select Reason',
                border: OutlineInputBorder(),
              ),
              items: reasons.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                setState(() {
                  reason = value ?? '';
                });
              },
            ),
          ],

          // ===================================================
          // EXPLICIT TRANSPORT CLASSIFICATION
          // ===================================================

          if (outcome == 'Could Not Attend') ...[
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons
                              .directions_bus_outlined,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Was this absence caused by a transport/travel problem?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'This information is used to calculate transport-related absences in the research data.',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 8),

                    RadioListTile<bool>(
                      contentPadding:
                      EdgeInsets.zero,
                      value: true,
                      groupValue:
                      transportRelated,
                      title:
                      const Text('Yes'),
                      subtitle: const Text(
                        'Transport or travel difficulty caused the absence.',
                      ),
                      onChanged: saving
                          ? null
                          : (value) {
                        setState(() {
                          transportRelated =
                              value;
                        });
                      },
                    ),

                    RadioListTile<bool>(
                      contentPadding:
                      EdgeInsets.zero,
                      value: false,
                      groupValue:
                      transportRelated,
                      title:
                      const Text('No'),
                      subtitle: const Text(
                        'The absence was caused by another reason.',
                      ),
                      onChanged: saving
                          ? null
                          : (value) {
                        setState(() {
                          transportRelated =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 22),

          // ===================================================
          // SAVE
          // ===================================================

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
              saving ? null : submit,
              icon: saving
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.save_outlined,
              ),
              label: Text(
                saving
                    ? 'Saving...'
                    : 'Save Journey Outcome',
              ),
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Please record the outcome accurately. This information contributes to attendance and travel research statistics.',
            style: TextStyle(
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}