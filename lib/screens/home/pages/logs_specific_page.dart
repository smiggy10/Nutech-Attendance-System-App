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

  /// Logic helper to check time thresholds
  bool _isAfterTime(String timeStr, int hour, int minute) {
    if (timeStr.isEmpty) return false;
    try {
      final DateFormat format = DateFormat("hh:mm a");
      final DateTime time = format.parse(timeStr);
      if (time.hour > hour) return true;
      if (time.hour == hour && time.minute > minute) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Calculates hours from an entry for status logic
  double _calculateHours(AttendanceLogEntry entry) {
    if (entry.clockIn.isEmpty || entry.clockOut.isEmpty) return 0.0;
    try {
      final DateFormat format = DateFormat("hh:mm a");
      final DateTime inTime = format.parse(entry.clockIn);
      final DateTime outTime = format.parse(entry.clockOut);
      return outTime.difference(inTime).inMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  Color _statusColorFromEntries(List<AttendanceLogEntry> items) {
    if (items.isEmpty) return Colors.transparent;
    final lastEntry = items.last;
    final now = DateTime.now();
    bool isPast5PM = now.hour >= 17;
    bool isToday = DateUtils.isSameDay(lastEntry.date, now);

    // Absent: Red
    if (lastEntry.status.toLowerCase().contains('absent') ||
        (isToday && isPast5PM && lastEntry.clockIn.isEmpty)) {
      return Colors.red;
    }

    // Late: Orange
    if (_isAfterTime(lastEntry.clockIn, 8, 15)) {
      return Colors.orange;
    }

    // Complete: Green
    double hours = _calculateHours(lastEntry);
    if (lastEntry.clockIn.isNotEmpty &&
        lastEntry.clockOut.isNotEmpty &&
        hours >= 8) {
      return Colors.green;
    }

    // Ongoing: Violet/DeepPurple
    return Colors.deepPurple;
  }

  String _prettyStatus(AttendanceLogEntry entry) {
    final now = DateTime.now();
    bool isPast5PM = now.hour >= 17;
    bool isToday = DateUtils.isSameDay(entry.date, now);

    if (entry.status.toLowerCase().contains('absent') ||
        (isToday && isPast5PM && entry.clockIn.isEmpty)) {
      return 'Absent';
    }

    if (_isAfterTime(entry.clockIn, 8, 15)) {
      return 'Late';
    }

    double hours = _calculateHours(entry);
    if (entry.clockIn.isNotEmpty && entry.clockOut.isNotEmpty && hours >= 8) {
      return 'On-Time/Complete';
    }

    return 'On-Going/On-Time';
  }

  @override
  Widget build(BuildContext context) {
    final String dayName = DateFormat('EEE').format(date).toUpperCase();
    final String dayNumber = DateFormat('dd').format(date);
    final String fullMonthYear = DateFormat('MMMM yyyy').format(date);

    // Calculate total hours worked for this specific date
    final totalMinutes = entries.fold<int>(0, (sum, e) => sum + e.totalMinutes);

    final topColor = entries.isEmpty
        ? AppTheme.muted
        : _statusColorFromEntries(entries);
    final topTitle = entries.isEmpty
        ? 'No Log Found'
        : _prettyStatus(entries.last);
    final topSubtitle = entries.isEmpty
        ? 'No shift record'
        : '${entries.length} shift entr${entries.length == 1 ? 'y' : 'ies'}';

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
                                    _ShiftBlock(
                                      entry: entries[i],
                                      prettyStatus: _prettyStatus(entries[i]),
                                    ),
                                    if (i != entries.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
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
                              right: AttendanceLogEntry.formatMinutes(
                                totalMinutes,
                              ),
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
  const _ShiftBlock({required this.entry, required this.prettyStatus});

  final AttendanceLogEntry entry;
  final String prettyStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entry.site.isNotEmpty ||
            entry.remarks.isNotEmpty ||
            entry.status.isNotEmpty)
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
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Status: $prettyStatus',
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
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
                Text(time, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

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
            child: const Icon(Icons.access_time_rounded, color: AppTheme.teal),
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
                Text(device, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.left, required this.right});

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
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ],
    );
  }
}
