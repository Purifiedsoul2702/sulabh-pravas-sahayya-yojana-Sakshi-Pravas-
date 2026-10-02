import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class AdminCollectionScreen extends StatelessWidget {
  const AdminCollectionScreen({
    super.key,
    required this.collection,
    required this.title,
    this.filterType,
  });

  final String collection;
  final String title;

  /// Optional special filter for read-only research records.
  ///
  /// Supported values:
  /// lateArrivals
  /// transportAbsences
  final String? filterType;

  bool get isManageableCollection {
    return [
      'busStops',
      'routes',
      'buses',
      'busSchedules',
    ].contains(collection);
  }

  Map<String, TextEditingController> controllersFor(
      Map<String, dynamic>? current,
      ) {
    final c = <String, TextEditingController>{};

    List<String> fields;

    switch (collection) {
      case 'busStops':
        fields = [
          'stopName',
          'village',
          'latitude',
          'longitude',
        ];
        break;

      case 'routes':
        fields = [
          'routeName',
          'sourceStopId',
          'destinationStopId',
          'estimatedDurationMinutes',
        ];
        break;

      case 'buses':
        fields = [
          'busName',
          'busNumber',
          'routeId',
          'operator',
        ];
        break;

      case 'busSchedules':
        fields = [
          'busId',
          'routeId',
          'departureTime',
          'expectedArrivalTime',
        ];
        break;

      default:
        fields = [];
    }

    for (final f in fields) {
      c[f] = TextEditingController(
        text: '${current?[f] ?? ''}',
      );
    }

    return c;
  }

  Map<String, dynamic> normalize(
      Map<String, TextEditingController> c,
      ) {
    final m = <String, dynamic>{
      'active': true,
    };

    c.forEach((k, v) {
      final text = v.text.trim();

      if (['latitude', 'longitude'].contains(k)) {
        m[k] = double.tryParse(text) ?? 0;
      } else if (k == 'estimatedDurationMinutes') {
        m[k] = int.tryParse(text) ?? 0;
      } else {
        m[k] = text;
      }
    });

    if (collection == 'routes') {
      m['stopIds'] = <String>[];
    }

    if (collection == 'busSchedules') {
      m['daysOfWeek'] = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ];
    }

    return m;
  }

  // ============================================================
  // ADD / EDIT
  // ============================================================

  Future<void> editor(
      BuildContext context,
      AdminService service, {
        String? id,
        Map<String, dynamic>? current,
      }) async {
    final c = controllersFor(current);

    List<QueryDocumentSnapshot<Map<String, dynamic>>> routes = [];
    List<QueryDocumentSnapshot<Map<String, dynamic>>> buses = [];

    // ----------------------------------------------------------
    // LOAD ROUTES
    // ----------------------------------------------------------

    if (collection == 'buses' ||
        collection == 'busSchedules') {
      try {
        final routeSnapshot =
        await FirebaseFirestore.instance
            .collection('routes')
            .get();

        routes = routeSnapshot.docs;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unable to load routes: $e',
              ),
            ),
          );
        }

        return;
      }
    }

    // ----------------------------------------------------------
    // LOAD BUSES
    // ----------------------------------------------------------

    if (collection == 'busSchedules') {
      try {
        final busSnapshot =
        await FirebaseFirestore.instance
            .collection('buses')
            .get();

        buses = busSnapshot.docs;
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Unable to load buses: $e',
              ),
            ),
          );
        }

        return;
      }
    }

    if (!context.mounted) return;

    // ----------------------------------------------------------
    // CURRENT SELECTIONS
    // ----------------------------------------------------------

    String? selectedRouteId;
    String? selectedBusId;

    if (collection == 'buses' ||
        collection == 'busSchedules') {
      final existingRouteId =
      current?['routeId']?.toString().trim();

      if (existingRouteId != null &&
          existingRouteId.isNotEmpty &&
          routes.any(
                (route) => route.id == existingRouteId,
          )) {
        selectedRouteId = existingRouteId;
      }
    }

    if (collection == 'busSchedules') {
      final existingBusId =
      current?['busId']?.toString().trim();

      if (existingBusId != null &&
          existingBusId.isNotEmpty &&
          buses.any(
                (bus) => bus.id == existingBusId,
          )) {
        selectedBusId = existingBusId;
      }
    }

    // ----------------------------------------------------------
    // SHOW DIALOG
    // ----------------------------------------------------------

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              BuildContext dialogStateContext,
              StateSetter setState,
              ) {
            return AlertDialog(
              title: Text(
                id == null
                    ? 'Add $title'
                    : 'Edit $title',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: c.entries.map((e) {
                    // ==================================================
                    // BUS DROPDOWN FOR BUS SCHEDULE
                    // ==================================================

                    if (collection == 'busSchedules' &&
                        e.key == 'busId') {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                        DropdownButtonFormField<String>(
                          value: selectedBusId,
                          isExpanded: true,
                          decoration:
                          const InputDecoration(
                            labelText: 'Bus',
                            border:
                            OutlineInputBorder(),
                          ),
                          hint:
                          const Text('Select Bus'),

                          items: buses.map((busDoc) {
                            final data =
                            busDoc.data();

                            final busName =
                                data['busName']
                                    ?.toString()
                                    .trim() ??
                                    '';

                            final busNumber =
                                data['busNumber']
                                    ?.toString()
                                    .trim() ??
                                    '';

                            String label;

                            if (busName.isNotEmpty &&
                                busNumber.isNotEmpty) {
                              label =
                              '$busName - $busNumber';
                            } else if (busName
                                .isNotEmpty) {
                              label = busName;
                            } else if (busNumber
                                .isNotEmpty) {
                              label = busNumber;
                            } else {
                              label = busDoc.id;
                            }

                            return DropdownMenuItem<
                                String>(
                              value: busDoc.id,
                              child: Text(
                                label,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedBusId = value;

                              c['busId']!.text =
                                  value ?? '';

                              // Automatically select the route
                              // assigned to the selected bus.
                              if (value != null) {
                                final selectedBus =
                                buses.firstWhere(
                                      (bus) =>
                                  bus.id == value,
                                );

                                final busData =
                                selectedBus.data();

                                final routeId =
                                busData['routeId']
                                    ?.toString()
                                    .trim();

                                if (routeId != null &&
                                    routeId.isNotEmpty &&
                                    routes.any(
                                          (route) =>
                                      route.id ==
                                          routeId,
                                    )) {
                                  selectedRouteId =
                                      routeId;

                                  c['routeId']!.text =
                                      routeId;
                                }
                              }
                            });
                          },
                        ),
                      );
                    }

                    // ==================================================
                    // ROUTE DROPDOWN
                    // Used for Buses + Bus Schedules
                    // ==================================================

                    if ((collection == 'buses' ||
                        collection ==
                            'busSchedules') &&
                        e.key == 'routeId') {
                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                        child:
                        DropdownButtonFormField<String>(
                          value: selectedRouteId,
                          isExpanded: true,
                          decoration:
                          const InputDecoration(
                            labelText: 'Route',
                            border:
                            OutlineInputBorder(),
                          ),
                          hint:
                          const Text('Select Route'),

                          items:
                          routes.map((routeDoc) {
                            final data =
                            routeDoc.data();

                            final routeName =
                            data['routeName']
                                ?.toString()
                                .trim();

                            final label =
                            routeName != null &&
                                routeName
                                    .isNotEmpty
                                ? routeName
                                : routeDoc.id;

                            return DropdownMenuItem<
                                String>(
                              value: routeDoc.id,
                              child: Text(
                                label,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedRouteId =
                                  value;

                              c['routeId']!.text =
                                  value ?? '';
                            });
                          },
                        ),
                      );
                    }

                    // ==================================================
                    // NORMAL TEXT FIELDS
                    // ==================================================

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: TextField(
                        controller: e.value,
                        decoration:
                        InputDecoration(
                          labelText:
                          prettyFieldName(
                            e.key,
                          ),
                          border:
                          const OutlineInputBorder(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () async {
                    // --------------------------------------
                    // BUS VALIDATION
                    // --------------------------------------

                    if (collection == 'buses') {
                      if (selectedRouteId == null ||
                          selectedRouteId!
                              .isEmpty) {
                        ScaffoldMessenger.of(
                          dialogStateContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a route.',
                            ),
                          ),
                        );

                        return;
                      }

                      c['routeId']!.text =
                      selectedRouteId!;
                    }

                    // --------------------------------------
                    // SCHEDULE VALIDATION
                    // --------------------------------------

                    if (collection ==
                        'busSchedules') {
                      if (selectedBusId == null ||
                          selectedBusId!
                              .isEmpty) {
                        ScaffoldMessenger.of(
                          dialogStateContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a bus.',
                            ),
                          ),
                        );

                        return;
                      }

                      if (selectedRouteId == null ||
                          selectedRouteId!
                              .isEmpty) {
                        ScaffoldMessenger.of(
                          dialogStateContext,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select a route.',
                            ),
                          ),
                        );

                        return;
                      }

                      c['busId']!.text =
                      selectedBusId!;

                      c['routeId']!.text =
                      selectedRouteId!;
                    }

                    // --------------------------------------
                    // SAVE
                    // --------------------------------------

                    final data = normalize(c);

                    try {
                      if (id == null) {
                        await service.add(
                          collection,
                          data,
                        );
                      } else {
                        await service.update(
                          collection,
                          id,
                          data,
                        );
                      }

                      if (dialogContext.mounted) {
                        Navigator.of(
                          dialogContext,
                        ).pop();
                      }
                    } catch (e) {
                      if (dialogStateContext
                          .mounted) {
                        ScaffoldMessenger.of(
                          dialogStateContext,
                        ).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Unable to save: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // VALUE FORMATTING
  // ============================================================

  String formatValue(dynamic value) {
    if (value == null) {
      return '-';
    }

    if (value is Timestamp) {
      final d = value.toDate();

      return '${d.day.toString().padLeft(2, '0')}/'
          '${d.month.toString().padLeft(2, '0')}/'
          '${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    }

    if (value is List) {
      return value.join(', ');
    }

    if (value is Map) {
      return value.entries
          .map(
            (e) =>
        '${e.key}: ${formatValue(e.value)}',
      )
          .join('\n');
    }

    return value.toString();
  }

  String prettyFieldName(String field) {
    final result = field.replaceAllMapped(
      RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
    );

    if (result.isEmpty) {
      return field;
    }

    return result[0].toUpperCase() +
        result.substring(1);
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Future<void> showDetails(
      BuildContext context,
      String documentId,
      Map<String, dynamic> data,
      ) async {
    final entries = data.entries.toList()
      ..sort(
            (a, b) => a.key.compareTo(b.key),
      );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('$title Details'),

          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 4),

                  SelectableText(documentId),

                  const Divider(height: 28),

                  ...entries.map(
                        (entry) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            prettyFieldName(
                              entry.key,
                            ),
                            style:
                            const TextStyle(
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          SelectableText(
                            formatValue(
                              entry.value,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          actions: [
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                    dialogContext,
                  ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  String getLabel(
      DocumentSnapshot<Map<String, dynamic>> d,
      ) {
    final m = d.data() ?? {};

    if (filterType == 'lateArrivals') {
      final name =
          m['studentName'] ??
              m['participantCode'];

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString();
      }

      return 'Late Arrival';
    }

    if (filterType == 'transportAbsences') {
      final name =
          m['studentName'] ??
              m['participantCode'];

      if (name != null &&
          name.toString().trim().isNotEmpty) {
        return name.toString();
      }

      return 'Transport Absence';
    }

    final possibleLabels = [
      m['routeName'],
      m['stopName'],
      m['busName'],
      m['departureTime'],
      m['name'],
      m['studentName'],
      m['participantCode'],
      m['problemType'],
      m['reason'],
      m['delayMinutes'],
      m['userId'],
    ];

    for (final value in possibleLabels) {
      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return d.id;
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  String getSubtitle(
      Map<String, dynamic> data,
      String documentId,
      ) {
    if (filterType == 'lateArrivals') {
      final reason = data['reason'];

      if (reason != null &&
          reason.toString().trim().isNotEmpty) {
        return 'Reason: $reason\n'
            'Tap to view details';
      }

      return 'Reached Late • '
          'Tap to view details';
    }

    if (filterType == 'transportAbsences') {
      final reason = data['reason'];

      if (reason != null &&
          reason.toString().trim().isNotEmpty) {
        return 'Reason: $reason\n'
            'Tap to view details';
      }

      return 'Transport-related absence • '
          'Tap to view details';
    }

    if (isManageableCollection) {
      return documentId;
    }

    return 'Tap to view details';
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
  applyFilter(
      List<QueryDocumentSnapshot<Map<String, dynamic>>>
      docs,
      ) {
    if (filterType == 'lateArrivals') {
      return docs.where((doc) {
        final data = doc.data();

        return data['status'] ==
            'Reached Late';
      }).toList();
    }

    if (filterType == 'transportAbsences') {
      return docs.where((doc) {
        final data = doc.data();

        return data['status'] ==
            'Could Not Attend' &&
            data['transportRelated'] == true;
      }).toList();
    }

    return docs;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final service = AdminService();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),

      floatingActionButton:
      isManageableCollection
          ? FloatingActionButton(
        onPressed: () =>
            editor(
              context,
              service,
            ),
        child:
        const Icon(Icons.add),
      )
          : null,

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream:
        service.collectionStream(
          collection,
        ),

        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Text(
                  'Unable to load $title.\n\n'
                      '${snap.error}',
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          if (!snap.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final allDocs =
              snap.data!.docs;

          final docs =
          applyFilter(allDocs);

          if (docs.isEmpty) {
            String message =
                'No $title found.';

            if (filterType ==
                'lateArrivals') {
              message =
              'No late arrival records found.';
            }

            if (filterType ==
                'transportAbsences') {
              message =
              'No transport-related absence '
                  'records found.';
            }

            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Text(
                  message,
                  textAlign:
                  TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding:
            const EdgeInsets.all(12),

            children: docs.map((d) {
              final m = d.data();

              final label =
              getLabel(d);

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      filterType ==
                          'lateArrivals'
                          ? Icons.schedule
                          : filterType ==
                          'transportAbsences'
                          ? Icons
                          .directions_bus_outlined
                          : isManageableCollection
                          ? Icons
                          .edit_outlined
                          : Icons
                          .description_outlined,
                    ),
                  ),

                  title: Text(
                    label,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                  ),

                  subtitle: Text(
                    getSubtitle(
                      m,
                      d.id,
                    ),
                  ),

                  isThreeLine:
                  filterType != null,

                  onTap: () {
                    if (isManageableCollection) {
                      editor(
                        context,
                        service,
                        id: d.id,
                        current: m,
                      );
                    } else {
                      showDetails(
                        context,
                        d.id,
                        m,
                      );
                    }
                  },

                  trailing:
                  isManageableCollection
                      ? IconButton(
                    icon:
                    const Icon(
                      Icons
                          .delete_outline,
                    ),
                    onPressed: () =>
                        service.delete(
                          collection,
                          d.id,
                        ),
                  )
                      : const Icon(
                    Icons
                        .chevron_right,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}