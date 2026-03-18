import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/attendance_logs_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/nutech_background.dart';

class LogsSpecificPage extends StatelessWidget {
  const LogsSpecificPage({
    super.key,
    required this.date,
    required this.entries,
  });

  final DateTime date;
  final List<AttendanceLogEntry> entries;

  Color _statusColorFromEntries(List<AttendanceLogEntry> items) {
    final statuses = items.map((e) => e.status.toLowerCase()).toList();

    if (statuses.any((s) => s.contains('absent'))) {
      return Colors.redAccent;
    }
    if (statuses.any((s) => s.contains('late'))) {
      return Colors.orange;
    }
    if (statuses.any((s) => s.contains('incomplete'))) {
      return Colors.deepPurple;
    }
    return AppTheme.teal;
  }

  String _prettyStatus(String status) {
    if (status.trim().isEmpty) return 'Present';
    final lower = status.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final String dayName = DateFormat('EEE').format(date).toUpperCase();
    final String dayNumber = DateFormat('dd').format(date);
    final String fullMonthYear = DateFormat('MMMM yyyy').format(date);

    final totalMinutes = entries.fold<int>(0, (sum, e) => sum + e.totalMinutes);
    final overtimeMinutes =
        entries.fold<int>(0, (sum, e) => sum + e.overtimeMinutes);

    final topColor =
        entries.isEmpty ? AppTheme.muted : _statusColorFromEntries(entries);
    final topTitle =
        entries.isEmpty ? 'No Log Found' : _prettyStatus(entries.first.status);
    final topSubtitle =
        entries.isEmpty ? 'No shift record' : '${entries.length} shift entr${entries.length == 1 ? 'y' : 'ies'}';

    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ATTENDANCE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'DETAILS',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        fullMonthYear,
                        style: const TextStyle(
                          color: AppTheme.teal,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _TopRow(
                        dayLabel: '$dayName\n$dayNumber',
                        title: topTitle,
                        time: topSubtitle,
                        dotColor: topColor,
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        title: 'CLOCK IN / CLOCK OUT TIMES',
                        child: entries.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text(
                                    'No attendance record for this date.',
                                    style: TextStyle(color: AppTheme.muted),
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (int i = 0; i < entries.length; i++) ...[
                                    _ShiftBlock(entry: entries[i]),
                                    if (i != entries.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 18),
                                        child: Divider(),
                                      ),
                                  ],
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      _Section(
                        title: 'TIMING SUMMARY',
                        child: Column(
                          children: [
                            _SummaryRow(
                              left: 'Total Hours Worked:',
                              right: AttendanceLogEntry.formatMinutes(totalMinutes),
                            ),
                            const Divider(height: 24),
                            _SummaryRow(
                              left: 'Over time:',
                              right: AttendanceLogEntry.formatMinutes(overtimeMinutes),
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
}

class _ShiftBlock extends StatelessWidget {
  const _ShiftBlock({required this.entry});

  final AttendanceLogEntry entry;

  String _prettyStatus(String status) {
    if (status.trim().isEmpty) return 'Present';
    final lower = status.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.site.isNotEmpty || entry.remarks.isNotEmpty || entry.status.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.site.isNotEmpty)
                Text(
                  'Site: ${entry.site}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              if (entry.status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Status: ${_prettyStatus(entry.status)}',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ),
              if (entry.remarks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Remarks: ${entry.remarks}',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        _TimeCard(
          label: 'Clock In',
          device: entry.clockInDevice.isEmpty ? '---' : entry.clockInDevice,
          time: entry.clockIn.isEmpty ? '--:--' : entry.clockIn,
        ),
        const SizedBox(height: 12),
        _TimeCard(
          label: 'Clock Out',
          device: entry.clockOutDevice.isEmpty ? '---' : entry.clockOutDevice,
          time: entry.clockOut.isEmpty ? '--:--' : entry.clockOut,
        ),
      ],
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({
    required this.dayLabel,
    required this.title,
    required this.time,
    required this.dotColor,
  });

  final String dayLabel;
  final String title;
  final String time;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              dayLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppTheme.ink,
            ),
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.device,
    required this.time,
  });

  final String label;
  final String device;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.access_time_rounded,
              color: AppTheme.teal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  device,
                  style: const TextStyle(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.left,
    required this.right,
  });

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: const TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          right,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}