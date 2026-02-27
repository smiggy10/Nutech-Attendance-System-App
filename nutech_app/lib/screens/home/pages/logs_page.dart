import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'logs_specific_page.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  int _monthOffset = 0; // 0 = October in mock

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ATTENDANCE', style: Theme.of(context).textTheme.headlineMedium),
          Text('LOGS', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 14),

          _MonthCard(
            monthName: 'October',
            subtitle: 'Monthly',
            onPrev: () => setState(() => _monthOffset--),
            onNext: () => setState(() => _monthOffset++),
            onTapDay: (day) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LogsSpecificPage(day: day)),
              );
            },
          ),

          const SizedBox(height: 14),
          _LogRow(
            dayLabel: 'TUE\n30',
            title: 'Late',
            timeRange: '9:30 AM - 6:05 PM',
            dotColor: const Color(0xFFE39B26),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsSpecificPage(day: 30))),
          ),
          const SizedBox(height: 12),
          _LogRow(
            dayLabel: 'MON\n29',
            title: 'Late',
            timeRange: '9:20 AM - 5:07 PM',
            dotColor: const Color(0xFFE39B26),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogsSpecificPage(day: 29))),
          ),
        ],
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.monthName,
    required this.subtitle,
    required this.onPrev,
    required this.onNext,
    required this.onTapDay,
  });

  final String monthName;
  final String subtitle;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onTapDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(monthName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(subtitle, style: const TextStyle(color: AppTheme.muted)),
                  ],
                ),
              ),
              _NavButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
              const SizedBox(width: 10),
              _NavButton(icon: Icons.chevron_right_rounded, onTap: onNext),
            ],
          ),
          const SizedBox(height: 10),

          // Week header
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeekLabel('Sat'),
              _WeekLabel('Sun'),
              _WeekLabel('Mon'),
              _WeekLabel('Tue'),
              _WeekLabel('Wed'),
              _WeekLabel('Thu'),
              _WeekLabel('Fri'),
            ],
          ),
          const SizedBox(height: 8),

          // Simple 5x7 grid (mocked)
          _CalendarGrid(onTapDay: onTapDay),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.teal,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _WeekLabel extends StatelessWidget {
  const _WeekLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({required this.onTapDay});

  final ValueChanged<int> onTapDay;

  @override
  Widget build(BuildContext context) {
    // This is a lightweight visual approximation of your mock.
    // If you want a real calendar later, we can swap this with table_calendar.
    const days = [
      28, 29, 30, 1, 2, 3, 4,
      5, 6, 7, 8, 9, 10, 11,
      12, 13, 14, 15, 16, 17, 18,
      19, 20, 21, 22, 23, 24, 25,
      27, 28, 29, 30, 31, 1, 2,
    ];

    // Dots: green=ok, orange=late, blue=holiday/other, red=absent
    const dotMap = {
      1: Color(0xFF52B788),
      2: Color(0xFF52B788),
      3: Color(0xFFE39B26),
      4: Color(0xFFE39B26),
      5: Color(0xFF52B788),
      6: Color(0xFF52B788),
      8: Color(0xFF52B788),
      9: Color(0xFF52B788),
      10: Color(0xFFE39B26),
      11: Color(0xFFE39B26),
      15: Color(0xFFD64545),
      16: Color(0xFF2D6CDF),
      17: Color(0xFF2D6CDF),
      25: Color(0xFFD64545),
      27: Color(0xFF2D6CDF),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(days.length, (i) {
        final day = days[i];
        final dot = dotMap[day];
        final isMuted = (i < 3) || (i > 31); // fake prev/next month

        return InkWell(
          onTap: isMuted ? null : () => onTapDay(day),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isMuted ? const Color(0xFFF2F4F6) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isMuted ? const Color(0xFFB8C0C7) : AppTheme.ink,
                    ),
                  ),
                ),
                if (dot != null)
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({
    required this.dayLabel,
    required this.title,
    required this.timeRange,
    required this.dotColor,
    required this.onTap,
  });

  final String dayLabel;
  final String title;
  final String timeRange;
  final Color dotColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(dayLabel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(timeRange, style: const TextStyle(color: AppTheme.ink)),
                ],
              ),
            ),
            Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}
