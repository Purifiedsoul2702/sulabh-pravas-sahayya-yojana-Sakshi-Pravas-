import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  final Widget child;
  final int currentIndex;

  static const Color primary =
  Color(0xFF5B4FD8);

  @override
  Widget build(BuildContext context) {
    const routes = [
      '/home',
      '/buses',
      '/plan-trip',
      '/safety',
      '/profile',
    ];

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FC),

      body: child,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.07),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),

        child: SafeArea(
          top: false,

          child: NavigationBar(
            selectedIndex: currentIndex,

            backgroundColor: Colors.white,

            elevation: 0,

            height: 68,

            indicatorColor:
            primary.withOpacity(0.12),

            onDestinationSelected: (index) {
              if (index == currentIndex) {
                return;
              }

              context.go(routes[index]);
            },

            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                ),
                label: 'Home',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons
                      .directions_bus_outlined,
                ),
                selectedIcon: Icon(
                  Icons
                      .directions_bus_rounded,
                ),
                label: 'Buses',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.route_outlined,
                ),
                selectedIcon: Icon(
                  Icons.route_rounded,
                ),
                label: 'Trip',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.shield_outlined,
                ),
                selectedIcon: Icon(
                  Icons.shield_rounded,
                ),
                label: 'Safety',
              ),

              NavigationDestination(
                icon: Icon(
                  Icons.person_outline_rounded,
                ),
                selectedIcon: Icon(
                  Icons.person_rounded,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}