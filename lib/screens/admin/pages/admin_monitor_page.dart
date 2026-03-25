import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/adminn8n.dart';
import '../../../../widgets/nutech_background.dart';
import 'attendance_details_page.dart'; // --- NEW: Imported our live page ---

class AdminMonitorPage extends StatefulWidget {
  const AdminMonitorPage({super.key});

  @override
  State<AdminMonitorPage> createState() => _AdminMonitorPageState();
}

class _AdminMonitorPageState extends State<AdminMonitorPage> {
  int _tab = 0; // 0 = Today, 1 = This Week
  bool _isLoading = false;

  int _currentlyClockedIn = 0;
  int _clockedOutToday = 0;
  int _missingTimeOut = 0;

  List<AdminMonitorActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadMonitorData();
  }

  Future<void> _loadMonitorData() async {
    setState(() => _isLoading = true);

    try {
      final data = await AdminN8n.getMonitorData();
      if (!mounted) return;

      setState(() {
        _currentlyClockedIn = data.currentlyClockedIn;
        _clockedOutToday = data.clockedOutToday;
        _missingTimeOut = data.missingTimeOut;
        _activities = data.recentActivities;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentlyClockedIn = 0;
        _clockedOutToday = 0;
        _missingTimeOut = 0;
        _activities = [];
        _isLoading = false;
      });
    }
  }

  // --- UPDATED NAVIGATION LOGIC ---
  void _navigateToDetail(String title) {
    String type = '';
    
    // Map the card title directly to our n8n filter types
    if (title == 'Currently Clocked In') {
      type = 'currently_clocked_in';
    } else if (title == 'Clocked Out Today') {
      type = 'clocked_out_today';
    } else if (title == 'Missing Time-Out') {
      type = 'missing_time_out';
    }

    if (type.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AttendanceDetailsPage(type: type),
        ),
      );
    }
  }

  // --- Date and Time Helpers ---

  String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDateOnly(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  bool _isToday(String? attendanceDate) => attendanceDate == _todayString();

  bool _isThisWeek(String? attendanceDate) {
    final date = _parseDateOnly(attendanceDate);
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diffToMonday = today.weekday - DateTime.monday;
    final startOfWeek = today.subtract(Duration(days: diffToMonday));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
  }

  String _formatUtcTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return '-';
    final trimmed = raw.trim();
    if (trimmed.contains('AM') || trimmed.contains('PM')) return trimmed;
    
    final isoMatch = RegExp(r'T(\d{2}):(\d{2})').firstMatch(trimmed);
    if (isoMatch != null) {
      return _to12Hour(int.parse(isoMatch.group(1)!), int.parse(isoMatch.group(2)!));
    }
    
    final simpleMatch = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(trimmed);
    if (simpleMatch != null) {
      return _to12Hour(int.parse(simpleMatch.group(1)!), int.parse(simpleMatch.group(2)!));
    }
    return trimmed;
  }

  String _to12Hour(int hour, int minute) {
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$hour12:${minute.toString().padLeft(2, '0')} $suffix';
  }

  String _buildTimeText(AdminMonitorActivity activity) {
    final dateText = activity.attendanceDate ?? '-';
    final actionTime = _formatUtcTime(activity.actionTime);
    return actionTime != '-' ? '$dateText • $actionTime' : dateText;
  }

  _MonitorStatus _mapStatus(String status) {
    final value = status.toLowerCase();
    if (value.contains('alert')) return _MonitorStatus.alert;
    if (value.contains('clocked out')) return _MonitorStatus.clockedOut;
    return _MonitorStatus.clockedIn;
  }

  List<_MonitorItem> get _displayItems {
    final filtered = _activities.where((activity) {
      return _tab == 0 ? _isToday(activity.attendanceDate) : _isThisWeek(activity.attendanceDate);
    }).toList();

    final Map<String, List<AdminMonitorActivity>> grouped = {};
    for (final activity in filtered) {
      final key = '${activity.userId}_${activity.attendanceDate}';
      grouped.putIfAbsent(key, () => []).add(activity);
    }

    return grouped.entries.map((entry) {
      final activities = entry.value;
      final firstActivity = activities.first;
      String? clockInTime;
      String? clockOutTime;

      for (final activity in activities) {
        final status = _mapStatus(activity.status);
        if (status == _MonitorStatus.clockedIn) {
          clockInTime = _formatUtcTime(activity.actionTime);
        } else if (status == _MonitorStatus.clockedOut) {
          clockOutTime = _formatUtcTime(activity.actionTime);
        }
      }

      return _MonitorItem(
        name: firstActivity.fullName.isNotEmpty ? firstActivity.fullName : firstActivity.userId,
        site: firstActivity.userId,
        status: _mapStatus(firstActivity.status),
        timeText: _buildTimeText(firstActivity),
        clockInTime: clockInTime,
        clockOutTime: clockOutTime,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _displayItems;
    final double cardWidth = (MediaQuery.of(context).size.width - 54) / 2;

    return RefreshIndicator(
      onRefresh: _loadMonitorData,
      color: AppTheme.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  child: Image.asset('assets/images/branding/nutechlogo1.png', fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Center(
                child: Text(
                  'Attendance Monitoring',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
                ),
              ),
            ),
            Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Currently Clocked In',
                          value: _isLoading ? '...' : _currentlyClockedIn.toString(),
                          background: AppTheme.teal,
                          onTap: () => _navigateToDetail('Currently Clocked In'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _StatCard(
                          title: 'Clocked Out Today',
                          value: _isLoading ? '...' : _clockedOutToday.toString(),
                          background: const Color(0xFFFFA826),
                          onTap: () => _navigateToDetail('Clocked Out Today'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: SizedBox(
                      width: cardWidth,
                      child: _StatCard(
                        title: 'Missing Time-Out',
                        value: _isLoading ? '...' : _missingTimeOut.toString(),
                        background: const Color(0xFFE74C3C),
                        onTap: () => _navigateToDetail('Missing Time-Out'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        if (_isLoading)
                          const _LoadingState()
                        else if (items.isEmpty)
                          const _EmptyState()
                        else
                          ...items.map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _EmployeeRow(item: e, isTranslucent: true),
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
      ),
    );
  }
}

// --- Supporting Widgets ---

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title, 
    required this.value, 
    required this.background,
    required this.onTap,
  });
  final String title;
  final String value;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    value, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)
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
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5), 
        borderRadius: BorderRadius.circular(14)
      ),
      child: Row(
        children: [
          _SegmentTile(label: left, isSelected: index == 0, onTap: () => onChanged(0)),
          const SizedBox(width: 6),
          _SegmentTile(label: right, isSelected: index == 1, onTap: () => onChanged(1)),
        ],
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.teal : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: isSelected ? Colors.white : AppTheme.ink
            ),
          ),
        ),
      ),
    );
  }
}

enum _MonitorStatus { clockedIn, clockedOut, alert }

class _MonitorItem {
  const _MonitorItem({
    required this.name,
    required this.site,
    required this.status,
    required this.timeText,
    this.clockInTime,
    this.clockOutTime,
  });
  final String name;
  final String site;
  final _MonitorStatus status;
  final String timeText;
  final String? clockInTime;
  final String? clockOutTime;
}

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow({required this.item, this.isTranslucent = false});
  final _MonitorItem item;
  final bool isTranslucent;

  @override
  Widget build(BuildContext context) {
    final bool hasBothTimes = item.clockInTime != null && item.clockOutTime != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isTranslucent ? Colors.white.withOpacity(0.8) : Colors.white,
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
                Text(
                  item.site, 
                  style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600, fontSize: 12)
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasBothTimes)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'In: ${item.clockInTime}', 
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green)
                      ),
                      Text(
                        'Out: ${item.clockOutTime}', 
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.orange)
                      ),
                    ],
                  ),
                )
              else ...[
                _StatusPill(status: item.status),
                const SizedBox(height: 4),
                Text(
                  item.timeText, 
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)
                ),
              ],
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
    Color bg; Color fg; String text;
    switch (status) {
      case _MonitorStatus.clockedIn:
        bg = AppTheme.teal; fg = Colors.white; text = 'Clocked In';
        break;
      case _MonitorStatus.clockedOut:
        bg = const Color(0xFFE9ECEF); fg = AppTheme.ink; text = 'Clocked Out';
        break;
      case _MonitorStatus.alert:
        bg = AppTheme.danger; fg = Colors.white; text = 'ALERT';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text, 
        style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 11)
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          "Loading logs...", 
          style: TextStyle(color: AppTheme.ink.withOpacity(0.4), fontWeight: FontWeight.w600)
        )
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Text(
          "No logs found for this period", 
          style: TextStyle(color: AppTheme.ink.withOpacity(0.4), fontWeight: FontWeight.w600)
        )
      ),
    );
  }
}