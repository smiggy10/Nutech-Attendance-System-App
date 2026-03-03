import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../theme/app_theme.dart';
import 'logs_specific_page.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final List<dynamic> _realLogs = []; 
  final Map<DateTime, Color> _events = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ATTENDANCE', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          Text('LOGS', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: TableCalendar(
              firstDay: DateTime(2026, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              
              // FIXED SIZE SETTINGS
              rowHeight: 52, 
              daysOfWeekHeight: 25,
              // This is the key fix: Forces 6 rows every time
              sixWeekMonthsEnforced: true, 
              
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },

              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LogsSpecificPage(date: selectedDay),
                  ),
                );
              },
              
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dayToCheck = DateTime(date.year, date.month, date.day);
                  final statusColor = _events[dayToCheck];
                  
                  if (statusColor != null) {
                    return Positioned(
                      bottom: 6,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
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
          const Text('Recent History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          if (_realLogs.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.history_toggle_off_rounded, size: 80, color: AppTheme.muted.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  const Text(
                    'No attendance logs found yet.', 
                    style: TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            )
          else
            ..._realLogs.map((log) => const Text("Log Item")), 
        ],
      ),
    );
  }
}