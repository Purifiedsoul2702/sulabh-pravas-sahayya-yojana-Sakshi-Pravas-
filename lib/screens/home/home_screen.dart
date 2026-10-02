import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primary =
  Color(0xFF5B4FD8);

  static const Color primaryDark =
  Color(0xFF3730A3);

  static const Color background =
  Color(0xFFF7F8FC);

  // ============================================================
  // LOGO
  // ============================================================

  Widget _logo() {
    return Container(
      width: 50,
      height: 50,

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF675CE5),
            Color(0xFF4338CA),
          ],
        ),

        borderRadius:
        BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 29,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF20232A),
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF777D89),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK SERVICE TILE
  // ============================================================

  Widget _serviceTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Material(
      color: Colors.white,

      borderRadius:
      BorderRadius.circular(20),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(20),

        onTap: () =>
            context.push(route),

        child: Container(
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(20),

            border: Border.all(
              color:
              const Color(0xFFE7E9F1),
            ),
          ),

          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 18,
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Container(
                width: 56,
                height: 56,

                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius:
                  BorderRadius.circular(18),
                ),

                child: Icon(
                  icon,
                  color: iconColor,
                  size: 29,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 13,
                  height: 1.2,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  Color(0xFF30343B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _activityCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 11),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(19),

        border: Border.all(
          color:
          const Color(0xFFE7E9F1),
        ),
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius:
          BorderRadius.circular(19),

          onTap: () =>
              context.push(route),

          child: Padding(
            padding:
            const EdgeInsets.all(15),

            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,

                  decoration:
                  BoxDecoration(
                    color: iconBackground,
                    borderRadius:
                    BorderRadius
                        .circular(16),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        title,

                        style:
                        const TextStyle(
                          fontSize: 15.5,
                          fontWeight:
                          FontWeight.w800,
                          color: Color(
                            0xFF252A34,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        subtitle,

                        style:
                        const TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: Color(
                            0xFF777D89,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 15,
                  color:
                  Color(0xFFA0A5AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 0,

      child: Scaffold(
        backgroundColor: background,

        body: SafeArea(
          child: ListView(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              14,
              16,
              30,
            ),

            children: [
              // =================================================
              // HEADER
              // =================================================

              Row(
                children: [
                  _logo(),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [
                        Text(
                          'सुलभ प्रवास सहाय्य योजना',

                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                            FontWeight.w900,
                            color:
                            primaryDark,
                          ),
                        ),

                        SizedBox(height: 2),

                        Text(
                          'Rural Student Travel Assistant',

                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                            FontWeight.w500,
                            color: Color(
                              0xFF777D89,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Material(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),

                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),

                      onTap: () {
                        context.push(
                          '/notifications',
                        );
                      },

                      child: Container(
                        width: 47,
                        height: 47,

                        decoration:
                        BoxDecoration(
                          border:
                          Border.all(
                            color:
                            const Color(
                              0xFFE7E9F1,
                            ),
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(15),
                        ),

                        child: const Icon(
                          Icons
                              .notifications_none_rounded,
                          color: primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // =================================================
              // WELCOME
              // =================================================

              const Text(
                'नमस्कार 👋',

                style: TextStyle(
                  fontSize: 14,
                  color:
                  Color(0xFF777D89),
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'आजचा प्रवास नियोजित करा',

                style: TextStyle(
                  fontSize: 24,
                  height: 1.25,
                  fontWeight:
                  FontWeight.w900,
                  color:
                  Color(0xFF20232A),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // MAIN JOURNEY CARD
              // =================================================

              Container(
                padding:
                const EdgeInsets.all(21),

                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(
                    begin: Alignment.topLeft,
                    end:
                    Alignment.bottomRight,

                    colors: [
                      Color(0xFF675CE5),
                      Color(0xFF3730A3),
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    25,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: primary
                          .withOpacity(0.20),
                      blurRadius: 20,
                      offset:
                      const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Container(
                          width: 57,
                          height: 57,

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              0.15,
                            ),

                            borderRadius:
                            BorderRadius
                                .circular(
                              18,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons
                                .directions_bus_rounded,
                            size: 31,
                            color:
                            Colors.white,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration:
                          BoxDecoration(
                            color: Colors
                                .white
                                .withOpacity(
                              0.14,
                            ),

                            borderRadius:
                            BorderRadius
                                .circular(
                              30,
                            ),
                          ),

                          child:
                          const Text(
                            'आजचा प्रवास',

                            style:
                            TextStyle(
                              color:
                              Colors.white,
                              fontSize: 12,
                              fontWeight:
                              FontWeight
                                  .w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'तुमचा महाविद्यालयीन\nप्रवास सोपा करा',

                      style: TextStyle(
                        color:
                        Colors.white,
                        fontSize: 22,
                        height: 1.25,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Text(
                      'बस, मार्ग आणि प्रवासाचे नियोजन एकाच ठिकाणी.',

                      style: TextStyle(
                        color: Colors.white
                            .withOpacity(
                          0.85,
                        ),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width:
                      double.infinity,

                      child:
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push(
                            '/plan-trip',
                          );
                        },

                        icon: const Icon(
                          Icons
                              .route_rounded,
                        ),

                        label:
                        const Text(
                          'Plan My Trip',
                        ),

                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          Colors.white,
                          foregroundColor:
                          primaryDark,
                          elevation: 0,

                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 14,
                          ),

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // =================================================
              // QUICK SERVICES
              // =================================================

              _sectionTitle(
                'Quick Services',
                'प्रवासासाठी आवश्यक सुविधा',
              ),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisSpacing: 12,
                mainAxisSpacing: 12,

                childAspectRatio: 1.22,

                children: [
                  _serviceTile(
                    context: context,

                    icon: Icons
                        .directions_bus_rounded,

                    title:
                    'Bus Schedule',

                    route: '/buses',

                    iconColor:
                    const Color(
                      0xFF2563EB,
                    ),

                    backgroundColor:
                    const Color(
                      0xFFEAF2FF,
                    ),
                  ),

                  _serviceTile(
                    context: context,

                    icon:
                    Icons.route_rounded,

                    title:
                    'Plan My Trip',

                    route: '/plan-trip',

                    iconColor: primary,

                    backgroundColor:
                    const Color(
                      0xFFEDE9FE,
                    ),
                  ),

                  _serviceTile(
                    context: context,

                    icon: Icons
                        .location_on_rounded,

                    title:
                    'Nearby Bus Stops',

                    route:
                    '/nearby-stops',

                    iconColor:
                    const Color(
                      0xFF159447,
                    ),

                    backgroundColor:
                    const Color(
                      0xFFE9F8EF,
                    ),
                  ),

                  _serviceTile(
                    context: context,

                    icon: Icons
                        .fact_check_rounded,

                    title: 'Attendance',

                    route:
                    '/attendance',

                    iconColor:
                    const Color(
                      0xFFE27B00,
                    ),

                    backgroundColor:
                    const Color(
                      0xFFFFF2DF,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // =================================================
              // MY ACTIVITY
              // =================================================

              _sectionTitle(
                'My Activity',
                'प्रवास आणि उपस्थितीची नोंद',
              ),

              const SizedBox(height: 14),

              _activityCard(
                context: context,

                icon:
                Icons.history_rounded,

                title:
                'Travel History',

                subtitle:
                'तुमचे पूर्ण झालेले मागील प्रवास पहा',

                route:
                '/travel-history',

                iconColor: primary,

                iconBackground:
                const Color(
                  0xFFEDE9FE,
                ),
              ),

              _activityCard(
                context: context,

                icon: Icons
                    .fact_check_rounded,

                title: 'Attendance',

                subtitle:
                'तुमची नोंदवलेली महाविद्यालयीन उपस्थिती पहा',

                route:
                '/attendance',

                iconColor:
                const Color(
                  0xFF159447,
                ),

                iconBackground:
                const Color(
                  0xFFE9F8EF,
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // SAFETY
              // =================================================

              InkWell(
                borderRadius:
                BorderRadius.circular(
                  20,
                ),

                onTap: () {
                  context.push(
                    '/safety',
                  );
                },

                child: Container(
                  padding:
                  const EdgeInsets.all(
                    17,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFFFF7F8,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    border: Border.all(
                      color:
                      const Color(
                        0xFFFFDCE3,
                      ),
                    ),
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFFFE8ED,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),

                        child:
                        const Icon(
                          Icons
                              .shield_rounded,
                          color:
                          Color(
                            0xFFE84C6A,
                          ),
                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              'Safety & SOS',

                              style:
                              TextStyle(
                                fontSize: 15.5,
                                fontWeight:
                                FontWeight
                                    .w900,
                                color:
                                Color(
                                  0xFFB83250,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Text(
                              'आपत्कालीन मदत आणि लोकेशन शेअर करण्यासाठी',

                              style:
                              TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color:
                                Color(
                                  0xFF76515A,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 15,
                        color:
                        Color(
                          0xFFB83250,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // SMALL FOOTER
              // =================================================

              const Center(
                child: Text(
                  'सुरक्षित प्रवास • नियमित उपस्थिती',

                  style: TextStyle(
                    fontSize: 11,
                    color:
                    Color(0xFF9CA3AF),
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
