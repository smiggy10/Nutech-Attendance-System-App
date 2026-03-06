import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class AdminMonitorPage extends StatefulWidget {
  const AdminMonitorPage({super.key});

  @override
  State<AdminMonitorPage> createState() => _AdminMonitorPageState();
}

class _AdminMonitorPageState extends State<AdminMonitorPage> {
  int _tab = 0; // 0 = Today, 1 = This Week

  // ✅ The list starts empty. Numbers will stay at 0 until n8n fills this list.
  List<_MonitorItem> items = [];

  @override
  Widget build(BuildContext context) {
    // These lines calculate the numbers based on what is actually in your 'items' list
    final int clockedInCount = items.where((e) => e.status == _MonitorStatus.clockedIn).length;
    final int alertCount = items.where((e) => e.status == _MonitorStatus.alert).length;
    final int clockedOutCount = items.where((e) => e.status == _MonitorStatus.clockedOut).length;

    return SingleChildScrollView(
      // ✅ Removed horizontal padding to allow Dividers to hit screen edges
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ Section 1: Logo (Re-applied horizontal padding)
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
          
          // ✅ FIXED: Continuous edge-to-edge lines for the title
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
                child: const Center(
                  child: Text(
                    'Attendance Monitoring',
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
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

          const SizedBox(height: 16),

          // ✅ Section 2: Body Content (Re-applied horizontal padding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Currently Clocked In',
                        value: clockedInCount.toString(),
                        background: AppTheme.teal,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _StatCard(
                        title: 'Clocked Out Today',
                        value: clockedOutCount.toString(),
                        background: const Color(0xFFFFA826),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Missing Time-Out',
                        value: alertCount.toString(),
                        background: AppTheme.danger,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: _StatCard(
                        title: 'Overtime Detected',
                        value: '0', 
                        background: AppTheme.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main Container for Employee Logs
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Segmented(
                        left: 'Today',
                        right: 'This Week',
                        index: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          "Recent Activity Logs (${items.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.ink.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),

                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              "No logs found for this period",
                              style: TextStyle(
                                color: AppTheme.ink.withOpacity(0.4),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        ...items.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EmployeeRow(item: e),
                            )),
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

// --- Supporting Widgets ---

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.background});
  final String title;
  final String value;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({required this.left, required this.right, required this.index, required this.onChanged});
  final String left;
  final String right;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == 0 ? AppTheme.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(left, style: TextStyle(fontWeight: FontWeight.w900, color: index == 0 ? Colors.white : AppTheme.ink)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index == 1 ? AppTheme.teal : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(right, style: TextStyle(fontWeight: FontWeight.w900, color: index == 1 ? Colors.white : AppTheme.ink)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MonitorStatus { clockedIn, clockedOut, alert }

class _MonitorItem {
  const _MonitorItem({required this.name, required this.site, required this.status, required this.timeText});
  final String name;
  final String site;
  final _MonitorStatus status;
  final String timeText;
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.item});
  final _MonitorItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black.withOpacity(0.08),
            child: Icon(Icons.person, color: Colors.black.withOpacity(0.45)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(item.site, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusPill(status: item.status),
              const SizedBox(height: 6),
              Text(item.timeText, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final _MonitorStatus status;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String text;

    switch (status) {
      case _MonitorStatus.clockedIn:
        bg = AppTheme.teal;
        fg = Colors.white;
        text = 'Clocked In';
        break;
      case _MonitorStatus.clockedOut:
        bg = const Color(0xFFE9ECEF);
        fg = AppTheme.ink;
        text = 'Clocked Out';
        break;
      case _MonitorStatus.alert:
        bg = AppTheme.danger;
        fg = Colors.white;
        text = 'ALERT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}