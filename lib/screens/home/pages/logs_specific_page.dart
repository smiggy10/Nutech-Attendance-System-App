import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/nutech_background.dart';

class LogsSpecificPage extends StatelessWidget {
  const LogsSpecificPage({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final String dayName = DateFormat('EEE').format(date).toUpperCase();
    final String dayNumber = DateFormat('dd').format(date);
    final String fullMonthYear = DateFormat('MMMM yyyy').format(date);

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
                      const Text('ATTENDANCE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      const Text('DETAILS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                      Text(
                        fullMonthYear,
                        style: const TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 22),

                      _TopRow(
                        dayLabel: '$dayName\n$dayNumber',
                        title: 'Log Details',
                        time: 'Shift Record',
                        dotColor: AppTheme.teal,
                      ),
                      const SizedBox(height: 16),

                      _Section(
                        title: 'CLOCK IN / CLOCK OUT TIMES',
                        child: Column(
                          children: [
                            _TimeCard(label: 'Clock In', device: '---', time: '--:--'),
                            const SizedBox(height: 12),
                            _TimeCard(label: 'Clock Out', device: '---', time: '--:--'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),
                      _Section(
                        title: 'TIMING SUMMARY',
                        child: Column(
                          children: const [
                            _SummaryRow(left: 'Total Hours Worked:', right: '0h 0m'),
                            Divider(height: 24),
                            _SummaryRow(left: 'Over time:', right: '0h 0m'),
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

class _TopRow extends StatelessWidget {
  const _TopRow({required this.dayLabel, required this.title, required this.time, required this.dotColor});
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
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Text(dayLabel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                Text(time, style: const TextStyle(color: AppTheme.muted)),
              ],
            ),
          ),
          Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.ink)),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.device, required this.time});
  final String label;
  final String device;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border.withOpacity(0.5))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: Color(0xFFF3F4F6), shape: BoxShape.circle),
            child: const Icon(Icons.watch_later_outlined, size: 18, color: AppTheme.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text('Device: $device', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w900)),
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
        Expanded(child: Text(left, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w500))),
        Text(right, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.ink)),
      ],
    );
  }
}