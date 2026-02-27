import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../theme/app_theme.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    this.onRequestAdjustment,
  });

  final Activity activity;
  final VoidCallback? onRequestAdjustment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${activity.site} - ${activity.date}',
                    style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('Time In: ${activity.timeIn}', style: const TextStyle(color: AppTheme.muted)),
                  Text('Time Out: ${activity.timeOut}', style: const TextStyle(color: AppTheme.muted)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 34,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  elevation: 0,
                  backgroundColor: AppTheme.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: onRequestAdjustment,
                child: const Text(
                  'Request Adjustment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
