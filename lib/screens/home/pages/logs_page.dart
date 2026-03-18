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

  // Updated to return Future<void> for the RefreshIndicator
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

  Color _statusColorFromEntries(List<AttendanceLogEntry> entries) {
    final statuses = entries.map((e) => e.status.toLowerCase()).toList();

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
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.teal,
      edgeOffset: 50, // Adjusts where the spinner appears
      child: FutureBuilder<List<AttendanceLogEntry>>(
        future: _futureLogs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
            // physics ensures pull-to-refresh works even when content is small
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
                // Removed the Refresh Button from this Row
                const Text(
                  'Recent History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (sortedLogs.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 80,
                          color: AppTheme.muted.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No attendance logs found yet.',
                          style: TextStyle(
                            color: AppTheme.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  )
                else
                  ...sortedLogs.take(8).map(
                        (log) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecentLogCard(
                            entry: log,
                            statusColor: _statusColorFromEntries([log]),
                            statusLabel: _prettyStatus(log.status),
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
                const SizedBox(height: 4),
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
  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}