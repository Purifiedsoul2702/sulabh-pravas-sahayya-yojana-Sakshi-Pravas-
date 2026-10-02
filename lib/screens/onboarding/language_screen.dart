import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen
    extends StatelessWidget {
  const LanguageScreen({super.key});

  static const Color primary =
  Color(0xFF5B4FD8);
  static const Color primaryDark =
  Color(0xFF3730A3);

  Future<void> choose(
      BuildContext context,
      String code,
      ) async {
    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.setString(
      'language',
      code,
    );

    if (context.mounted) {
      context.go('/welcome');
    }
  }

  Widget languageCard({
    required BuildContext context,
    required String symbol,
    required String title,
    required String subtitle,
    required String code,
    required Color background,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(22),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(22),
        onTap: () =>
            choose(context, code),
        child: Container(
          padding:
          const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius:
            BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color:
              const Color(
                0xFFE6E8F0,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 57,
                height: 57,
                decoration:
                BoxDecoration(
                  color: background,
                  borderRadius:
                  BorderRadius
                      .circular(17),
                ),
                alignment:
                Alignment.center,
                child: Text(
                  symbol,
                  style:
                  const TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w900,
                    color: primaryDark,
                  ),
                ),
              ),

              const SizedBox(
                width: 15,
              ),

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
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .w800,
                        color:
                        Color(
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
                        color:
                        Color(
                          0xFF7A8291,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 16,
                color: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Spacer(),

              Center(
                child: Container(
                  width: 86,
                  height: 86,
                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFEDE9FE,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(27),
                  ),
                  child: const Icon(
                    Icons
                        .language_rounded,
                    size: 43,
                    color: primary,
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              const Center(
                child: Text(
                  'Choose Your Language',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight:
                    FontWeight.w900,
                    color:
                    Color(
                      0xFF20232A,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              const Center(
                child: Text(
                  'तुमची भाषा निवडा',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                    Color(
                      0xFF697386,
                    ),
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(
                height: 32,
              ),

              languageCard(
                context: context,
                symbol: 'म',
                title: 'मराठी',
                subtitle:
                'ॲप मराठीमध्ये वापरा',
                code: 'mr',
                background:
                const Color(
                  0xFFFFF1DF,
                ),
              ),

              const SizedBox(
                height: 13,
              ),

              languageCard(
                context: context,
                symbol: 'EN',
                title: 'English',
                subtitle:
                'Continue in English',
                code: 'en',
                background:
                const Color(
                  0xFFEAF2FF,
                ),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  'You can continue with your preferred language.',
                  textAlign:
                  TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                    Color(
                      0xFF9AA1AE,
                    ),
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