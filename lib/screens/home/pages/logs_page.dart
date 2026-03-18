import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../services/attendance_logs_service.dart';
import '../../../theme/app_theme.dart';
import 'logs_specific_page.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late Future<List<AttendanceLogEntry>> _futureLogs;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _futureLogs = AttendanceLogsService.fetchCurrentUserLogs();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _futureLogs = AttendanceLogsService.fetchCurrentUserLogs();
    });
    await _futureLogs;
  }

  DateTime _dayKey(DateTime date) => DateTime(date.year, date.month, date.day);

  Map<DateTime, List<AttendanceLogEntry>> _groupByDay(
    List<AttendanceLogEntry> logs,
  ) {
    final map = <DateTime, List<AttendanceLogEntry>>{};
    for (final log in logs) {
      final key = log.dayKey;
      map.putIfAbsent(key, () => []);
      map[key]!.add(log);
    }
    return map;
  }

  /// Helper to calculate the difference in hours
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

  /// New Helper to check specific time thresholds (e.g., 8:15 AM)
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

  Color _statusColorFromEntries(List<AttendanceLogEntry> entries) {
    if (entries.isEmpty) return Colors.transparent;
    final lastEntry = entries.last;
    
    // Logic for Absent: No logs and it's after 5:00 PM
    final now = DateTime.now();
    bool isPast5PM = now.hour >= 17;
    bool isToday = isSameDay(lastEntry.date, now);

    if (lastEntry.status.toLowerCase().contains('absent') || 
       (isToday && isPast5PM && lastEntry.clockIn.isEmpty)) {
      return Colors.red;
    }

    // Logic for Late: Clocked in after 8:15 AM
    if (_isAfterTime(lastEntry.clockIn, 8, 15)) {
      return Colors.orange;
    }

    // Logic for On-Time/Complete: Clocked in <= 8:15, has clock out, and worked 8+ hours
    double hours = _calculateHours(lastEntry);
    if (lastEntry.clockIn.isNotEmpty && lastEntry.clockOut.isNotEmpty && hours >= 8) {
      return Colors.green;
    }

    // Logic for On-Going/On-Time: Clocked in but no clock out yet
    return Colors.deepPurple;
  }

  String _prettyStatus(AttendanceLogEntry entry) {
    final now = DateTime.now();
    bool isPast5PM = now.hour >= 17;
    bool isToday = isSameDay(entry.date, now);

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

    if (entry.clockIn.isNotEmpty && entry.clockOut.isEmpty) {
      return 'On-Going/On-Time';
    }

    return entry.status.isEmpty ? 'On-Going/On-Time' : entry.status;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.teal,
      edgeOffset: 50,
      child: FutureBuilder<List<AttendanceLogEntry>>(
        future: _futureLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              error: snapshot.error.toString(),
              onRetry: _handleRefresh,
            );
          }

          final logs = snapshot.data ?? [];
          final grouped = _groupByDay(logs);
          final sortedLogs = [...logs];

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATTENDANCE',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  'LOGS',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2020, 1, 1),
                    lastDay: DateTime(2035, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    rowHeight: 52,
                    daysOfWeekHeight: 25,
                    sixWeekMonthsEnforced: true,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      final key = _dayKey(selectedDay);
                      final selectedEntries = grouped[key] ?? [];

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LogsSpecificPage(
                            date: selectedDay,
                            entries: selectedEntries,
                          ),
                        ),
                      );
                    },
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final key = _dayKey(date);
                        final entries = grouped[key];

                        if (entries == null || entries.isEmpty) {
                          return null;
                        }

                        final color = _statusColorFromEntries(entries);

                        return Positioned(
                          bottom: 6,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    calendarStyle: const CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppTheme.teal,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: AppTheme.ink,
                        shape: BoxShape.circle,
                      ),
                      outsideDaysVisible: true,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Recent History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (sortedLogs.isEmpty)
                  const Center(child: Text("No attendance logs found yet."))
                else
                  ...sortedLogs.take(8).map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecentLogCard(
                            entry: log,
                            statusColor: _statusColorFromEntries([log]),
                            statusLabel: _prettyStatus(log),
                            onTap: () {
                              final key = _dayKey(log.date);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LogsSpecificPage(
                                    date: log.date,
                                    entries: grouped[key] ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecentLogCard extends StatelessWidget {
  const _RecentLogCard({
    required this.entry,
    required this.statusColor,
    required this.statusLabel,
    required this.onTap,
  });

  final AttendanceLogEntry entry;
  final Color statusColor;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM dd, yyyy').format(entry.date);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clock In: ${entry.clockIn.isEmpty ? '---' : entry.clockIn}',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                  Text(
                    'Clock Out: ${entry.clockOut.isEmpty ? '---' : entry.clockOut}',
                    style: const TextStyle(color: AppTheme.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          Text(error),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}