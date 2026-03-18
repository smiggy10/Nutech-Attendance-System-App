import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../services/dashboard_service.dart';
import '../../../theme/app_theme.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.onStartShift,
    required this.isActive,
    required this.selectedSite,
    required this.onClockOut,
    this.userName,
  });

  final VoidCallback onStartShift;
  final bool isActive;
  final String selectedSite;
  final VoidCallback onClockOut;
  final String? userName;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = DashboardService.fetchDashboard(
      fallbackUserName: widget.userName,
    );
  }

  // Updated to return Future<void> for the RefreshIndicator
  Future<void> _handleRefresh() async {
    setState(() {
      _future = DashboardService.fetchDashboard(
        fallbackUserName: widget.userName,
      );
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.teal,
      edgeOffset: 80, // Offset to appear below the top padding if needed
      child: FutureBuilder<DashboardData>(
        future: _future,
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

          final data = snapshot.data;

          if (data == null) {
            return _ErrorState(
              error: 'No dashboard data returned.',
              onRetry: _handleRefresh,
            );
          }

          return SingleChildScrollView(
            // physics ensures pull-to-refresh works even when content is small
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildHeader(currentDate, data),
                const SizedBox(height: 30),
                _buildStatusCard(data),
                const SizedBox(height: 18),
                _buildTodayQuickInfo(data),
                const SizedBox(height: 25),
                _buildShiftProgressBar(data),
                const SizedBox(height: 25),
                _buildHoursSummaryCard(data),
                const SizedBox(height: 25),
                _buildWeeklyBreakdown(data),
                const SizedBox(height: 20), // Adjusted spacing after removing button
                Text(
                  "Last synced with Airtable: ${DateFormat('h:mm a').format(DateTime.now())}",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String date, DashboardData data) {
    return Row(
      children: [
        _buildAvatar(data),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${data.displayName}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.wb_sunny_rounded,
          color: Colors.orangeAccent,
          size: 28,
        ),
      ],
    );
  }

  Widget _buildStatusCard(DashboardData data) {
    final Color cardColor = data.isCurrentlyActive
        ? AppTheme.teal
        : data.todayMinutes > 0
            ? const Color(0xFF215A4A)
            : const Color(0xFF7A2821);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            data.statusLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.statusHeadline,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.statusSubtext,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayQuickInfo(DashboardData data) {
    List<String> modes = data.todayDevice.split('/');
    String inMode = modes.isNotEmpty ? modes[0].trim() : '--';
    String outMode = modes.length > 1 ? modes[1].trim() : '--';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Clock In',
                  value: data.todayClockIn.isEmpty ? '--:--' : data.todayClockIn,
                  subValue: inMode != '--' ? inMode : null,
                  icon: Icons.login_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  label: 'Clock Out',
                  value: data.todayClockOut.isEmpty ? '--:--' : data.todayClockOut,
                  subValue: outMode != '--' ? outMode : null,
                  icon: Icons.logout_rounded,
                ),
              ),
            ],
          ),
          if (data.todayCardNo.isNotEmpty || data.todayRemarks.isNotEmpty) ...[
            const SizedBox(height: 14),
            if (data.todayCardNo.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, size: 16, color: AppTheme.teal),
                    const SizedBox(width: 8),
                    Text(
                      "Card: ${data.todayCardNo}",
                      style: const TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600,
                        color: Colors.black87
                      ),
                    ),
                  ],
                ),
              ),
            if (data.todayRemarks.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 16, color: AppTheme.teal),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      data.todayRemarks,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftProgressBar(DashboardData data) {
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
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                "${(data.todayMinutes / 60.0).toStringAsFixed(1)}h / 8h",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: data.progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[100],
              color: data.hasOvertime ? Colors.deepOrange : AppTheme.teal,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursSummaryCard(DashboardData data) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          _buildHourCol("Hours Today", data.todayHoursLabel),
          Container(width: 1, height: 45, color: Colors.grey[100]),
          _buildHourCol("Weekly Total", data.weeklyHoursLabel),
        ],
      ),
    );
  }

  Widget _buildWeeklyBreakdown(DashboardData data) {
    const days = ['M', 'T', 'W', 'T', 'F'];
    final maxMinutes = data.weekdayMinutes.fold<int>(
      480,
      (current, item) => item > current ? item : current,
    );

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
          const Text(
            "Weekly Distribution (Hours)",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final minutes = data.weekdayMinutes[index];
              final hours = minutes / 60.0;
              final normalized = maxMinutes == 0 ? 0.0 : minutes / maxMinutes;
              final height = minutes == 0 ? 6.0 : 18 + (normalized * 62);

              return Column(
                children: [
                  Text(
                    minutes == 0 ? '-' : '${hours.toStringAsFixed(1)}h',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 32,
                    height: height,
                    decoration: BoxDecoration(
                      color: minutes == 0
                          ? Colors.grey[200]
                          : AppTheme.teal.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    days[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(DashboardData data) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: data.profileImageUrl.isNotEmpty
            ? Image.network(
                data.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/avatar.png',
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                'assets/images/avatar.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildHourCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black45,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    this.subValue,
    this.icon,
  });

  final String label;
  final String value;
  final String? subValue;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (icon != null) Icon(icon, size: 14, color: Colors.grey[300]),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  subValue!.toLowerCase().contains('face') 
                    ? Icons.face_retouching_natural_rounded 
                    : Icons.credit_card_rounded,
                  size: 12,
                  color: AppTheme.teal,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    subValue!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
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
              'Failed to Load Dashboard',
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