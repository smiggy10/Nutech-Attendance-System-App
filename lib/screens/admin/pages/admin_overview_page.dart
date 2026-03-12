import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'pending_approvals_page.dart';

class AdminOverviewPage extends StatefulWidget {
  const AdminOverviewPage({super.key});

  @override
  State<AdminOverviewPage> createState() => _AdminOverviewPageState();
}

class _AdminOverviewPageState extends State<AdminOverviewPage> {
  final List<dynamic> _todayLogs = [];
  final List<dynamic> _allEmployees = [];

  @override
  Widget build(BuildContext context) {
    final onTimeCount = _todayLogs
        .where((l) => l['status'] == 'on-time')
        .length;
    final lateCount = _todayLogs.where((l) => l['status'] == 'late').length;
    final totalEmployees = _allEmployees.length;

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
                        value: onTimeCount.toString(),
                        isDanger: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MiniStat(
                        title: 'Late Today',
                        value: lateCount.toString(),
                        isDanger: true,
                        backgroundColor: const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _AlertRow(
                  iconAsset: 'assets/admin/SandWatch.png',
                  title: 'Pending Approval',
                  value: 'View',
                  badgeColor: AppTheme.teal,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PendingApprovalsPage(),
                      ),
                    );
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
                        value: totalEmployees.toString(),
                        valueColor: AppTheme.ink,
                      ),
                      const _DividerLine(),
                      const _DataStatusRow(
                        iconAsset: 'assets/admin/Attendance.png',

                        label: 'Absences This Week',
                        value: '0',
                        valueColor: Colors.red,
                      ),
                      const _DividerLine(),
                      const _DataStatusRow(
                        iconAsset: 'assets/admin/Overtime.png',

                        label: 'Overtime Hours',
                        value: '0',
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
  });
  final String title;
  final String value;
  final bool isDanger;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ?? (isDanger ? const Color(0xFFE24B33) : AppTheme.teal);
    return Container(
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
  }
}

/// Updated _AlertRow with Hover Effect
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
              // Slightly darken background on hover
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
  });
  final String iconAsset;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        ],
      ),
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
