import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  static const Color primary =
  Color(0xFF5B4FD8);
  static const Color primaryDark =
  Color(0xFF3730A3);

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
          () {
        if (mounted) {
          context.go('/language');
        }
      },
    );
  }

  Widget logo() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7167E8),
            primaryDark,
          ],
        ),
        borderRadius:
        BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color:
            primary.withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons
                .directions_bus_rounded,
            color: Colors.white,
            size: 55,
          ),

          Positioned(
            right: 18,
            top: 17,
            child: Container(
              width: 27,
              height: 27,
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFFFC857),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons
                    .location_on_rounded,
                size: 17,
                color: primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
        const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F3FF),
              Color(0xFFF8FAFF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(
                flex: 3,
              ),

              logo(),

              const SizedBox(
                height: 28,
              ),

              const Text(
                'सुलभ प्रवास सहाय्य योजना',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight:
                  FontWeight.w900,
                  color: primaryDark,
                  height: 1.2,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'Rural Student Travel Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  Color(0xFF697386),
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              Container(
                margin:
                const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                  border: Border.all(
                    color:
                    const Color(
                      0xFFE6E4F5,
                    ),
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .shield_outlined,
                      size: 18,
                      color:
                      Color(
                        0xFF1F9D61,
                      ),
                    ),
                    SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'सुरक्षित प्रवास  •  योग्य वेळ  •  नियमित उपस्थिती',
                        textAlign:
                        TextAlign.center,
                        style:
                        TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight
                              .w600,
                          color:
                          Color(
                            0xFF667085,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(
                flex: 4,
              ),

              const SizedBox(
                width: 26,
                height: 26,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: primary,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Preparing your journey...',
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Color(0xFF98A0AE),
                ),
              ),

              const SizedBox(
                height: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
