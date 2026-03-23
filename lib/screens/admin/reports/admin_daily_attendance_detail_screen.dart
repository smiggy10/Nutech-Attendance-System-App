import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutech_app/services/adminn8n.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/employee_profile_avatar.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

enum DailyAttendanceDetailKind { present, late, absent, overtime }

/// Same shell as [AdminDailyAttendanceScreen]: bottom wave background.
class AdminDailyAttendanceDetailScreen extends StatelessWidget {
  const AdminDailyAttendanceDetailScreen({
    super.key,
    required this.kind,
    required this.reportDateLabel,
    required this.data,
    required this.formatTimeManila,
  });

  final DailyAttendanceDetailKind kind;
  final String reportDateLabel;
  final AdminDailyAttendanceReportData data;

  /// PHT 12h formatter from parent (shared with main report).
  final String Function(String? raw) formatTimeManila;

  String get _title {
    switch (kind) {
      case DailyAttendanceDetailKind.present:
        return 'Present';
      case DailyAttendanceDetailKind.late:
        return 'Late';
      case DailyAttendanceDetailKind.absent:
        return 'Absent';
      case DailyAttendanceDetailKind.overtime:
        return 'Overtime';
    }
  }

  String _prettyReportDate() {
    final raw = data.date.trim();
    if (raw.isEmpty) return reportDateLabel;
    final p = DateTime.tryParse(raw.length >= 10 ? raw.substring(0, 10) : raw);
    if (p != null) {
      return DateFormat('MMMM d, yyyy').format(p);
    }
    return raw;
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
                  _prettyReportDate(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(child: _buildList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _employeeListCard({
    required String userId,
    required String preferredImageUrl,
    required Widget body,
  }) {
    return _DailyInfoCard(
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

  Widget _buildList() {
    switch (kind) {
      case DailyAttendanceDetailKind.present:
        final list = [...data.resolvedPresent]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _empty('No employees in the present list for this date.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
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
                  _nameBlock(e.fullName, e.userId),
                  const SizedBox(height: 10),
                  _kvRow('Time in', formatTimeManila(e.timeIn)),
                  _kvRow('Time out', formatTimeManila(e.timeOut)),
                  if (e.hours != null)
                    _kvRow('Hours', e.hours!.toStringAsFixed(1)),
                ],
              ),
            );
          },
        );

      case DailyAttendanceDetailKind.late:
        final list = [...data.resolvedLate]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _empty('No employees in the late list for this date.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
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
                  _nameBlock(e.fullName, e.userId),
                  const SizedBox(height: 8),
                  _kvRow('Time in', formatTimeManila(e.timeIn)),
                  _kvRow('Time out', formatTimeManila(e.timeOut)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 18,
                          color: Color(0xFFE74C3C),
                        ),
                        const SizedBox(width: 8),
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

      case DailyAttendanceDetailKind.absent:
        final list = [...data.resolvedAbsent]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _empty(
            'No employees in the absent list.\n\n'
            'If absences are missing, add `absentEntries` to the daily-attendance webhook response.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
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
                  _nameBlock(e.fullName, e.userId),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 18,
                        color: const Color(0xFFF39C12).withOpacity(0.95),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Absent: ${_prettyReportDate()}',
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

      case DailyAttendanceDetailKind.overtime:
        final list = [...data.resolvedOvertime]..sort((a, b) {
            final n = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
            if (n != 0) return n;
            return a.userId.compareTo(b.userId);
          });
        if (list.isEmpty) {
          return _empty('No employees in the overtime list for this date.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
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
                  _nameBlock(e.fullName, e.userId),
                  const SizedBox(height: 10),
                  _kvRow('Time in', formatTimeManila(e.timeIn)),
                  _kvRow('Time out', formatTimeManila(e.timeOut)),
                  if (e.hours != null)
                    _kvRow('Hours', e.hours!.toStringAsFixed(1)),
                ],
              ),
            );
          },
        );
    }
  }

  Widget _nameBlock(String name, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.trim().isEmpty ? '—' : name,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userId.trim().isEmpty ? '—' : userId,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black.withOpacity(0.45),
          ),
        ),
      ],
    );
  }

  Widget _kvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(String message) {
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

class _DailyInfoCard extends StatelessWidget {
  const _DailyInfoCard({required this.child});

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
