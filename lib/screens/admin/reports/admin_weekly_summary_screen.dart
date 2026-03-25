import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutech_app/services/adminn8n.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

import 'admin_weekly_summary_detail_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AdminWeeklySummaryScreen extends StatefulWidget {
  const AdminWeeklySummaryScreen({super.key});

  static const route = '/admin/weekly-summary';

  @override
  State<AdminWeeklySummaryScreen> createState() =>
      _AdminWeeklySummaryScreenState();
}

class _AdminWeeklySummaryScreenState extends State<AdminWeeklySummaryScreen> {
  /// Default: last 7 calendar days ending today.
  static DateTimeRange _defaultRange() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }

  DateTimeRange _selectedRange = _defaultRange();

  late Future<AdminWeeklySummaryData> _weeklyData;
  AdminWeeklySummaryData? _lastLoadedReport;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _weeklyData = _fetchWeeklySummary();
  }

  Future<AdminWeeklySummaryData> _fetchWeeklySummary() async {
    final report = await AdminN8n.getWeeklySummary(
      start: _selectedRange.start,
      end: _selectedRange.end,
    );
    _lastLoadedReport = report;
    return report;
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.teal,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
        _weeklyData = _fetchWeeklySummary();
      });
    }
  }

  /// Opens detail: Total→roster, Present→presentEntries, Late→lateEntries, Absent→absentEntries.
  void _openWeeklyDetail(
    BuildContext context,
    AdminWeeklySummaryData data,
    String periodLabel,
    WeeklySummaryDetailKind kind,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminWeeklySummaryDetailScreen(
          kind: kind,
          periodLabel: periodLabel,
          data: data,
        ),
      ),
    );
  }

  Future<void> _exportReport() async {
    final report = _lastLoadedReport;

    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary data to export yet.')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final csvRows = <List<dynamic>>[
        ['Weekly Summary Report'],
        ['Start', report.start],
        ['End', report.end],
        ['Total Employees', report.totalEmployees],
        ['Present', report.presentCount],
        ['Late', report.lateCount],
        ['Absent', report.absentCount],
        ['Total attendance logs', report.totalAttendanceLogs],
        ['Total hours worked', report.totalHoursWorked],
        ['Total overtime hours', report.totalOvertimeHours],
        ['Missing time-out logs', report.missingTimeOutLogs],
        [],
        ['Metric', 'Value'],
        ...report.displaySummaryRows.map((row) => [row.left, row.right]),
      ];

      final csvText = csv.encode(csvRows);
      final dir = await getTemporaryDirectory();
      final fileName = 'weekly_summary_${report.start}_to_${report.end}.csv';
      final file = File('${dir.path}/$fileName');

      await file.writeAsString(csvText);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'Weekly Summary Report - ${report.start} to ${report.end}',
          text: 'Weekly Summary Report - ${report.start} to ${report.end}',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to export CSV: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d');
    final yf = DateFormat('yyyy');
    final rangeText =
        "${df.format(_selectedRange.start)} - ${df.format(_selectedRange.end)}, ${yf.format(_selectedRange.end)}";

    return Scaffold(
      body: NutechBackground(
        bottomAsset: 'assets/images/ui/bottombackground2.png',
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.teal,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (_isExporting)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppTheme.teal,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.file_download_outlined),
                        color: AppTheme.teal,
                        onPressed: _exportReport,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: Image.asset(
                              'assets/images/branding/nutechlogo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _FilterCard(
                              text: 'Period: $rangeText',
                              actionText: 'Change',
                              onTap: () => _selectDateRange(context),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<AdminWeeklySummaryData>(
                              future: _weeklyData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 50),
                                    child: CircularProgressIndicator(
                                      color: AppTheme.teal,
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildStatsRow(
                                        context: context,
                                        periodLabel: rangeText,
                                        data: null,
                                        total: '—',
                                        p: '—',
                                        l: '—',
                                        a: '—',
                                      ),
                                      const SizedBox(height: 14),
                                      _buildStatusMessage(
                                        'Could not load summary.\n${snapshot.error}',
                                      ),
                                    ],
                                  );
                                }

                                final data = snapshot.data;
                                if (data == null) {
                                  return _buildStatusMessage(
                                    'No data returned for this range.',
                                  );
                                }

                                final emptyRange = !data.hasMeaningfulData;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildStatsRow(
                                      context: context,
                                      periodLabel: rangeText,
                                      data: data,
                                      total: data.totalEmployees.toString(),
                                      p: data.presentCount.toString(),
                                      l: data.lateCount.toString(),
                                      a: data.absentCount.toString(),
                                    ),
                                    const SizedBox(height: 14),
                                    _buildSectionDivider('Period summary'),
                                    const SizedBox(height: 10),
                                    _TotalsCard(rows: data.displaySummaryRows),
                                    if (emptyRange) ...[
                                      const SizedBox(height: 16),
                                      _buildInfoBanner(
                                        'No attendance in this date range, or your n8n workflow is not returning counts. '
                                        'The workflow for GET /webhook/admin/weekly-summary must aggregate from your database for the selected start/end dates (see docs/n8n_summary_report_prompt.md).',
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
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
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              'Weekly Summary Report',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        ),
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildInfoBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Colors.brown.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String message) {
    return _TableCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required BuildContext context,
    required String periodLabel,
    required AdminWeeklySummaryData? data,
    required String total,
    required String p,
    required String l,
    required String a,
  }) {
    final d = data;
    void open(WeeklySummaryDetailKind kind) {
      if (d == null) return;
      _openWeeklyDetail(context, d, periodLabel, kind);
    }

    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            label: 'Total\nEmployees',
            value: total,
            color: const Color(0xFF1FA651),
            onTap: d == null
                ? null
                : () => open(WeeklySummaryDetailKind.totalEmployees),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            label: 'Present',
            value: p,
            color: const Color(0xFF148A8F),
            onTap: d == null
                ? null
                : () => open(WeeklySummaryDetailKind.present),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            label: 'Late',
            value: l,
            color: const Color(0xFFE74C3C),
            onTap: d == null ? null : () => open(WeeklySummaryDetailKind.late),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MiniStatCard(
            label: 'Absent',
            value: a,
            color: const Color(0xFFF39C12),
            onTap: d == null
                ? null
                : () => open(WeeklySummaryDetailKind.absent),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1),
        ),
      ],
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.text,
    required this.actionText,
    required this.onTap,
  });

  final String text;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.tealSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    final card = Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              height: 1.1,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: Colors.white.withOpacity(0.25),
        highlightColor: Colors.white.withOpacity(0.12),
        child: card,
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.rows});

  final List<AdminWeeklySummaryRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(rows[i].left)),
                  Text(
                    rows[i].right,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1)
              Divider(height: 1, color: Colors.black.withOpacity(0.12)),
          ],
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black.withOpacity(0.12)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}
