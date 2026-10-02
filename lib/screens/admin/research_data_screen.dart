import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResearchDataScreen extends StatefulWidget {
  const ResearchDataScreen({super.key});

  @override
  State<ResearchDataScreen> createState() =>
      _ResearchDataScreenState();
}

class _ResearchDataScreenState extends State<ResearchDataScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================
  // BASIC UI HELPERS
  // ===========================================================

  InputDecoration fieldDecoration(
      String label, {
        String? hint,
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: const OutlineInputBorder(),
    );
  }

  Widget sectionTitle(
      String title,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================
  // LOAD REGISTERED STUDENTS
  // ===========================================================

  Future<List<Map<String, dynamic>>> _loadStudents() async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: 'student')
        .get();

    final students = query.docs.map((doc) {
      return <String, dynamic>{
        'uid': doc.id,
        ...doc.data(),
      };
    }).toList();

    students.sort((a, b) {
      final nameA =
      (a['fullName'] ?? '').toString().toLowerCase();
      final nameB =
      (b['fullName'] ?? '').toString().toLowerCase();

      return nameA.compareTo(nameB);
    });

    return students;
  }

  // ===========================================================
  // STUDENT DISPLAY NAME
  // ===========================================================

  String _studentLabel(Map<String, dynamic> student) {
    final name =
    (student['fullName'] ?? '').toString().trim();

    final className =
    (student['className'] ?? '').toString().trim();

    final village =
    (student['village'] ?? '').toString().trim();

    if (name.isEmpty) {
      return 'Registered Student';
    }

    final extras = <String>[];

    if (className.isNotEmpty) {
      extras.add(className);
    }

    if (village.isNotEmpty) {
      extras.add(village);
    }

    if (extras.isEmpty) {
      return name;
    }

    return '$name (${extras.join(' • ')})';
  }

  // ===========================================================
  // AUTOMATIC POST CALCULATION
  // ===========================================================

  Future<Map<String, dynamic>> _calculatePostData(
      String studentUid,
      ) async {
    // We intentionally query only by userId here and filter
    // pre/post locally. This avoids requiring a new composite
    // Firestore index for this feature.
    final query = await _db
        .collection('attendance')
        .where(
      'userId',
      isEqualTo: studentUid,
    )
        .get();

    final postRecords = query.docs.where((doc) {
      final data = doc.data();

      return data['preOrPostIntervention'] == 'post';
    }).toList();

    final recordedDays = postRecords.length;

    int attendedDays = 0;
    int lateArrivals = 0;
    int transportAbsences = 0;

    for (final doc in postRecords) {
      final data = doc.data();

      final status =
      (data['status'] ?? '').toString();

      if (status == 'Reached On Time' ||
          status == 'Reached Late') {
        attendedDays++;
      }

      if (status == 'Reached Late') {
        lateArrivals++;
      }

      if (status == 'Could Not Attend' &&
          data['transportRelated'] == true) {
        transportAbsences++;
      }
    }

    final attendancePercentage =
    recordedDays == 0
        ? 0.0
        : (attendedDays / recordedDays) * 100;

    return {
      'recordedDays': recordedDays,
      'attendedDays': attendedDays,
      'lateArrivals': lateArrivals,
      'transportAbsences': transportAbsences,
      'attendancePercentage':
      attendancePercentage,
    };
  }

  // ===========================================================
  // OPEN ADD / EDIT DIALOG
  // ===========================================================

  Future<void> _openEditor({
    String? documentId,
    Map<String, dynamic>? existing,
  }) async {
    List<Map<String, dynamic>> students;

    try {
      students = await _loadStudents();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load registered students: $e',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    String? selectedStudentUid =
    existing?['studentUid']?.toString();

    // If an old research record has no UID, it can now be linked.
    if (selectedStudentUid != null &&
        !students.any(
              (student) =>
          student['uid'] == selectedStudentUid,
        )) {
      selectedStudentUid = null;
    }

    final participantController =
    TextEditingController(
      text:
      existing?['participantCode']?.toString() ??
          '',
    );

    // PRE
    final preWorkingDaysController =
    TextEditingController(
      text:
      existing?['preWorkingDays']?.toString() ??
          '',
    );

    final preAttendedDaysController =
    TextEditingController(
      text:
      existing?['preAttendedDays']?.toString() ??
          '',
    );

    final preLateArrivalsController =
    TextEditingController(
      text:
      existing?['preLateArrivals']?.toString() ??
          '0',
    );

    final preTransportAbsencesController =
    TextEditingController(
      text: existing?['preTransportAbsences']
          ?.toString() ??
          '0',
    );

    // POST
    final postWorkingDaysController =
    TextEditingController(
      text:
      existing?['postWorkingDays']?.toString() ??
          '',
    );

    final postAttendedDaysController =
    TextEditingController(
      text:
      existing?['postAttendedDays']?.toString() ??
          '',
    );

    final postLateArrivalsController =
    TextEditingController(
      text:
      existing?['postLateArrivals']?.toString() ??
          '0',
    );

    final postTransportAbsencesController =
    TextEditingController(
      text: existing?['postTransportAbsences']
          ?.toString() ??
          '0',
    );

    bool calculatingPost = false;
    bool postCalculatedFromApp =
        existing?['postDataSource'] == 'app';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              dialogContext,
              setDialogState,
              ) {
            Future<void> calculatePost() async {
              if (selectedStudentUid == null ||
                  selectedStudentUid!.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Please select a registered student first.',
                    ),
                  ),
                );

                return;
              }

              setDialogState(() {
                calculatingPost = true;
              });

              try {
                final result =
                await _calculatePostData(
                  selectedStudentUid!,
                );

                if (!dialogContext.mounted) {
                  return;
                }

                final recordedDays =
                result['recordedDays'] as int;

                if (recordedDays == 0) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No POST attendance records were found for this student.',
                      ),
                    ),
                  );

                  return;
                }

                postWorkingDaysController.text =
                    recordedDays.toString();

                postAttendedDaysController.text =
                    result['attendedDays']
                        .toString();

                postLateArrivalsController.text =
                    result['lateArrivals']
                        .toString();

                postTransportAbsencesController.text =
                    result['transportAbsences']
                        .toString();

                setDialogState(() {
                  postCalculatedFromApp = true;
                });

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'POST data calculated from '
                          '$recordedDays recorded college day(s).',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      'Unable to calculate POST data: $e',
                    ),
                  ),
                );
              } finally {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    calculatingPost = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: Text(
                documentId == null
                    ? 'Add Research Participant'
                    : 'Edit Research Participant',
              ),
              content: SizedBox(
                width: 550,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                    MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // =====================================
                      // PARTICIPANT LINK
                      // =====================================

                      sectionTitle(
                        'PARTICIPANT LINK',
                        Icons.link,
                      ),

                      DropdownButtonFormField<String>(
                        value: selectedStudentUid,
                        isExpanded: true,
                        decoration: fieldDecoration(
                          'Registered Student',
                        ),
                        hint: const Text(
                          'Select student',
                        ),
                        items: students.map((student) {
                          final uid =
                          student['uid']
                              .toString();

                          return DropdownMenuItem<
                              String>(
                            value: uid,
                            child: Text(
                              _studentLabel(
                                student,
                              ),
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedStudentUid =
                                value;

                            // If the researcher changes
                            // the linked student, old automatic
                            // POST values should no longer be
                            // considered current app-derived data.
                            postCalculatedFromApp =
                            false;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        participantController,
                        textCapitalization:
                        TextCapitalization
                            .characters,
                        decoration:
                        fieldDecoration(
                          'Participant Code',
                          hint: 'Example: SP001',
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'The participant code is used for research analysis and anonymized export. The student account link is stored internally.',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Divider(),

                      // =====================================
                      // PRE DATA
                      // =====================================

                      sectionTitle(
                        'PRE-INTERVENTION DATA',
                        Icons.history,
                      ),

                      const Text(
                        'Enter baseline data manually.',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        preWorkingDaysController,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        fieldDecoration(
                          'College Working Days',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        preAttendedDaysController,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        fieldDecoration(
                          'Days Attended',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        preLateArrivalsController,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        fieldDecoration(
                          'Late Arrivals',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        preTransportAbsencesController,
                        keyboardType:
                        TextInputType.number,
                        decoration:
                        fieldDecoration(
                          'Transport-Related Absences',
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Divider(),

                      // =====================================
                      // POST DATA
                      // =====================================

                      sectionTitle(
                        'POST-INTERVENTION DATA',
                        Icons.auto_graph,
                      ),

                      const Text(
                        'Recommended: calculate POST data from the student\'s recorded app attendance. Manual editing remains available during pilot testing.',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child:
                        FilledButton.icon(
                          onPressed:
                          calculatingPost
                              ? null
                              : calculatePost,
                          icon: calculatingPost
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons
                                .sync_outlined,
                          ),
                          label: Text(
                            calculatingPost
                                ? 'Calculating...'
                                : 'Update POST from App Records',
                          ),
                        ),
                      ),

                      if (postCalculatedFromApp)
                        Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .check_circle_outline,
                                size: 18,
                              ),
                              const SizedBox(
                                  width: 6),
                              Expanded(
                                child: Text(
                                  'POST values currently reflect recorded app attendance.',
                                  style:
                                  Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 14),

                      TextField(
                        controller:
                        postWorkingDaysController,
                        keyboardType:
                        TextInputType.number,
                        onChanged: (_) {
                          postCalculatedFromApp =
                          false;
                        },
                        decoration:
                        fieldDecoration(
                          'Recorded College Days',
                          hint:
                          'Automatically calculated from app attendance',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        postAttendedDaysController,
                        keyboardType:
                        TextInputType.number,
                        onChanged: (_) {
                          postCalculatedFromApp =
                          false;
                        },
                        decoration:
                        fieldDecoration(
                          'Days Attended',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        postLateArrivalsController,
                        keyboardType:
                        TextInputType.number,
                        onChanged: (_) {
                          postCalculatedFromApp =
                          false;
                        },
                        decoration:
                        fieldDecoration(
                          'Late Arrivals',
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextField(
                        controller:
                        postTransportAbsencesController,
                        keyboardType:
                        TextInputType.number,
                        onChanged: (_) {
                          postCalculatedFromApp =
                          false;
                        },
                        decoration:
                        fieldDecoration(
                          'Transport-Related Absences',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ===========================================
              // SAVE
              // ===========================================

              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                        dialogContext,
                      ),
                  child:
                  const Text('Cancel'),
                ),

                FilledButton.icon(
                  icon: const Icon(
                    Icons.save_outlined,
                  ),
                  label:
                  const Text('Save'),
                  onPressed: () async {
                    final participant =
                    participantController
                        .text
                        .trim()
                        .toUpperCase();

                    final studentUid =
                        selectedStudentUid;

                    final preWorking =
                    int.tryParse(
                      preWorkingDaysController
                          .text
                          .trim(),
                    );

                    final preAttended =
                    int.tryParse(
                      preAttendedDaysController
                          .text
                          .trim(),
                    );

                    final preLate =
                    int.tryParse(
                      preLateArrivalsController
                          .text
                          .trim(),
                    );

                    final preTransport =
                    int.tryParse(
                      preTransportAbsencesController
                          .text
                          .trim(),
                    );

                    final postWorking =
                    int.tryParse(
                      postWorkingDaysController
                          .text
                          .trim(),
                    );

                    final postAttended =
                    int.tryParse(
                      postAttendedDaysController
                          .text
                          .trim(),
                    );

                    final postLate =
                    int.tryParse(
                      postLateArrivalsController
                          .text
                          .trim(),
                    );

                    final postTransport =
                    int.tryParse(
                      postTransportAbsencesController
                          .text
                          .trim(),
                    );

                    // =====================================
                    // REQUIRED FIELDS
                    // =====================================

                    if (studentUid == null ||
                        studentUid.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select a registered student.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (participant.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a participant code.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (preWorking == null ||
                        preAttended == null ||
                        preLate == null ||
                        preTransport == null ||
                        postWorking == null ||
                        postAttended == null ||
                        postLate == null ||
                        postTransport == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter all PRE and POST values correctly.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =====================================
                    // VALIDATION
                    // =====================================

                    if (preWorking <= 0 ||
                        postWorking <= 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PRE working days and POST recorded days must be greater than zero.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (preAttended < 0 ||
                        postAttended < 0 ||
                        preAttended >
                            preWorking ||
                        postAttended >
                            postWorking) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Attended days cannot exceed the corresponding total days.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (preLate < 0 ||
                        postLate < 0 ||
                        preTransport < 0 ||
                        postTransport < 0) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Late arrivals and transport absences cannot be negative.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (preLate >
                        preAttended ||
                        postLate >
                            postAttended) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Late arrivals cannot exceed days attended.',
                          ),
                        ),
                      );

                      return;
                    }

                    final preAbsent =
                        preWorking -
                            preAttended;

                    final postAbsent =
                        postWorking -
                            postAttended;

                    if (preTransport >
                        preAbsent ||
                        postTransport >
                            postAbsent) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Transport-related absences cannot exceed total absences.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =====================================
                    // DUPLICATE PARTICIPANT CODE CHECK
                    // =====================================

                    final duplicateCode =
                    await _db
                        .collection(
                      'researchData',
                    )
                        .where(
                      'participantCode',
                      isEqualTo:
                      participant,
                    )
                        .get();

                    final duplicateCodeExists =
                    duplicateCode.docs.any(
                          (doc) =>
                      doc.id !=
                          documentId,
                    );

                    if (duplicateCodeExists) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This participant code already exists.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =====================================
                    // PREVENT SAME STUDENT LINKING TWICE
                    // =====================================

                    final duplicateStudent =
                    await _db
                        .collection(
                      'researchData',
                    )
                        .where(
                      'studentUid',
                      isEqualTo:
                      studentUid,
                    )
                        .get();

                    final duplicateStudentExists =
                    duplicateStudent.docs.any(
                          (doc) =>
                      doc.id !=
                          documentId,
                    );

                    if (duplicateStudentExists) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This student is already linked to another participant code.',
                          ),
                        ),
                      );

                      return;
                    }

                    // =====================================
                    // CALCULATIONS
                    // =====================================

                    final prePercentage =
                        (preAttended /
                            preWorking) *
                            100;

                    final postPercentage =
                        (postAttended /
                            postWorking) *
                            100;

                    final attendanceChange =
                        postPercentage -
                            prePercentage;

                    final lateArrivalChange =
                        postLate -
                            preLate;

                    final transportAbsenceChange =
                        postTransport -
                            preTransport;

                    final data =
                    <String, dynamic>{
                      // PARTICIPANT LINK
                      'participantCode':
                      participant,

                      // Internal research link.
                      // Do not include this in
                      // anonymized CSV exports.
                      'studentUid':
                      studentUid,

                      // PRE
                      'preWorkingDays':
                      preWorking,
                      'preAttendedDays':
                      preAttended,
                      'preAttendancePercentage':
                      prePercentage,
                      'preLateArrivals':
                      preLate,
                      'preTransportAbsences':
                      preTransport,

                      // POST
                      //
                      // Existing field name is
                      // preserved for compatibility
                      // with the dashboard and CSV.
                      'postWorkingDays':
                      postWorking,
                      'postAttendedDays':
                      postAttended,
                      'postAttendancePercentage':
                      postPercentage,
                      'postLateArrivals':
                      postLate,
                      'postTransportAbsences':
                      postTransport,

                      // DATA SOURCE
                      'postDataSource':
                      postCalculatedFromApp
                          ? 'app'
                          : 'manual',

                      // CHANGES
                      'attendanceChange':
                      attendanceChange,
                      'lateArrivalChange':
                      lateArrivalChange,
                      'transportAbsenceChange':
                      transportAbsenceChange,

                      'updatedAt':
                      FieldValue
                          .serverTimestamp(),
                    };

                    // =====================================
                    // SAVE
                    // =====================================

                    try {
                      if (documentId ==
                          null) {
                        data['createdAt'] =
                            FieldValue
                                .serverTimestamp();

                        await _db
                            .collection(
                          'researchData',
                        )
                            .add(data);
                      } else {
                        await _db
                            .collection(
                          'researchData',
                        )
                            .doc(
                          documentId,
                        )
                            .update(data);
                      }

                      if (dialogContext
                          .mounted) {
                        Navigator.pop(
                          dialogContext,
                        );
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Research data saved successfully.',
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Unable to save research data: $e',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    participantController.dispose();

    preWorkingDaysController.dispose();
    preAttendedDaysController.dispose();
    preLateArrivalsController.dispose();
    preTransportAbsencesController.dispose();

    postWorkingDaysController.dispose();
    postAttendedDaysController.dispose();
    postLateArrivalsController.dispose();
    postTransportAbsencesController.dispose();
  }

  // ===========================================================
  // QUICK UPDATE POST DATA
  // ===========================================================

  Future<void> _quickUpdatePost(
      String documentId,
      Map<String, dynamic> existing,
      ) async {
    final studentUid =
    existing['studentUid']?.toString();

    if (studentUid == null ||
        studentUid.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This participant is not linked to a student account. Tap the participant and select a registered student first.',
          ),
        ),
      );

      return;
    }

    try {
      final result =
      await _calculatePostData(
        studentUid,
      );

      final recordedDays =
      result['recordedDays'] as int;

      final attendedDays =
      result['attendedDays'] as int;

      final lateArrivals =
      result['lateArrivals'] as int;

      final transportAbsences =
      result['transportAbsences'] as int;

      if (recordedDays == 0) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'No POST attendance records were found for this participant.',
            ),
          ),
        );

        return;
      }

      final postPercentage =
          (attendedDays / recordedDays) *
              100;

      final prePercentage =
          (existing[
          'preAttendancePercentage']
          as num?)
              ?.toDouble() ??
              0.0;

      final preLate =
          (existing['preLateArrivals']
          as num?)
              ?.toInt() ??
              0;

      final preTransport =
          (existing[
          'preTransportAbsences']
          as num?)
              ?.toInt() ??
              0;

      await _db
          .collection('researchData')
          .doc(documentId)
          .update({
        'postWorkingDays':
        recordedDays,
        'postAttendedDays':
        attendedDays,
        'postAttendancePercentage':
        postPercentage,
        'postLateArrivals':
        lateArrivals,
        'postTransportAbsences':
        transportAbsences,

        'attendanceChange':
        postPercentage -
            prePercentage,

        'lateArrivalChange':
        lateArrivals -
            preLate,

        'transportAbsenceChange':
        transportAbsences -
            preTransport,

        'postDataSource': 'app',
        'postUpdatedAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'POST data updated from $recordedDays recorded college day(s).',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update POST data: $e',
          ),
        ),
      );
    }
  }

  // ===========================================================
  // DELETE
  // ===========================================================

  Future<void> _delete(
      String id,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Research Data?',
          ),
          content: const Text(
            'This will permanently delete this participant\'s pre/post research record.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    false,
                  ),
              child:
              const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                    true,
                  ),
              child:
              const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _db
          .collection('researchData')
          .doc(id)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Research record deleted.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'Unable to delete record: $e',
            ),
          ),
        );
      }
    }
  }

  // ===========================================================
  // DISPLAY HELPERS
  // ===========================================================

  String percentage(dynamic value) {
    if (value is num) {
      return '${value.toDouble().toStringAsFixed(1)}%';
    }

    return '0.0%';
  }

  String changeText(dynamic value) {
    final n =
        (value as num?)?.toDouble() ??
            0;

    return '${n >= 0 ? '+' : ''}'
        '${n.toStringAsFixed(1)} pp';
  }

  String numberChange(dynamic value) {
    final n =
        (value as num?)?.toInt() ??
            0;

    return '${n > 0 ? '+' : ''}$n';
  }

  // ===========================================================
  // BUILD
  // ===========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pre/Post Research Data',
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () =>
            _openEditor(),
        icon: const Icon(
          Icons.person_add_outlined,
        ),
        label: const Text(
          'Add Participant',
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: _db
            .collection('researchData')
            .orderBy('participantCode')
            .snapshots(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),
                child: Text(
                  'Unable to load research data.\n\n'
                      '${snapshot.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                EdgeInsets.all(24),
                child: Text(
                  'No pre/post research data yet.\n\n'
                      'Tap "Add Participant" to link a registered student and enter baseline data.',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding:
            const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              100,
            ),
            itemCount:
            docs.length,
            itemBuilder: (
                context,
                index,
                ) {
              final doc =
              docs[index];

              final data =
              doc.data();

              final participant =
                  data['participantCode']
                      ?.toString() ??
                      'Participant';

              final linked =
                  data['studentUid'] !=
                      null &&
                      data['studentUid']
                          .toString()
                          .isNotEmpty;

              final postSource =
                  data['postDataSource']
                      ?.toString() ??
                      'manual';

              final pre =
              percentage(
                data[
                'preAttendancePercentage'],
              );

              final post =
              percentage(
                data[
                'postAttendancePercentage'],
              );

              final attendanceChange =
              changeText(
                data[
                'attendanceChange'],
              );

              final preLate =
                  data[
                  'preLateArrivals'] ??
                      0;

              final postLate =
                  data[
                  'postLateArrivals'] ??
                      0;

              final lateChange =
              numberChange(
                data[
                'lateArrivalChange'],
              );

              final preTransport =
                  data[
                  'preTransportAbsences'] ??
                      0;

              final postTransport =
                  data[
                  'postTransportAbsences'] ??
                      0;

              final transportChange =
              numberChange(
                data[
                'transportAbsenceChange'],
              );

              final postRecordedDays =
                  data[
                  'postWorkingDays'] ??
                      0;

              return Card(
                margin:
                const EdgeInsets.only(
                  bottom: 12,
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(
                    6,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading:
                        CircleAvatar(
                          child: Text(
                            participant
                                .isNotEmpty
                                ? participant[
                            participant
                                .length -
                                1]
                                : 'P',
                          ),
                        ),

                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                participant,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                  fontSize:
                                  16,
                                ),
                              ),
                            ),

                            if (linked)
                              const Tooltip(
                                message:
                                'Linked to student account',
                                child: Icon(
                                  Icons
                                      .link,
                                  size: 19,
                                ),
                              )
                            else
                              const Tooltip(
                                message:
                                'Student account not linked',
                                child: Icon(
                                  Icons
                                      .link_off,
                                  size: 19,
                                ),
                              ),
                          ],
                        ),

                        subtitle: Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 8,
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                'Attendance: '
                                    '$pre → $post '
                                    '($attendanceChange)',
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Late arrivals: '
                                    '$preLate → '
                                    '$postLate '
                                    '($lateChange)',
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'Transport absences: '
                                    '$preTransport → '
                                    '$postTransport '
                                    '($transportChange)',
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                'POST recorded days: '
                                    '$postRecordedDays',
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                postSource ==
                                    'app'
                                    ? 'POST source: App attendance records'
                                    : 'POST source: Manual entry',
                                style:
                                const TextStyle(
                                  fontSize:
                                  11,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        onTap: () =>
                            _openEditor(
                              documentId:
                              doc.id,
                              existing:
                              data,
                            ),

                        trailing:
                        IconButton(
                          tooltip:
                          'Delete',
                          icon:
                          const Icon(
                            Icons
                                .delete_outline,
                          ),
                          onPressed: () =>
                              _delete(
                                doc.id,
                              ),
                        ),
                      ),

                      if (linked)
                        Padding(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                            12,
                            0,
                            12,
                            8,
                          ),
                          child: SizedBox(
                            width:
                            double.infinity,
                            child:
                            OutlinedButton
                                .icon(
                              onPressed: () =>
                                  _quickUpdatePost(
                                    doc.id,
                                    data,
                                  ),
                              icon:
                              const Icon(
                                Icons
                                    .sync_outlined,
                              ),
                              label:
                              const Text(
                                'Update POST from App Records',
                              ),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding:
                          const EdgeInsets
                              .fromLTRB(
                            12,
                            0,
                            12,
                            8,
                          ),
                          child: SizedBox(
                            width:
                            double.infinity,
                            child:
                            OutlinedButton
                                .icon(
                              onPressed: () =>
                                  _openEditor(
                                    documentId:
                                    doc.id,
                                    existing:
                                    data,
                                  ),
                              icon:
                              const Icon(
                                Icons
                                    .link_outlined,
                              ),
                              label:
                              const Text(
                                'Link Registered Student',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}