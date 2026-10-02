import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/app_models.dart';
import '../../services/bus_repository.dart';
import '../../services/profile_service.dart';
import '../../services/trip_planner_service.dart';
import '../../services/trip_service.dart';
import '../../widgets/app_shell.dart';

class PlanTripScreen extends StatefulWidget {
  const PlanTripScreen({super.key});

  @override
  State<PlanTripScreen> createState() => _PlanTripScreenState();
}

class _PlanTripScreenState extends State<PlanTripScreen> {
  final BusRepository repo = BusRepository();
  final TripPlannerService planner = TripPlannerService();

  List<BusRoute> routes = [];
  BusRoute? route;

  TimeOfDay reachBy = const TimeOfDay(
    hour: 10,
    minute: 30,
  );

  int walkMinutes = 15;

  TripPlanResult? result;

  bool busy = true;

  String? errorMessage;

  // ============================================================
  // INITIALIZE SCREEN
  // ============================================================

  @override
  void initState() {
    super.initState();
    prepare();
  }

  Future<void> prepare() async {
    if (mounted) {
      setState(() {
        busy = true;
        errorMessage = null;
      });
    }

    try {
      // --------------------------------------------------------
      // LOAD ACTIVE ROUTES
      // --------------------------------------------------------

      final loadedRoutes = await repo.getActiveRoutes();

      if (!mounted) return;

      routes = loadedRoutes;

      if (routes.isNotEmpty) {
        route = routes.first;
      } else {
        route = null;
      }

      // --------------------------------------------------------
      // LOAD STUDENT PROFILE
      // --------------------------------------------------------

      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final p = await ProfileService().getProfile(uid);

        if (!mounted) return;

        final distanceValue = p?['busStopDistanceKm'];

        double km = 1;

        if (distanceValue is num) {
          km = distanceValue.toDouble();
        } else if (distanceValue != null) {
          km =
              double.tryParse(
                distanceValue.toString(),
              ) ??
                  1;
        }

        if (km < 0) {
          km = 1;
        }

        walkMinutes = ((km / 4.5) * 60).round();

        if (walkMinutes < 1) {
          walkMinutes = 1;
        }
      }
    } catch (e) {
      if (!mounted) return;

      errorMessage =
      'Unable to load trip information.\n\n$e';
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ============================================================
  // FIND BEST JOURNEY
  // ============================================================

  Future<void> find() async {
    if (route == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a route first.',
          ),
        ),
      );

      return;
    }

    setState(() {
      busy = true;
      errorMessage = null;
      result = null;
    });

    try {
      // --------------------------------------------------------
      // LOAD SCHEDULES FOR SELECTED ROUTE
      // --------------------------------------------------------

      final schedules =
      await repo.getSchedulesForRoute(route!.id);

      if (!mounted) return;

      // No schedule available for this route.
      if (schedules.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No active bus schedule is available for '
                  '${route!.routeName}.',
            ),
          ),
        );

        return;
      }

      // --------------------------------------------------------
      // REQUIRED ARRIVAL TIME
      // --------------------------------------------------------

      final now = DateTime.now();

      final required = DateTime(
        now.year,
        now.month,
        now.day,
        reachBy.hour,
        reachBy.minute,
      );

      // --------------------------------------------------------
      // FIND RECOMMENDED JOURNEY
      // --------------------------------------------------------

      final recommendation = planner.recommend(
        schedules: schedules,
        requiredArrival: required,
        walkMinutes: walkMinutes,
      );

      if (!mounted) return;

      setState(() {
        result = recommendation;
      });

      if (recommendation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No suitable journey was found for the '
                  'selected arrival time.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
        'Unable to find a journey.\n\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  // ============================================================
  // START TRIP
  // ============================================================

  Future<void> startTrip() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || result == null) {
      return;
    }

    try {
      final id = await TripService().startTrip(
        userId: uid,
        busId: result!.schedule.busId,
        routeId: result!.schedule.routeId,
        expectedArrival: result!.expectedArrival,
      );

      if (!mounted) return;

      context.push(
        '/active-journey',
        extra: {
          'tripId': id,
          'busId': result!.schedule.busId,
          'routeId': result!.schedule.routeId,
          'departure':
          result!.schedule.departureTime,
          'arrival':
          result!.schedule.expectedArrivalTime,
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to start the trip: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> selectReachTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: reachBy,
    );

    if (t != null && mounted) {
      setState(() {
        reachBy = t;
        result = null;
      });
    }
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget buildErrorView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 58,
              color:
              Theme.of(context).colorScheme.error,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to Load Trip Planner',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              errorMessage ??
                  'An unexpected error occurred.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 22),

            FilledButton.icon(
              onPressed: prepare,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY ROUTES VIEW
  // ============================================================

  Widget buildNoRoutesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.route_outlined,
              size: 58,
            ),

            const SizedBox(height: 16),

            const Text(
              'No Routes Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'There are currently no active bus routes '
                  'available for trip planning.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: prepare,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN TRIP PLANNER
  // ============================================================

  Widget buildTripPlanner() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ------------------------------------------------------
        // ROUTE
        // ------------------------------------------------------

        DropdownButtonFormField<BusRoute>(
          value: route,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Route',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.route),
          ),
          items: routes.map((r) {
            return DropdownMenuItem<BusRoute>(
              value: r,
              child: Text(
                r.routeName,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (r) {
            setState(() {
              route = r;
              result = null;
              errorMessage = null;
            });
          },
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // REQUIRED COLLEGE ARRIVAL
        // ------------------------------------------------------

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(
              color: Color(0xFFDDE1EA),
            ),
          ),
          leading: const Icon(
            Icons.access_time,
          ),
          title: const Text(
            'Need to reach college by',
          ),
          trailing: Text(
            reachBy.format(context),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: selectReachTime,
        ),

        const SizedBox(height: 16),

        // ------------------------------------------------------
        // WALK TIME
        // ------------------------------------------------------

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFDDE1EA),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.directions_walk,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  'Estimated walk to stop: '
                      '$walkMinutes minutes',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ------------------------------------------------------
        // FIND JOURNEY
        // ------------------------------------------------------

        FilledButton.icon(
          onPressed: find,
          icon: const Icon(Icons.search),
          label: const Text(
            'Find Best Journey',
          ),
        ),

        const SizedBox(height: 20),

        // ------------------------------------------------------
        // NO RESULT YET
        // ------------------------------------------------------

        if (result == null)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select a route and your required '
                          'arrival time, then tap '
                          '"Find Best Journey".',
                    ),
                  ),
                ],
              ),
            ),
          )

        // ------------------------------------------------------
        // RECOMMENDED JOURNEY
        // ------------------------------------------------------

        else
          Card(
            child: Padding(
              padding:
              const EdgeInsets.all(18),
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

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Recommended Journey',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                            FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Bus departure: '
                        '${result!.schedule.departureTime}',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Expected arrival: '
                        '${result!.schedule.expectedArrivalTime}',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Walk time: '
                        '${result!.walkMinutes} min',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Leave home: '
                        '${TimeOfDay.fromDateTime(result!.leaveHome).format(context)}',
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'College buffer: '
                        '${result!.collegeBufferMinutes} min',
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: startTrip,
                      icon: const Icon(
                        Icons.play_arrow,
                      ),
                      label: const Text(
                        'Start This Trip',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 2,
      child: Scaffold(
        appBar: AppBar(
          title:
          const Text('Plan My Trip'),
        ),

        body: busy
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : errorMessage != null
            ? buildErrorView()
            : routes.isEmpty
            ? buildNoRoutesView()
            : buildTripPlanner(),
      ),
    );
  }
}