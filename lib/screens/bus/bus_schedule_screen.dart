import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_models.dart';
import '../../services/bus_repository.dart';
import '../../widgets/app_shell.dart';

class BusScheduleScreen extends StatefulWidget {
  const BusScheduleScreen({super.key});

  @override
  State<BusScheduleScreen> createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  final repo = BusRepository();

  List<BusRoute> routes = [];
  List<BusSchedule> schedules = [];

  BusRoute? selected;
  bool busy = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final loadedRoutes = await repo.getActiveRoutes();

      List<BusSchedule> loadedSchedules = [];
      BusRoute? firstRoute;

      if (loadedRoutes.isNotEmpty) {
        firstRoute = loadedRoutes.first;

        loadedSchedules =
        await repo.getSchedulesForRoute(firstRoute.id);
      }

      if (!mounted) return;

      setState(() {
        routes = loadedRoutes;
        selected = firstRoute;
        schedules = loadedSchedules;
        busy = false;
        errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint('BUS SCHEDULE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        busy = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> change(BusRoute? route) async {
    if (route == null) return;

    setState(() {
      selected = route;
      busy = true;
      errorMessage = null;
    });

    try {
      final loadedSchedules =
      await repo.getSchedulesForRoute(route.id);

      if (!mounted) return;

      setState(() {
        schedules = loadedSchedules;
        busy = false;
      });
    } catch (e, stackTrace) {
      debugPrint('BUS ROUTE CHANGE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        busy = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bus Schedule'),
        ),
        body: busy
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load bus schedules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      busy = true;
                      errorMessage = null;
                    });

                    load();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        )
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (routes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No active routes available.',
                  ),
                ),
              )
            else
              DropdownButtonFormField<BusRoute>(
                value: selected,
                decoration: const InputDecoration(
                  labelText: 'Route',
                ),
                items: routes
                    .map(
                      (r) => DropdownMenuItem<BusRoute>(
                    value: r,
                    child: Text(r.routeName),
                  ),
                )
                    .toList(),
                onChanged: change,
              ),

            const SizedBox(height: 14),

            if (routes.isNotEmpty && schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No schedules available.',
                  ),
                ),
              ),

            ...schedules.map(
                  (s) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.directions_bus),
                  ),
                  title: Text(
                    s.departureTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  subtitle: Text(
                    'Expected arrival: ${s.expectedArrivalTime}',
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      context.push(
                        '/bus-details',
                        extra: {
                          'busId': s.busId,
                          'routeId': s.routeId,
                          'departure': s.departureTime,
                          'arrival':
                          s.expectedArrivalTime,
                        },
                      );
                    },
                    child: const Text('View'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}