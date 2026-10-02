import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen
    extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color primary =
  Color(0xFF5B4FD8);
  static const Color primaryDark =
  Color(0xFF3730A3);

  Widget feature(
      IconData icon,
      String title,
      Color color,
      Color background,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration:
            BoxDecoration(
              color: background,
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 23,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Text(
              title,
              style:
              const TextStyle(
                fontSize: 14,
                fontWeight:
                FontWeight.w600,
                color:
                Color(
                  0xFF414753,
                ),
              ),
            ),
          ),

          const Icon(
            Icons
                .check_circle_rounded,
            size: 20,
            color:
            Color(0xFF1F9D61),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            30,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                  BoxDecoration(
                    gradient:
                    const LinearGradient(
                      colors: [
                        Color(
                          0xFF675CE5,
                        ),
                        primaryDark,
                      ],
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(16),
                  ),
                  child:
                  const Icon(
                    Icons
                        .directions_bus_rounded,
                    color:
                    Colors.white,
                    size: 29,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        'सुलभ प्रवास सहाय्य योजना',
                        style:
                        TextStyle(
                          fontSize: 21,
                          fontWeight:
                          FontWeight
                              .w900,
                          color:
                          primaryDark,
                        ),
                      ),
                      Text(
                        'Rural Student Travel Assistant',
                        style:
                        TextStyle(
                          fontSize: 10.5,
                          color:
                          Color(
                            0xFF7A8291,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 35,
            ),

            Container(
              padding:
              const EdgeInsets.all(
                22,
              ),
              decoration:
              BoxDecoration(
                gradient:
                const LinearGradient(
                  begin:
                  Alignment.topLeft,
                  end: Alignment
                      .bottomRight,
                  colors: [
                    Color(
                      0xFF675CE5,
                    ),
                    primaryDark,
                  ],
                ),
                borderRadius:
                BorderRadius.circular(
                  25,
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Icon(
                    Icons
                        .route_rounded,
                    color:
                    Colors.white,
                    size: 36,
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Text(
                    'तुमच्या महाविद्यालयीन\nप्रवासाची सोपी सखी',
                    style:
                    TextStyle(
                      color:
                      Colors.white,
                      fontSize: 23,
                      height: 1.3,
                      fontWeight:
                      FontWeight
                          .w900,
                    ),
                  ),
                  SizedBox(
                    height: 9,
                  ),
                  Text(
                    'Plan your journey, check bus information, report travel difficulties and maintain your travel-related attendance record.',
                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFFE8E6FF,
                      ),
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            const Text(
              'What you can do',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.w900,
                color:
                Color(
                  0xFF20232A,
                ),
              ),
            ),

            const SizedBox(
              height: 17,
            ),

            feature(
              Icons
                  .directions_bus_rounded,
              'Bus timings and route information',
              const Color(
                0xFF2563EB,
              ),
              const Color(
                0xFFEAF2FF,
              ),
            ),

            feature(
              Icons.route_rounded,
              'Travel planning and leave-home time',
              primary,
              const Color(
                0xFFEDE9FE,
              ),
            ),

            feature(
              Icons
                  .report_problem_outlined,
              'Delay and travel problem reporting',
              const Color(
                0xFFE27B00,
              ),
              const Color(
                0xFFFFF2DF,
              ),
            ),

            feature(
              Icons.shield_rounded,
              'Safety assistance and location sharing',
              const Color(
                0xFFE84C6A,
              ),
              const Color(
                0xFFFFE8ED,
              ),
            ),

            feature(
              Icons
                  .fact_check_rounded,
              'Attendance and travel history',
              const Color(
                0xFF159447,
              ),
              const Color(
                0xFFE9F8EF,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            FilledButton.icon(
              onPressed: () =>
                  context.go(
                    '/register',
                  ),
              icon: const Icon(
                Icons
                    .person_add_alt_1_rounded,
              ),
              label: const Text(
                'Create Account',
              ),
            ),

            const SizedBox(
              height: 11,
            ),

            OutlinedButton(
              onPressed: () =>
                  context.go(
                    '/login',
                  ),
              child: const Text(
                'I already have an account',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
