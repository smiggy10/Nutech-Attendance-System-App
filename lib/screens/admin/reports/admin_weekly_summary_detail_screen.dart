import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutech_app/services/adminn8n.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/employee_profile_avatar.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

enum WeeklySummaryDetailKind {
  totalEmployees,
  present,
  late,
  absent,
}

/// Drill-down for summary report stats (no extra API call). Stat button → list:
/// - **Total employees** → [AdminWeeklySummaryData.rosterEmployees] (`employeeRoster`)
/// - **Present** → [AdminWeeklySummaryData.presentEntries]
/// - **Late** → [AdminWeeklySummaryData.lateEntries] (`lateBy` minutes after 8:15 AM, `lateDescription`)
/// - **Absent** → [AdminWeeklySummaryData.absentEntries] (roster with no log that day; includes `date`)
class AdminWeeklySummaryDetailScreen extends StatelessWidget {
  const AdminWeeklySummaryDetailScreen({
    super.key,
    required this.kind,
    required this.periodLabel,
    required this.data,
  });

  final WeeklySummaryDetailKind kind;
  final String periodLabel;

  /// Parsed weekly summary (includes roster + entry arrays from the same GET response).
  final AdminWeeklySummaryData data;

  String get _title {
    switch (kind) {
      case WeeklySummaryDetailKind.totalEmployees:
        return 'Total employees';
      case WeeklySummaryDetailKind.present:
        return 'Present';
      case WeeklySummaryDetailKind.late:
        return 'Late';
      case WeeklySummaryDetailKind.absent:
        return 'Absent';
    }
  }

  Widget _employeeListCard({
    required String userId,
    required String preferredImageUrl,
    required Widget body,
  }) {
    return _InfoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmployeeProfileAvatar(
            key: ValueKey('$userId|$preferredImageUrl'),
            userId: userId,
            preferredImageUrl: preferredImageUrl,
          ),
          const SizedBox(width: 14),
          Expanded(child: body),
        ],
      ),
    );
  }

  static String _formatDateLabel(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '—';
    final parsed = DateTime.tryParse(t);
    if (parsed != null) {
      return DateFormat('MMM d, yyyy').format(parsed);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        bottomAsset: 'assets/images/ui/bottombackground2.png',
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.teal,
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  periodLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(child: _buildList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    switch (kind) {
      case WeeklySummaryDetailKind.totalEmployees:
        final list = [...data.rosterEmployees]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _emptyState(
            'No employees in `employeeRoster` for this period.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final e = list[i];
            return _employeeListCard(
              userId: e.userId,
              preferredImageUrl: data.resolvedProfileImageUrl(
                userId: e.userId,
                entryUrl: e.profileImageUrl,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName.trim().isEmpty ? '—' : e.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    e.userId.trim().isEmpty ? '—' : e.userId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case WeeklySummaryDetailKind.present:
        final list = [...data.presentEntries]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            final d = a.date.compareTo(b.date);
            if (d != 0) return d;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _emptyState(
            'No rows in `presentEntries` for this period.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final e = list[i];
            return _employeeListCard(
              userId: e.userId,
              preferredImageUrl: data.resolvedProfileImageUrl(
                userId: e.userId,
                entryUrl: e.profileImageUrl,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName.trim().isEmpty ? '—' : e.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.userId.trim().isEmpty ? '—' : e.userId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: AppTheme.teal.withOpacity(0.85),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateLabel(e.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );

      case WeeklySummaryDetailKind.late:
        final list = [...data.lateEntries]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            final d = a.date.compareTo(b.date);
            if (d != 0) return d;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _emptyState(
            'No rows in `lateEntries` for this period.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final e = list[i];
            return _employeeListCard(
              userId: e.userId,
              preferredImageUrl: data.resolvedProfileImageUrl(
                userId: e.userId,
                entryUrl: e.profileImageUrl,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName.trim().isEmpty ? '—' : e.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.userId.trim().isEmpty ? '—' : e.userId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: const Color(0xFFE74C3C).withOpacity(0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDateLabel(e.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: Color(0xFFE74C3C),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            e.lateDescription,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFFB03A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );

      case WeeklySummaryDetailKind.absent:
        final list = [...data.absentEntries]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            final d = a.date.compareTo(b.date);
            if (d != 0) return d;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _emptyState(
            'No rows in `absentEntries`. Populate this array with roster employees who had '
            'no attendance log on each absent workday (they do not appear in log rows).',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final e = list[i];
            return _employeeListCard(
              userId: e.userId,
              preferredImageUrl: data.resolvedProfileImageUrl(
                userId: e.userId,
                entryUrl: e.profileImageUrl,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.fullName.trim().isEmpty ? '—' : e.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    e.userId.trim().isEmpty ? '—' : e.userId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 18,
                        color: const Color(0xFFF39C12).withOpacity(0.95),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Absent: ${_formatDateLabel(e.date)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
    }
  }

  Widget _emptyState(String message) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Icon(
          Icons.info_outline,
          size: 48,
          color: Colors.black.withOpacity(0.25),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
