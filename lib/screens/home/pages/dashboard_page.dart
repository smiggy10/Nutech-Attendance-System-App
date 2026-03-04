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
    this.userName, // ✅ Removed the default "Juan" here
  });

  final VoidCallback onStartShift;
  final bool isActive;
  final String selectedSite;
  final VoidCallback onClockOut;
  final String? userName; // ✅ Made nullable to detect if a user is missing

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
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
          const SizedBox(height: 30),
          Text(
            "Last synced with Dahua Device: Just now",
            style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String date) {
    // ✅ Logic: If userName is null or empty, show "Guest" or "User"
    final String displayName = (widget.userName == null || widget.userName!.isEmpty) 
        ? "Guest" 
        : widget.userName!;

    return Row(
      children: [
        _buildAvatar(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $displayName!', 
                style: const TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                )
              ),
              Text(
                date, 
                style: TextStyle(
                  fontSize: 14, 
                  color: Colors.grey[600], 
                  fontWeight: FontWeight.w500
                )
              ),
            ],
          ),
        ),
        const Icon(Icons.wb_sunny_rounded, color: Colors.orangeAccent, size: 28),
      ],
    );
  }

  // --- UI Components remain as per your mockup ---

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: widget.isActive ? AppTheme.teal : const Color(0xFF7A2821), 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.isActive ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 13, 
              letterSpacing: 2.0, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isActive ? widget.selectedSite : 'Disconnected from Device',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.w900
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.isActive ? "Logged in via Dahua Terminal" : "Awaiting login from Dahua Device...",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftProgressBar() {
    double workedHours = widget.isActive ? 9.5 : 0.0; 
    double standardShift = 8.0;
    double progress = (workedHours / standardShift).clamp(0.0, 1.0);
    bool hasOvertime = workedHours > standardShift;

    return Container(
      padding: const EdgeInsets.all(20),
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
                "Daily Shift Progress", 
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])
              ),
              Text(
                "${workedHours.toStringAsFixed(1)}h / 8h",
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              color: hasOvertime ? Colors.deepOrange : AppTheme.teal,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSummaryCard() {
    String todayDisplay = widget.isActive ? "9h 30m" : "0h";
    String weeklyTotalDisplay = widget.isActive ? "32h 25m" : "0h";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          _buildHourCol("Hours Today", todayDisplay),
          Container(width: 1, height: 45, color: Colors.grey[100]),
          _buildHourCol("Weekly Total", weeklyTotalDisplay),
        ],
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Distribution (Hours)", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final days = ['M', 'T', 'W', 'T', 'F'];
              double height = widget.isActive ? [35.0, 55.0, 45.0, 75.0, 15.0][index] : 4.0;
              
              return Column(
                children: [
                  Text(
                    widget.isActive ? "${(height / 10).toStringAsFixed(1)}h" : "-",
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 32,
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
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
        image: const DecorationImage(
          image: AssetImage('assets/images/avatar.png'), 
          fit: BoxFit.cover
        ),
      ),
    );
  }

  Widget _buildHourCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black45, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}