import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/admin_service.dart';
import '../../services/csv_export_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? analytics;

  bool loading = true;
  String? error;

  static const Color primary = Color(0xFF5B4FD8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color background = Color(0xFFF6F7FB);
  static const Color textPrimary = Color(0xFF20232A);
  static const Color textSecondary = Color(0xFF697386);
  static const Color border = Color(0xFFE7E9F1);

  @override
  void initState() {
    super.initState();
    load();
  }

  // ============================================================
  // DATA
  // ============================================================

  Future<void> load() async {
    try {
      final loaded = await AdminService().researchAnalytics();

      if (!mounted) return;

      setState(() {
        analytics = loaded;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  double number(String key) {
    final value = analytics?[key];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int integer(String key) {
    final value = analytics?[key];

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String signedNumber(
      double value, {
        int decimals = 1,
      }) {
    if (value > 0) {
      return '+${value.toStringAsFixed(decimals)}';
    }

    return value.toStringAsFixed(decimals);
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _logo() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7167E8),
            primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.directions_bus_rounded,
            color: Colors.white,
            size: 29,
          ),
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC857),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 11,
                color: primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget sectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 6,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW CARD
  // ============================================================

  Widget overviewCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 21,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_outward_rounded,
                    size: 17,
                    color: Color(0xFFA0A5AF),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INDICATOR
  // ============================================================

  Widget indicatorTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color lightColor,
    String? note,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF98A0AE),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRE / POST ROW
  // ============================================================

  Widget prePostRow({
    required IconData icon,
    required String title,
    required String pre,
    required String post,
    required String change,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _valueBox(
                  label: 'PRE',
                  value: pre,
                  background: const Color(0xFFF3F4F7),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 21,
                  color: color,
                ),
              ),
              Expanded(
                child: _valueBox(
                  label: 'POST',
                  value: post,
                  background: color.withOpacity(0.08),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              change,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _valueBox({
    required String label,
    required String value,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MANAGEMENT TILE
  // ============================================================

  Widget managementTile({
    required String title,
    required IconData icon,
    required Color color,
    required Color lightColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: lightColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXPORT
  // ============================================================

  Future<void> exportCsv() async {
    try {
      final file = await CsvExportService().exportResearchData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV saved: ${file.path}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'CSV export failed: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: loading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : error != null
            ? buildError()
            : buildDashboard(),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8ED),
                borderRadius: BorderRadius.circular(23),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 38,
                color: Color(0xFFE5484D),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  loading = true;
                  error = null;
                });
                load();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DASHBOARD
  // ============================================================

  Widget buildDashboard() {
    final participants = integer('participants');
    final averageDelay = number('averageDelay');

    final preAttendance = number('preAttendanceMean');
    final postAttendance = number('postAttendanceMean');
    final attendanceChange = number('attendanceChange');

    final preLate = number('preLateMean');
    final postLate = number('postLateMean');
    final lateReduction = number('lateReduction');

    final preTransport = number('preTransportMean');
    final postTransport = number('postTransportMean');
    final transportReduction = number('transportReduction');

    final mostCommonProblem =
        analytics?['mostCommonProblem']?.toString() ?? 'No data';

    final mostCommonProblemCount =
    integer('mostCommonProblemCount');

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          15,
          16,
          32,
        ),
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          Row(
            children: [
              _logo(),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'सुलभ प्रवास सहाय्य योजना',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryDark,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'Researcher Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: IconButton(
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      loading = true;
                      error = null;
                    });
                    load();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ====================================================
          // INTRODUCTION
          // ====================================================

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF675CE5),
                  Color(0xFF3730A3),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Research Administration',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Monitor student travel, attendance and PRE/POST research data.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFFE8E6FF),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  Icons.analytics_rounded,
                  size: 46,
                  color: Color(0xFFDCD8FF),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // RESEARCH OVERVIEW
          // ====================================================

          sectionHeader(
            title: 'Research Overview',
            subtitle: 'Current records and travel activity',
            icon: Icons.dashboard_rounded,
          ),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.30,
            children: [
              overviewCard(
                label: 'Students',
                value: integer('students'),
                icon: Icons.people_alt_rounded,
                color: const Color(0xFF2563EB),
                lightColor: const Color(0xFFEAF2FF),
                onTap: () {
                  context.push('/admin/students');
                },
              ),
              overviewCard(
                label: 'Routes',
                value: integer('routes'),
                icon: Icons.route_rounded,
                color: primary,
                lightColor: const Color(0xFFEDE9FE),
                onTap: () {
                  context.push('/admin/routes');
                },
              ),
              overviewCard(
                label: 'Delay Reports',
                value: integer('delayReports'),
                icon: Icons.schedule_rounded,
                color: const Color(0xFFE27B00),
                lightColor: const Color(0xFFFFF2DF),
                onTap: () {
                  context.push('/admin/delay-reports');
                },
              ),
              overviewCard(
                label: 'Travel Problems',
                value: integer('travelProblems'),
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFE5484D),
                lightColor: const Color(0xFFFFE8ED),
                onTap: () {
                  context.push('/admin/travel-problems');
                },
              ),
              overviewCard(
                label: 'Late Arrivals',
                value: integer('lateArrivals'),
                icon: Icons.access_time_filled_rounded,
                color: const Color(0xFF7C3AED),
                lightColor: const Color(0xFFF1EAFE),
                onTap: () {
                  context.push('/admin/late-arrivals');
                },
              ),
              overviewCard(
                label: 'Transport Absences',
                value: integer('transportAbsences'),
                icon: Icons.event_busy_rounded,
                color: const Color(0xFF159447),
                lightColor: const Color(0xFFE9F8EF),
                onTap: () {
                  context.push('/admin/transport-absences');
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ====================================================
          // KEY INDICATORS
          // ====================================================

          sectionHeader(
            title: 'Key Indicators',
            subtitle: 'Compact research summary',
            icon: Icons.insights_rounded,
          ),

          indicatorTile(
            title: 'Paired Participants',
            value: '$participants',
            icon: Icons.groups_rounded,
            color: const Color(0xFF2563EB),
            lightColor: const Color(0xFFEAF2FF),
            note: 'Complete PRE/POST records',
          ),

          const SizedBox(height: 9),

          indicatorTile(
            title: 'Average Reported Delay',
            value: '${averageDelay.toStringAsFixed(1)} min',
            icon: Icons.timer_rounded,
            color: const Color(0xFFE27B00),
            lightColor: const Color(0xFFFFF2DF),
          ),

          const SizedBox(height: 9),

          indicatorTile(
            title: 'Attendance Change',
            value: '${signedNumber(attendanceChange)} pp',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF159447),
            lightColor: const Color(0xFFE9F8EF),
            note: 'POST mean − PRE mean',
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: indicatorTile(
                  title: 'Late Reduction',
                  value: signedNumber(lateReduction),
                  icon: Icons.schedule_rounded,
                  color: primary,
                  lightColor: const Color(0xFFEDE9FE),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: indicatorTile(
                  title: 'Absence Reduction',
                  value: signedNumber(transportReduction),
                  icon: Icons.event_available_rounded,
                  color: const Color(0xFF159447),
                  lightColor: const Color(0xFFE9F8EF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ====================================================
          // PRE / POST
          // ====================================================

          sectionHeader(
            title: 'PRE / POST Analysis',
            subtitle: 'Paired descriptive comparison',
            icon: Icons.compare_arrows_rounded,
          ),

          prePostRow(
            icon: Icons.school_rounded,
            title: 'Mean Attendance',
            pre: '${preAttendance.toStringAsFixed(1)}%',
            post: '${postAttendance.toStringAsFixed(1)}%',
            change:
            'Change: ${signedNumber(attendanceChange)} percentage points',
            color: const Color(0xFF2563EB),
          ),

          prePostRow(
            icon: Icons.access_time_filled_rounded,
            title: 'Mean Late Arrivals',
            pre: preLate.toStringAsFixed(1),
            post: postLate.toStringAsFixed(1),
            change:
            'Reduction: ${signedNumber(lateReduction)} average late arrivals',
            color: const Color(0xFFE27B00),
          ),

          prePostRow(
            icon: Icons.directions_bus_rounded,
            title: 'Transport-Related Absences',
            pre: preTransport.toStringAsFixed(1),
            post: postTransport.toStringAsFixed(1),
            change:
            'Reduction: ${signedNumber(transportReduction)} average absences',
            color: const Color(0xFF159447),
          ),

          const SizedBox(height: 15),

          // ====================================================
          // RESEARCH SUMMARY
          // ====================================================

          sectionHeader(
            title: 'Research Summary',
            subtitle: 'Interpret the current descriptive data',
            icon: Icons.fact_check_rounded,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.science_rounded,
                      color: primary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        participants == 0
                            ? 'No complete paired records yet'
                            : '$participants paired participant record(s)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                _summaryLine(
                  'Attendance change',
                  '${signedNumber(attendanceChange)} percentage points',
                ),
                _summaryLine(
                  'Late-arrival reduction',
                  signedNumber(lateReduction),
                ),
                _summaryLine(
                  'Transport-absence reduction',
                  signedNumber(transportReduction),
                ),
                const Divider(height: 23),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 17,
                      color: textSecondary,
                    ),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'These are descriptive PRE/POST comparisons and should not by themselves be interpreted as proof that the intervention caused the observed changes.',
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // TRAVEL PROBLEMS
          // ====================================================

          sectionHeader(
            title: 'Travel Problems',
            subtitle: 'Student-reported travel difficulties',
            icon: Icons.warning_amber_rounded,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Frequently Reported Problem',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  mostCommonProblem,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mostCommonProblemCount == 0
                      ? 'No categorized travel problem data yet.'
                      : '$mostCommonProblemCount report(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push('/admin/travel-problems');
                    },
                    icon: const Icon(
                      Icons.visibility_outlined,
                    ),
                    label: const Text(
                      'View Travel Problem Reports',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // PRE POST DATA
          // ====================================================

          sectionHeader(
            title: 'Research Data',
            subtitle: 'Manage participant PRE/POST records',
            icon: Icons.science_rounded,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EEFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFDCD8FF),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participants == 0
                      ? 'No complete PRE/POST participant records yet.'
                      : '$participants participant(s) included in the paired attendance summary.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await context.push('/admin/research-data');

                      if (!mounted) return;

                      setState(() {
                        loading = true;
                        error = null;
                      });

                      await load();
                    },
                    icon: const Icon(Icons.edit_note_rounded),
                    label: const Text(
                      'Manage PRE/POST Research Data',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // TRANSPORT MANAGEMENT
          // ====================================================

          sectionHeader(
            title: 'Transport Management',
            subtitle: 'Maintain routes, stops, buses and schedules',
            icon: Icons.directions_bus_rounded,
          ),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: [
              managementTile(
                title: 'Routes',
                icon: Icons.route_rounded,
                color: primary,
                lightColor: const Color(0xFFEDE9FE),
                onTap: () {
                  context.push('/admin/routes');
                },
              ),
              managementTile(
                title: 'Bus Stops',
                icon: Icons.location_on_rounded,
                color: const Color(0xFFE27B00),
                lightColor: const Color(0xFFFFF2DF),
                onTap: () {
                  context.push('/admin/stops');
                },
              ),
              managementTile(
                title: 'Buses',
                icon: Icons.directions_bus_rounded,
                color: const Color(0xFF2563EB),
                lightColor: const Color(0xFFEAF2FF),
                onTap: () {
                  context.push('/admin/buses');
                },
              ),
              managementTile(
                title: 'Schedules',
                icon: Icons.calendar_month_rounded,
                color: const Color(0xFF159447),
                lightColor: const Color(0xFFE9F8EF),
                onTap: () {
                  context.push('/admin/schedules');
                },
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ====================================================
          // EXPORT
          // ====================================================

          sectionHeader(
            title: 'Data Export',
            subtitle: 'Export anonymized research information',
            icon: Icons.file_download_rounded,
          ),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: primary,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'The research export uses participant codes and should not include names, phone numbers, email addresses or precise location information.',
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: exportCsv,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text(
                      'Export Anonymized CSV',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY LINE
  // ============================================================

  Widget _summaryLine(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                color: textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
