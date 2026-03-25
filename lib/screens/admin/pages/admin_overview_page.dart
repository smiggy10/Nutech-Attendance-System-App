import '../../../services/adminn8n.dart';
import '../../../services/n8n_api.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'attendance_details_page.dart';
import 'admin_overview_shell.dart';
import 'pending_approvals_page.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  // Overview stats variables
  int _onTimeToday = 0;
  int _lateToday = 0;
  int _totalEmployees = 0;
  int _absencesThisWeek = 0;
  double _overtimeHours = 0;
  bool _isLoadingOverview = false;

  // Pending approvals variables
  final List<dynamic> _todayLogs = [];
  final List<dynamic> _allEmployees = [];
  int _pendingApprovalsCount = 0;
  bool _isLoadingPending = false;

  @override
  void initState() {
    super.initState();
    _loadOverviewStats();
    _loadPendingApprovalsCount();
  }

  Future<void> _loadOverviewStats() async {
    setState(() {
      _isLoadingOverview = true;
    });

    try {
      final stats = await AdminN8n.getOverviewStats();
      if (!mounted) return;

      setState(() {
        _onTimeToday = stats.onTimeToday;
        _lateToday = stats.lateToday;
        _totalEmployees = stats.totalEmployees;
        _absencesThisWeek = stats.absencesThisWeek;
        _overtimeHours = stats.overtimeHours;
        _isLoadingOverview = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _onTimeToday = 0;
        _lateToday = 0;
        _totalEmployees = 0;
        _absencesThisWeek = 0;
        _overtimeHours = 0;
        _isLoadingOverview = false;
      });
    }
  }

  Future<void> _loadPendingApprovalsCount() async {
    setState(() {
      _isLoadingPending = true;
    });

    try {
      final response = await N8nApi.getAdminPending();
      if (!mounted) return;

      final success = response['success'] == true;
      final list = response['pending'];

      if (success && list is List) {
        // Filter out rejected employees
        final filteredList = RejectedEmployeesTracker.filterRejected(
          list.cast<Map<String, dynamic>>(),
        );

        setState(() {
          _pendingApprovalsCount = filteredList.length;
          _isLoadingPending = false;
        });
      } else {
        setState(() {
          _pendingApprovalsCount = 0;
          _isLoadingPending = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingApprovalsCount = 0;
        _isLoadingPending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100),
                child: Image.asset(
                  'assets/images/branding/nutechlogo1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Divider(
                color: Colors.black.withOpacity(0.15),
                thickness: 1,
                height: 1,
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.black.withOpacity(0.15),
                thickness: 1,
                height: 1,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        title: 'On Time Today',
                        value: _isLoadingOverview
                            ? '...'
                            : _onTimeToday.toString(),
                        isDanger: false,
                        onTap: _isLoadingOverview
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const AttendanceDetailsPage(
                                      type: 'on_time',
                                    ),
                                  ),
                                );
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStat(
                        title: 'Late Today',
                        value: _isLoadingOverview
                            ? '...'
                            : _lateToday.toString(),
                        isDanger: true,
                        backgroundColor: const Color(0xFFE74C3C),
                        onTap: _isLoadingOverview
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const AttendanceDetailsPage(type: 'late'),
                                  ),
                                );
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AlertRow(
                  iconAsset: 'assets/admin/SandWatch.png',
                  title: 'Pending Approval',
                  value: _isLoadingPending
                      ? '...'
                      : _pendingApprovalsCount.toString(),
                  badgeColor: AppTheme.teal,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PendingApprovalsPage(),
                      ),
                    );
                    // Refresh the count when returning from pending approvals page
                    _loadPendingApprovalsCount();
                  },
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Data Status',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      _DataStatusRow(
                        iconAsset: 'assets/admin/Person-A.png',
                        label: 'Total Employees',
                        value: _isLoadingOverview
                            ? '...'
                            : _totalEmployees.toString(),
                        valueColor: AppTheme.ink,
                        showChevron: !_isLoadingOverview,
                        onTap: _isLoadingOverview
                            ? null
                            : () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AdminOverviewShell.employeesRoute);
                              },
                      ),
                      const _DividerLine(),
                      _DataStatusRow(
                        iconAsset: 'assets/admin/Attendance.png',
                        label: 'Absences This Week',
                        value: _isLoadingOverview
                            ? '...'
                            : _absencesThisWeek.toString(),
                        valueColor: Colors.red,
                      ),
                      const _DividerLine(),
                      _DataStatusRow(
                        iconAsset: 'assets/admin/Overtime.png',
                        label: 'Overtime Hours',
                        value: _isLoadingOverview
                            ? '...'
                            : _overtimeHours.toStringAsFixed(2),
                        valueColor: AppTheme.ink,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.title,
    required this.value,
    required this.isDanger,
    this.backgroundColor,
    this.onTap,
  });

  final String title;
  final String value;
  final bool isDanger;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ?? (isDanger ? const Color(0xFFE24B33) : AppTheme.teal);

    final card = Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withOpacity(0.18),
        highlightColor: Colors.white.withOpacity(0.08),
        child: card,
      ),
    );
  }
}

class _AlertRow extends StatefulWidget {
  const _AlertRow({
    required this.iconAsset,
    required this.title,
    required this.value,
    required this.badgeColor,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final String value;
  final Color badgeColor;
  final VoidCallback? onTap;

  @override
  State<_AlertRow> createState() => _AlertRowState();
}

class _AlertRowState extends State<_AlertRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.black.withOpacity(0.1),
          highlightColor: Colors.black.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? const Color(0xFFF5F5F5)
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? AppTheme.teal.withOpacity(0.5)
                    : Colors.black.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.10),
                  blurRadius: _isHovered ? 14 : 10,
                  offset: Offset(0, _isHovered ? 6 : 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Image.asset(widget.iconAsset, width: 28, height: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 64,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataStatusRow extends StatelessWidget {
  const _DataStatusRow({
    required this.iconAsset,
    required this.label,
    required this.value,
    required this.valueColor,
    this.onTap,
    this.showChevron = false,
  });

  final String iconAsset;
  final String label;
  final String value;
  final Color valueColor;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 26, height: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: valueColor,
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: Colors.black.withOpacity(0.28),
              size: 22,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.black.withOpacity(0.08),
    );
  }
}