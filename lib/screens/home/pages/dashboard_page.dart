import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

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
  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 65, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeader(currentDate),
          const SizedBox(height: 30),
          _buildStatusCard(),
          const SizedBox(height: 25),
          _buildShiftProgressBar(), 
          const SizedBox(height: 25),
          _buildHoursSummaryCard(), 
          const SizedBox(height: 25),
          _buildWeeklyBreakdown(),
          const SizedBox(height: 25),
          Text(
            "Last synced with Dahua Device: Just now",
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String date) {
    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Welcome, Juan!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              Text(date, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
        const Icon(Icons.wb_sunny_rounded, color: Colors.orange, size: 28),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: widget.isActive ? AppTheme.teal : AppTheme.danger,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (widget.isActive ? AppTheme.teal : AppTheme.danger).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.isActive ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isActive ? widget.selectedSite : 'Disconnected from Device',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isActive ? "Logged in via Dahua Terminal" : "Awaiting login from Dahua Device...",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftProgressBar() {
    // 1. Mapping Clock Times Logic
    // These reflect the 'Total Hours Worked' and 'Over time' fields in your logs
    double workedHours = widget.isActive ? 9.5 : 0.0; 
    double standardShift = 8.0;
    
    // 2. Overtime Calculation
    double overtimeHours = workedHours > standardShift ? workedHours - standardShift : 0.0;
    
    // 3. UI Progress Logic
    double progress = (workedHours / standardShift).clamp(0.0, 1.0);
    bool hasOvertime = overtimeHours > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasOvertime ? "Overtime Active" : "Daily Shift Progress", 
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: hasOvertime ? Colors.deepOrange : Colors.black,
                )
              ),
              Text(
                widget.isActive ? "${workedHours.toStringAsFixed(1)}h / 8h" : "0h / 8h",
                style: TextStyle(
                  fontSize: 12, 
                  color: hasOvertime ? Colors.deepOrange : (widget.isActive ? AppTheme.teal : Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              color: hasOvertime ? Colors.deepOrange : AppTheme.teal,
              minHeight: 10,
            ),
          ),
          if (hasOvertime)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "+${overtimeHours.toStringAsFixed(1)}h Overtime recorded in logs", 
                style: const TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.w600)
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHoursSummaryCard() {
    // Logic: Displays 0h if there are no logs for the day or week
    String todayDisplay = widget.isActive ? "9h 30m" : "0h";
    String weeklyTotalDisplay = widget.isActive ? "32h 25m" : "0h";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildHourCol("Hours Today", todayDisplay),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildHourCol("Weekly Total", weeklyTotalDisplay),
        ],
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Distribution (Hours)", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final days = ['M', 'T', 'W', 'T', 'F'];
              // Bars drop to a blueprint state (4.0 height) when inactive
              double height = widget.isActive ? [35.0, 55.0, 45.0, 75.0, 15.0][index] : 4.0;
              
              return Column(
                children: [
                  Text(
                    widget.isActive ? "${(height / 10).toStringAsFixed(1)}h" : "-",
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 28,
                    height: height,
                    decoration: BoxDecoration(
                      color: widget.isActive ? AppTheme.teal.withOpacity(0.7) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 55, height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(image: AssetImage('assets/images/avatar.png'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildHourCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}