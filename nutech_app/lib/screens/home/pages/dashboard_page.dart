import 'package:flutter/material.dart';

import '../../../models/activity.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/activity_card.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/nutech_text_field.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onStartShift,
    required this.isActive,
    required this.selectedSite,
    required this.onClockOut,
  });

  final VoidCallback onStartShift;
  final bool isActive;
  final String selectedSite;
  final VoidCallback onClockOut;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Logic for the Clock Out Dialog
  void _showClockOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Clock Out', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to end your shift?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onClockOut();
            },
            child: const Text('End Shift', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- NEW: DATE & TIME PICKER LOGIC FOR DIALOG ---

  Future<void> _openRequestDialog(BuildContext context, Activity activity) async {
    final dateController = TextEditingController(text: activity.date);
    final timeController = TextEditingController(text: activity.timeIn);
    final reasonController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        // StatefulBuilder allows the dialog to update when we pick a date/time
        return StatefulBuilder(builder: (context, setDialogState) {
          
          Future<void> pickDate() async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setDialogState(() {
                final mm = picked.month.toString().padLeft(2, '0');
                final dd = picked.day.toString().padLeft(2, '0');
                final yy = picked.year.toString();
                dateController.text = '$mm/$dd/$yy';
              });
            }
          }

          Future<void> pickTime() async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              setDialogState(() {
                timeController.text = picked.format(context);
              });
            }
          }

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
                    const Text('Request Manual\nAdjustment',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 18),
                    const Text('Reason for Adjustment',
                        style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    NutechTextField(controller: reasonController, hint: 'Enter your reason'),
                    const SizedBox(height: 14),
                    
                    // Date Field with Calendar Picker
                    NutechTextField(
                      controller: dateController,
                      hint: 'Date',
                      readOnly: true,
                      onTap: pickDate,
                      suffix: IconButton(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.teal),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    // Time Field with Clock Picker
                    NutechTextField(
                      controller: timeController,
                      hint: 'Correct Time',
                      readOnly: true,
                      onTap: pickTime,
                      suffix: IconButton(
                        onPressed: pickTime,
                        icon: const Icon(Icons.access_time_rounded, color: AppTheme.teal),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
                    const Text('Additional Notes',
                        style: TextStyle(color: AppTheme.teal, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Add more details...',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: SecondaryButton(label: 'Cancel', onPressed: () => Navigator.pop(ctx))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Submit Request',
                            onPressed: () {
                              // Handle logic here
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = const [
      Activity(site: 'Site A', date: '02/25/2026', timeIn: '9:05 AM', timeOut: '5:10 PM'),
      Activity(site: 'Site A', date: '02/24/2026', timeIn: '8:00 AM', timeOut: '5:05 PM'),
      Activity(site: 'Site A', date: '02/23/2026', timeIn: '8:03 AM', timeOut: '5:07 PM'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 55, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/ui/avatar.png'),
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Welcome, Juan!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive ? AppTheme.teal : AppTheme.danger,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.isActive ? 'Active at ${widget.selectedSite}' : 'Inactive',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 18),

          // Hours Card
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
                        Text(widget.isActive ? '0h 01m' : '0h',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 64, color: AppTheme.teal),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Hours This Week', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Text(widget.isActive ? '32h 26m' : '32h 25m',
                            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Action Button
          PrimaryButton(
            label: widget.isActive ? 'End Shift/Clock Out' : 'Start Shift/ Clock In',
            isDanger: widget.isActive,
            onPressed: () => widget.isActive ? _showClockOutDialog(context) : widget.onStartShift(),
          ),

          const SizedBox(height: 18),
          const Text('Recent Activities',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),

          for (final a in activities) ...[
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
}