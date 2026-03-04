import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class LogsSpecificPage extends StatelessWidget {
  const LogsSpecificPage({super.key, required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ATTENDANCE', style: Theme.of(context).textTheme.headlineMedium),
            Text('DETAILS', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),

            _TopRow(dayLabel: 'TUE\n${day.toString().padLeft(2, '0')}', title: 'Late', time: '9:30 AM - 5:05 PM'),
            const SizedBox(height: 14),

            _Section(
              title: 'CLOCK IN / CLOCK OUT TIMES',
              child: Column(
                children: const [
                  _TimeCard(label: 'Clock In', device: 'Dahua', time: '9:30 AM'),
                  SizedBox(height: 10),
                  _TimeCard(label: 'Clock Out', device: 'Dahua', time: '6:05 PM'),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const _Section(
              title: 'TIMING SUMMARY',
              child: Column(
                children: [
                  _SummaryRow(left: 'Total Hours Worked:', right: '8 hours and 45 min'),
                  SizedBox(height: 6),
                  _SummaryRow(left: 'Over time:', right: '1 hour and 5 min'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.dayLabel, required this.title, required this.time});

  final String dayLabel;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(time),
              ],
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: Color(0xFFE39B26), shape: BoxShape.circle),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const Divider(height: 18),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
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
        Expanded(child: Text(left, style: const TextStyle(color: AppTheme.muted))),
        Text(right, style: const TextStyle(color: AppTheme.muted)),
      ],
    );
  }
}
