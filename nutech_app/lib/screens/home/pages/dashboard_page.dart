import 'package:flutter/material.dart';

import '../../../models/activity.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/activity_card.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/nutech_text_field.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _active = false;

  final _activities = const [
    Activity(site: 'Site A', date: '02/25/2026', timeIn: '9:05 AM', timeOut: '5:10 PM'),
    Activity(site: 'Site A', date: '02/24/2026', timeIn: '8:00 AM', timeOut: '5:05 PM'),
    Activity(site: 'Site A', date: '02/23/2026', timeIn: '8:03 AM', timeOut: '5:07 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: const AssetImage('assets/images/avatar.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Welcome, Juan!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: _active ? AppTheme.teal : AppTheme.danger,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _active ? 'Active at Site A' : 'Inactive',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Hours Today', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          _active ? '8h 15m' : '0h',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 64, color: AppTheme.teal),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Hours This Week', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(
                          _active ? '40h 40m' : '32h 25m',
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          PrimaryButton(
            label: _active ? 'End Shift/Clock Out' : 'Start Shift/ Clock In',
            isDanger: _active,
            onPressed: () => setState(() => _active = !_active),
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              const Text('Recent Activities', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),

          for (final a in _activities) ...[
            ActivityCard(
              activity: a,
              onRequestAdjustment: () => _openRequestDialog(context, a),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _openRequestDialog(BuildContext context, Activity activity) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.teal, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Request Manual\nAdjustment',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),

                  const Text('Reason for Adjustment', style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const NutechTextField(hint: 'Enter your reason'),

                  const SizedBox(height: 14),
                  const NutechTextField(
                    hint: 'Date',
                    readOnly: true,
                    suffix: Padding(
                      padding: EdgeInsets.all(12),
                      child: Image(
                        image: AssetImage('assets/icons/calendar.png'),
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),
                  const NutechTextField(
                    hint: 'Correct Time',
                    readOnly: true,
                    suffix: Icon(Icons.access_time_rounded),
                  ),

                  const SizedBox(height: 14),
                  const Text('Additional Notes', style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      maxLines: 4,
                      decoration: InputDecoration(hintText: ''),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Cancel',
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Submit Request'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
