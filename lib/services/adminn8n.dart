import 'dart:convert';
import 'package:http/http.dart' as http;

const String kAdminN8nBaseUrl = String.fromEnvironment(
  'N8N_BASE_URL',
  defaultValue: 'https://smiggyn8n.app.n8n.cloud',
);

bool get isAdminN8nConfigured {
  return !RegExp(
    r'YOUR-N8N|placeholder|example\.com',
    caseSensitive: false,
  ).hasMatch(kAdminN8nBaseUrl);
}

class AdminMonitorActivity {
  final String userId;
  final String fullName;
  final String? attendanceDate;
  final String? actionTime;
  final String? checkInTime;
  final String? checkOutTime;
  final double totalWorkTime;
  final String status;

  const AdminMonitorActivity({
    required this.userId,
    required this.fullName,
    required this.attendanceDate,
    required this.actionTime,
    required this.checkInTime,
    required this.checkOutTime,
    required this.totalWorkTime,
    required this.status,
  });

  factory AdminMonitorActivity.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return AdminMonitorActivity(
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      attendanceDate: json['attendanceDate']?.toString(),
      actionTime: json['actionTime']?.toString(),
      checkInTime: json['checkInTime']?.toString(),
      checkOutTime: json['checkOutTime']?.toString(),
      totalWorkTime: toDouble(json['totalWorkTime']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class AdminMonitorData {
  final int currentlyClockedIn;
  final int clockedOutToday;
  final int missingTimeOut;
  final int overtimeDetected;
  final List<AdminMonitorActivity> recentActivities;

  const AdminMonitorData({
    required this.currentlyClockedIn,
    required this.clockedOutToday,
    required this.missingTimeOut,
    required this.overtimeDetected,
    required this.recentActivities,
  });

  factory AdminMonitorData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawActivities = json['recentActivities'];
    final activities = rawActivities is List
        ? rawActivities
              .whereType<Map>()
              .map((e) => AdminMonitorActivity.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
        : <AdminMonitorActivity>[];

    return AdminMonitorData(
      currentlyClockedIn: toInt(json['currentlyClockedIn']),
      clockedOutToday: toInt(json['clockedOutToday']),
      missingTimeOut: toInt(json['missingTimeOut']),
      overtimeDetected: toInt(json['overtimeDetected']),
      recentActivities: activities,
    );
  }
}

class AdminOverviewStats {
  final int onTimeToday;
  final int lateToday;
  final int totalEmployees;
  final int absencesThisWeek;
  final double overtimeHours;

  const AdminOverviewStats({
    required this.onTimeToday,
    required this.lateToday,
    required this.totalEmployees,
    required this.absencesThisWeek,
    required this.overtimeHours,
  });

  factory AdminOverviewStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return AdminOverviewStats(
      onTimeToday: toInt(json['onTimeToday']),
      lateToday: toInt(json['lateToday']),
      totalEmployees: toInt(json['totalEmployees']),
      absencesThisWeek: toInt(json['absencesThisWeek']),
      overtimeHours: toDouble(json['overtimeHours']),
    );
  }
}

/// Profile / avatar URL from n8n objects (supports common key names).
String _adminParseProfileImageUrl(Map<String, dynamic> json) {
  String extract(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final s = value.trim();
      if (s.isNotEmpty && s != 'null') return s;
      return '';
    }
    if (value is Map) {
      final m = Map<String, dynamic>.from(value);
      for (final k in const ['url', 'secure_url', 'href', 'src']) {
        final v = m[k];
        if (v is String) {
          final s = v.trim();
          if (s.isNotEmpty && s != 'null') return s;
        }
      }
      return '';
    }
    if (value is List) {
      for (final item in value) {
        final s = extract(item);
        if (s.isNotEmpty) return s;
      }
      return '';
    }
    final s = value.toString().trim();
    if (s.isNotEmpty && s != 'null') return s;
    return '';
  }

  for (final key in const [
    'profileImageUrl',
    'profilePicture',
    'avatar',
    'photo',
    'imageUrl',
    'picture',
    'profilePhoto',
    'profile_image_url',
    'avatarUrl',
  ]) {
    final s = extract(json[key]);
    if (s.isNotEmpty) return s;
  }
  return '';
}

String _adminParseUserId(Map<String, dynamic> json) {
  for (final key in const [
    'userId',
    'employeeId',
    'employeeID',
    'id',
    'identifier',
    'user_id',
  ]) {
    final v = json[key];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty && s != 'null') return s;
  }
  return '';
}

class AdminDailyAttendanceRow {
  final String employee;
  final String userId;
  final String profileImageUrl;
  final String? timeIn;
  final String? timeOut;
  final double hours;
  final String status;

  const AdminDailyAttendanceRow({
    required this.employee,
    required this.userId,
    this.profileImageUrl = '',
    required this.timeIn,
    required this.timeOut,
    required this.hours,
    required this.status,
  });

  factory AdminDailyAttendanceRow.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return AdminDailyAttendanceRow(
      employee: (json['employee'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
      timeIn: json['timeIn']?.toString(),
      timeOut: json['timeOut']?.toString(),
      hours: toDouble(json['hours']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

bool _dailyStatusIsLate(String status) {
  final s = status.toLowerCase();
  return s.contains('late') || s.contains('missed');
}

bool _dailyStatusIsAbsent(String status) =>
    status.toLowerCase().contains('absent');

bool _dailyStatusIsOvertime(String status) =>
    status.toLowerCase().contains('overtime');

/// Drill-down row: present (for selected report date).
class AdminDailyPresentEntry {
  final String fullName;
  final String userId;
  final String profileImageUrl;
  final String? timeIn;
  final String? timeOut;
  final double? hours;

  const AdminDailyPresentEntry({
    required this.fullName,
    required this.userId,
    this.profileImageUrl = '',
    this.timeIn,
    this.timeOut,
    this.hours,
  });

  factory AdminDailyPresentEntry.fromJson(Map<String, dynamic> json) {
    double? toDoubleOpt(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AdminDailyPresentEntry(
      fullName:
          (json['fullName'] ?? json['employee'] ?? json['name'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
      timeIn: json['timeIn']?.toString(),
      timeOut: json['timeOut']?.toString(),
      hours: toDoubleOpt(json['hours']),
    );
  }

  factory AdminDailyPresentEntry.fromAttendanceRow(AdminDailyAttendanceRow r) {
    return AdminDailyPresentEntry(
      fullName: r.employee,
      userId: r.userId,
      profileImageUrl: r.profileImageUrl,
      timeIn: r.timeIn,
      timeOut: r.timeOut,
      hours: r.hours,
    );
  }
}

/// Drill-down row: late.
class AdminDailyLateEntry {
  final String fullName;
  final String userId;
  final String profileImageUrl;
  final String? timeIn;
  final String? timeOut;
  final String lateDescription;

  const AdminDailyLateEntry({
    required this.fullName,
    required this.userId,
    this.profileImageUrl = '',
    this.timeIn,
    this.timeOut,
    required this.lateDescription,
  });

  factory AdminDailyLateEntry.fromJson(Map<String, dynamic> json) {
    int? parseMin(dynamic v) {
      if (v is int) return v;
      if (v is double) return v.round();
      if (v is String) return int.tryParse(v.trim());
      return null;
    }

    final desc = (json['lateDescription'] ?? '').toString().trim();
    final mins = parseMin(json['lateBy']) ??
        parseMin(json['minutesLate']) ??
        parseMin(json['lateMinutes']);
    final lateDesc = desc.isNotEmpty
        ? desc
        : (mins != null && mins > 0 ? '$mins min late' : '—');

    return AdminDailyLateEntry(
      fullName:
          (json['fullName'] ?? json['employee'] ?? json['name'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
      timeIn: json['timeIn']?.toString(),
      timeOut: json['timeOut']?.toString(),
      lateDescription: lateDesc,
    );
  }

  factory AdminDailyLateEntry.fromAttendanceRow(AdminDailyAttendanceRow r) {
    return AdminDailyLateEntry(
      fullName: r.employee,
      userId: r.userId,
      profileImageUrl: r.profileImageUrl,
      timeIn: r.timeIn,
      timeOut: r.timeOut,
      lateDescription: '—',
    );
  }
}

/// Drill-down row: absent (may not appear in main [rows]).
class AdminDailyAbsentEntry {
  final String fullName;
  final String userId;
  final String profileImageUrl;

  const AdminDailyAbsentEntry({
    required this.fullName,
    required this.userId,
    this.profileImageUrl = '',
  });

  factory AdminDailyAbsentEntry.fromJson(Map<String, dynamic> json) {
    return AdminDailyAbsentEntry(
      fullName:
          (json['fullName'] ?? json['employee'] ?? json['name'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
    );
  }

  factory AdminDailyAbsentEntry.fromAttendanceRow(AdminDailyAttendanceRow r) {
    return AdminDailyAbsentEntry(
      fullName: r.employee,
      userId: r.userId,
      profileImageUrl: r.profileImageUrl,
    );
  }
}

/// Drill-down row: overtime.
class AdminDailyOvertimeEntry {
  final String fullName;
  final String userId;
  final String profileImageUrl;
  final String? timeIn;
  final String? timeOut;
  final double? hours;

  const AdminDailyOvertimeEntry({
    required this.fullName,
    required this.userId,
    this.profileImageUrl = '',
    this.timeIn,
    this.timeOut,
    this.hours,
  });

  factory AdminDailyOvertimeEntry.fromJson(Map<String, dynamic> json) {
    double? toDoubleOpt(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return AdminDailyOvertimeEntry(
      fullName:
          (json['fullName'] ?? json['employee'] ?? json['name'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
      timeIn: json['timeIn']?.toString(),
      timeOut: json['timeOut']?.toString(),
      hours: toDoubleOpt(json['hours'] ?? json['overtimeHours']),
    );
  }

  factory AdminDailyOvertimeEntry.fromAttendanceRow(AdminDailyAttendanceRow r) {
    return AdminDailyOvertimeEntry(
      fullName: r.employee,
      userId: r.userId,
      profileImageUrl: r.profileImageUrl,
      timeIn: r.timeIn,
      timeOut: r.timeOut,
      hours: r.hours,
    );
  }
}

List<T> _dailyParseList<T>(
  Map<String, dynamic> json,
  List<String> keys,
  T Function(Map<String, dynamic>) fromMap,
) {
  for (final k in keys) {
    final v = json[k];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
  return <T>[];
}

/// Daily attendance from GET `/webhook/admin/daily-attendance?date=YYYY-MM-DD`.
///
/// Optional in `data`: [presentEntries], [lateEntries], [absentEntries],
/// [overtimeEntries] for stat drill-downs. If omitted, lists are derived from [rows] by [status]
/// (absent employees not in [rows] need [absentEntries] from n8n).
class AdminDailyAttendanceReportData {
  final String date;
  final int present;
  final int late;
  final int absent;
  final int overtime;
  final List<AdminDailyAttendanceRow> rows;
  final List<AdminDailyPresentEntry> presentEntries;
  final List<AdminDailyLateEntry> lateEntries;
  final List<AdminDailyAbsentEntry> absentEntries;
  final List<AdminDailyOvertimeEntry> overtimeEntries;

  const AdminDailyAttendanceReportData({
    required this.date,
    required this.present,
    required this.late,
    required this.absent,
    required this.overtime,
    required this.rows,
    this.presentEntries = const [],
    this.lateEntries = const [],
    this.absentEntries = const [],
    this.overtimeEntries = const [],
  });

  /// Lists for UI: API arrays first, else split [rows] by status.
  List<AdminDailyPresentEntry> get resolvedPresent {
    if (presentEntries.isNotEmpty) return presentEntries;
    return rows
        .where(
          (r) =>
              !_dailyStatusIsLate(r.status) &&
              !_dailyStatusIsAbsent(r.status) &&
              !_dailyStatusIsOvertime(r.status),
        )
        .map(AdminDailyPresentEntry.fromAttendanceRow)
        .toList();
  }

  List<AdminDailyLateEntry> get resolvedLate {
    if (lateEntries.isNotEmpty) return lateEntries;
    return rows
        .where((r) => _dailyStatusIsLate(r.status))
        .map(AdminDailyLateEntry.fromAttendanceRow)
        .toList();
  }

  List<AdminDailyAbsentEntry> get resolvedAbsent {
    if (absentEntries.isNotEmpty) return absentEntries;
    return rows
        .where((r) => _dailyStatusIsAbsent(r.status))
        .map(AdminDailyAbsentEntry.fromAttendanceRow)
        .toList();
  }

  List<AdminDailyOvertimeEntry> get resolvedOvertime {
    if (overtimeEntries.isNotEmpty) return overtimeEntries;
    return rows
        .where((r) => _dailyStatusIsOvertime(r.status))
        .map(AdminDailyOvertimeEntry.fromAttendanceRow)
        .toList();
  }

  /// Uses [entryUrl] when set; otherwise first matching [rows] row by [userId].
  String resolvedProfileImageUrl({
    required String userId,
    required String entryUrl,
  }) {
    final direct = entryUrl.trim();
    if (direct.isNotEmpty) return direct;
    final id = userId.trim().toLowerCase();
    if (id.isEmpty) return '';
    for (final r in rows) {
      if (r.userId.trim().toLowerCase() == id) {
        final u = r.profileImageUrl.trim();
        if (u.isNotEmpty) return u;
      }
    }
    return '';
  }

  factory AdminDailyAttendanceReportData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawRows = json['rows'];
    final rows = rawRows is List
        ? rawRows
              .whereType<Map>()
              .map((e) => AdminDailyAttendanceRow.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
        : <AdminDailyAttendanceRow>[];

    final presentList = _dailyParseList<AdminDailyPresentEntry>(
      json,
      ['presentEntries', 'presentList'],
      AdminDailyPresentEntry.fromJson,
    );
    final lateList = _dailyParseList<AdminDailyLateEntry>(
      json,
      ['lateEntries', 'lateList'],
      AdminDailyLateEntry.fromJson,
    );
    final absentList = _dailyParseList<AdminDailyAbsentEntry>(
      json,
      ['absentEntries', 'absentList'],
      AdminDailyAbsentEntry.fromJson,
    );
    final otList = _dailyParseList<AdminDailyOvertimeEntry>(
      json,
      ['overtimeEntries', 'overtimeList'],
      AdminDailyOvertimeEntry.fromJson,
    );

    return AdminDailyAttendanceReportData(
      date: (json['date'] ?? '').toString(),
      present: toInt(json['present']),
      late: toInt(json['late']),
      absent: toInt(json['absent']),
      overtime: toInt(json['overtime']),
      rows: rows,
      presentEntries: presentList,
      lateEntries: lateList,
      absentEntries: absentList,
      overtimeEntries: otList,
    );
  }
}
class AdminWeeklySummaryRow {
  final String left;
  final String right;

  const AdminWeeklySummaryRow({
    required this.left,
    required this.right,
  });

  factory AdminWeeklySummaryRow.fromJson(Map<String, dynamic> json) {
    return AdminWeeklySummaryRow(
      left: (json['left'] ?? '').toString(),
      right: (json['right'] ?? '').toString(),
    );
  }
}

/// One employee in the “total employees” roster (non-clickable list in app).
class AdminWeeklyRosterEntry {
  final String fullName;
  final String userId;
  final String profileImageUrl;

  const AdminWeeklyRosterEntry({
    required this.fullName,
    required this.userId,
    this.profileImageUrl = '',
  });

  factory AdminWeeklyRosterEntry.fromJson(Map<String, dynamic> json) {
    return AdminWeeklyRosterEntry(
      fullName: (json['fullName'] ?? '').toString(),
      userId: _adminParseUserId(json),
      profileImageUrl: _adminParseProfileImageUrl(json),
    );
  }
}

/// Present attendance row for the selected range (shows date per entry).
class AdminWeeklyPresentEntry {
  final String fullName;
  final String userId;
  final String date;
  final String profileImageUrl;

  const AdminWeeklyPresentEntry({
    required this.fullName,
    required this.userId,
    required this.date,
    this.profileImageUrl = '',
  });

  factory AdminWeeklyPresentEntry.fromJson(Map<String, dynamic> json) {
    return AdminWeeklyPresentEntry(
      fullName: (json['fullName'] ?? '').toString(),
      userId: _adminParseUserId(json),
      date: (json['date'] ?? '').toString(),
      profileImageUrl: _adminParseProfileImageUrl(json),
    );
  }
}

/// Late row for a date in the range. [lateBy] is integer **minutes after the 8:15 AM cutoff**
/// (e.g. 25 ⇒ arrived 8:40). [lateDescription] is optional human text (e.g. `"25 min late"`).
class AdminWeeklyLateEntry {
  final String fullName;
  final String userId;
  final String date;
  final String lateDescription;
  final String profileImageUrl;

  const AdminWeeklyLateEntry({
    required this.fullName,
    required this.userId,
    required this.date,
    required this.lateDescription,
    this.profileImageUrl = '',
  });

  static int? _parseMinutes(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  factory AdminWeeklyLateEntry.fromJson(Map<String, dynamic> json) {
    final descStr = (json['lateDescription'] ?? '').toString().trim();

    // `lateBy` is minutes (int) from n8n
    int? minutesLate = _parseMinutes(json['lateBy']);
    minutesLate ??= _parseMinutes(json['minutesLate']);
    minutesLate ??= _parseMinutes(json['lateMinutes']);

    String lateDesc;
    if (descStr.isNotEmpty) {
      lateDesc = descStr;
    } else if (minutesLate != null && minutesLate > 0) {
      lateDesc = '$minutesLate min late';
    } else {
      lateDesc = '—';
    }

    return AdminWeeklyLateEntry(
      fullName: (json['fullName'] ?? '').toString(),
      userId: _adminParseUserId(json),
      date: (json['date'] ?? '').toString(),
      lateDescription: lateDesc,
      profileImageUrl: _adminParseProfileImageUrl(json),
    );
  }
}

/// Absent row: roster employee with **no attendance record** that workday (they do not appear in
/// attendance `rows`). One entry per employee per absent `date` in the range.
class AdminWeeklyAbsentEntry {
  final String fullName;
  final String userId;
  final String date;
  final String profileImageUrl;

  const AdminWeeklyAbsentEntry({
    required this.fullName,
    required this.userId,
    required this.date,
    this.profileImageUrl = '',
  });

  factory AdminWeeklyAbsentEntry.fromJson(Map<String, dynamic> json) {
    return AdminWeeklyAbsentEntry(
      fullName: (json['fullName'] ?? '').toString(),
      userId: _adminParseUserId(json),
      date: (json['date'] ?? '').toString(),
      profileImageUrl: _adminParseProfileImageUrl(json),
    );
  }
}

List<T> _weeklySummaryParseList<T>(
  Map<String, dynamic> json,
  List<String> keys,
  T Function(Map<String, dynamic>) fromMap,
) {
  for (final k in keys) {
    final v = json[k];
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
  return <T>[];
}

/// Summary report from GET `/webhook/admin/weekly-summary?start=YYYY-MM-DD&end=YYYY-MM-DD`.
///
/// API shape: `{ "success": true, "data": { ... } }`. [AdminN8n.getWeeklySummary] parses `data`.
///
/// `data` includes:
/// - Counts: [totalEmployees], [presentCount], [lateCount], [absentCount]
/// - [summaryRows]: optional `{ left, right }[]`; if empty, UI uses [totalAttendanceLogs],
///   [totalHoursWorked], [totalOvertimeHours], [missingTimeOutLogs]
/// - **Drill-down** (read separately from `rows`; absent staff never appear in log rows):
///   - [employeeRoster] → Total Employees button
///   - [presentEntries] → Present
///   - [lateEntries] → Late ([AdminWeeklyLateEntry.lateBy] = minutes after 8:15 AM cutoff)
///   - [absentEntries] → Absent (roster members with **no** attendance that workday;
///     one row per employee per absent `date`)
///
/// [totalOvertimeHours]: aggregate overtime in range (typically hours worked beyond 8.0 per day).
class AdminWeeklySummaryData {
  final String start;
  final String end;
  final int totalEmployees;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final List<AdminWeeklySummaryRow> summaryRows;
  final List<AdminWeeklyRosterEntry> rosterEmployees;
  final List<AdminWeeklyPresentEntry> presentEntries;
  final List<AdminWeeklyLateEntry> lateEntries;
  final List<AdminWeeklyAbsentEntry> absentEntries;

  /// Attendance log rows in range (check-ins / records), from DB via n8n.
  final int totalAttendanceLogs;

  /// Sum of regular hours in range.
  final double totalHoursWorked;

  /// Sum of overtime hours in range.
  final double totalOvertimeHours;

  /// Count of logs missing clock-out in range.
  final int missingTimeOutLogs;

  const AdminWeeklySummaryData({
    required this.start,
    required this.end,
    required this.totalEmployees,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.summaryRows,
    this.rosterEmployees = const [],
    this.presentEntries = const [],
    this.lateEntries = const [],
    this.absentEntries = const [],
    this.totalAttendanceLogs = 0,
    this.totalHoursWorked = 0,
    this.totalOvertimeHours = 0,
    this.missingTimeOutLogs = 0,
  });

  /// Uses [entryUrl] when set; otherwise [employeeRoster] match on [userId].
  String resolvedProfileImageUrl({
    required String userId,
    required String entryUrl,
  }) {
    final direct = entryUrl.trim();
    if (direct.isNotEmpty) return direct;
    final id = userId.trim().toLowerCase();
    if (id.isEmpty) return '';
    for (final r in rosterEmployees) {
      if (r.userId.trim().toLowerCase() == id) {
        final u = r.profileImageUrl.trim();
        if (u.isNotEmpty) return u;
      }
    }
    return '';
  }

  /// True if API returned anything non-trivial for this range.
  bool get hasMeaningfulData {
    if (totalEmployees + presentCount + lateCount + absentCount > 0) return true;
    if (totalAttendanceLogs > 0 ||
        totalHoursWorked > 0 ||
        totalOvertimeHours > 0 ||
        missingTimeOutLogs > 0) {
      return true;
    }
    if (summaryRows.isNotEmpty) return true;
    if (rosterEmployees.isNotEmpty ||
        presentEntries.isNotEmpty ||
        lateEntries.isNotEmpty ||
        absentEntries.isNotEmpty) {
      return true;
    }
    return false;
  }

  /// Table under “Period summary”: webhook [summaryRows] or built-in metrics.
  List<AdminWeeklySummaryRow> get displaySummaryRows {
    if (summaryRows.isNotEmpty) return summaryRows;
    String fmtH(double h) {
      if (h == h.roundToDouble()) return h.round().toString();
      return h.toStringAsFixed(1);
    }

    return [
      AdminWeeklySummaryRow(
        left: 'Total attendance logs',
        right: totalAttendanceLogs.toString(),
      ),
      AdminWeeklySummaryRow(
        left: 'Total hours worked',
        right: fmtH(totalHoursWorked),
      ),
      AdminWeeklySummaryRow(
        left: 'Total overtime hours',
        right: fmtH(totalOvertimeHours),
      ),
      AdminWeeklySummaryRow(
        left: 'Missing time-out logs',
        right: missingTimeOutLogs.toString(),
      ),
    ];
  }

  factory AdminWeeklySummaryData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double toDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    final rawRows = json['summaryRows'];
    final rows = rawRows is List
        ? rawRows
            .whereType<Map>()
            .map((e) => AdminWeeklySummaryRow.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <AdminWeeklySummaryRow>[];

    final roster = _weeklySummaryParseList<AdminWeeklyRosterEntry>(
      json,
      [
        'employeeRoster',
        'totalEmployeesList',
        'employees',
        'allEmployees',
        'roster',
      ],
      AdminWeeklyRosterEntry.fromJson,
    );

    final present = _weeklySummaryParseList<AdminWeeklyPresentEntry>(
      json,
      ['presentEntries', 'presentList', 'presentDetails'],
      AdminWeeklyPresentEntry.fromJson,
    );

    final late = _weeklySummaryParseList<AdminWeeklyLateEntry>(
      json,
      ['lateEntries', 'lateList', 'lateDetails'],
      AdminWeeklyLateEntry.fromJson,
    );

    final absent = _weeklySummaryParseList<AdminWeeklyAbsentEntry>(
      json,
      ['absentEntries', 'absentList', 'absentDetails'],
      AdminWeeklyAbsentEntry.fromJson,
    );

    final logs = toInt(
      json['totalAttendanceLogs'] ??
          json['attendanceLogCount'] ??
          json['totalLogs'],
    );
    final hours = toDouble(
      json['totalHoursWorked'] ?? json['hoursWorkedTotal'] ?? json['totalHours'],
    );
    final otHrs = toDouble(
      json['totalOvertimeHours'] ??
          json['overtimeHoursTotal'] ??
          json['overtimeHours'],
    );
    final missingOut = toInt(
      json['missingTimeOutLogs'] ??
          json['missingTimeOut'] ??
          json['missingTimeoutCount'],
    );

    return AdminWeeklySummaryData(
      start: (json['start'] ?? json['startDate'] ?? '').toString(),
      end: (json['end'] ?? json['endDate'] ?? '').toString(),
      totalEmployees:
          toInt(json['totalEmployees'] ?? json['employeeCount'] ?? json['totalStaff']),
      presentCount: toInt(json['presentCount'] ?? json['present']),
      lateCount: toInt(json['lateCount'] ?? json['late']),
      absentCount: toInt(json['absentCount'] ?? json['absent']),
      summaryRows: rows,
      rosterEmployees: roster,
      presentEntries: present,
      lateEntries: late,
      absentEntries: absent,
      totalAttendanceLogs: logs,
      totalHoursWorked: hours,
      totalOvertimeHours: otHrs,
      missingTimeOutLogs: missingOut,
    );
  }
}

class AdminLateAbsenceRow {
  final String employee;
  final int late;
  final int absent;

  const AdminLateAbsenceRow({
    required this.employee,
    required this.late,
    required this.absent,
  });

  factory AdminLateAbsenceRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return AdminLateAbsenceRow(
      employee: (json['employee'] ?? '').toString(),
      late: toInt(json['late']),
      absent: toInt(json['absent']),
    );
  }
}

class AdminLateAbsencesData {
  final String date;
  final int totalLate;
  final int totalAbsent;
  final List<AdminLateAbsenceRow> rows;

  const AdminLateAbsencesData({
    required this.date,
    required this.totalLate,
    required this.totalAbsent,
    required this.rows,
  });

  factory AdminLateAbsencesData.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final rawRows = json['rows'];
    final rows = rawRows is List
        ? rawRows
            .whereType<Map>()
            .map((e) => AdminLateAbsenceRow.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <AdminLateAbsenceRow>[];

    return AdminLateAbsencesData(
      date: (json['date'] ?? '').toString(),
      totalLate: toInt(json['totalLate']),
      totalAbsent: toInt(json['totalAbsent']),
      rows: rows,
    );
  }
}

class AdminN8n {
  static Uri _buildUri(String path) {
    return Uri.parse(kAdminN8nBaseUrl + path);
  }

  static String _formatDateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
  
  static Future<AdminLateAbsencesData> getLateAbsencesReport({
    required DateTime date,
  }) async {
    if (!isAdminN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL.',
      );
    }

    final dateStr = _formatDateOnly(date);
    final response = await http.get(
      _buildUri('/webhook/admin/late-absences?date=$dateStr'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Admin late & absences request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return AdminLateAbsencesData(
        date: dateStr,
        totalLate: 0,
        totalAbsent: 0,
        rows: const [],
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return AdminLateAbsencesData.fromJson(data);
      }

      return AdminLateAbsencesData.fromJson(decoded);
    }

    throw Exception('Invalid admin late & absences response format.');
  }

  static Future<AdminWeeklySummaryData> getWeeklySummary({
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isAdminN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL.',
      );
    }

    final startStr = _formatDateOnly(start);
    final endStr = _formatDateOnly(end);

    final response = await http.get(
      _buildUri('/webhook/admin/weekly-summary?start=$startStr&end=$endStr'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Admin weekly summary request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return AdminWeeklySummaryData(
        start: startStr,
        end: endStr,
        totalEmployees: 0,
        presentCount: 0,
        lateCount: 0,
        absentCount: 0,
        summaryRows: const [],
        rosterEmployees: const [],
        presentEntries: const [],
        lateEntries: const [],
        absentEntries: const [],
        totalAttendanceLogs: 0,
        totalHoursWorked: 0,
        totalOvertimeHours: 0,
        missingTimeOutLogs: 0,
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid admin weekly summary response format.');
    }

    if (decoded['success'] == false) {
      final msg = (decoded['message'] ?? 'Weekly summary request failed').toString();
      throw Exception(msg.isEmpty ? 'Weekly summary request failed.' : msg);
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) {
      return AdminWeeklySummaryData.fromJson(data);
    }

    // Legacy: fields at root without `data` wrapper
    return AdminWeeklySummaryData.fromJson(decoded);
  }
  static Future<AdminOverviewStats> getOverviewStats() async {
    if (!isAdminN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL.',
      );
    }

    final response = await http.get(_buildUri('/webhook/admin/overview'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Admin overview request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return const AdminOverviewStats(
        onTimeToday: 0,
        lateToday: 0,
        totalEmployees: 0,
        absencesThisWeek: 0,
        overtimeHours: 0,
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return AdminOverviewStats.fromJson(data);
      }
      return AdminOverviewStats.fromJson(decoded);
    }

    throw Exception('Invalid admin overview response format.');
  }

  static Future<AdminMonitorData> getMonitorData() async {
    if (!isAdminN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL.',
      );
    }

    final response = await http.get(_buildUri('/webhook/admin/monitor'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Admin monitor request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return const AdminMonitorData(
        currentlyClockedIn: 0,
        clockedOutToday: 0,
        missingTimeOut: 0,
        overtimeDetected: 0,
        recentActivities: [],
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return AdminMonitorData.fromJson(data);
      }

      return AdminMonitorData.fromJson(decoded);
    }

    throw Exception('Invalid admin monitor response format.');
  }

  static Future<AdminDailyAttendanceReportData> getDailyAttendanceReport({
    required DateTime date,
  }) async {
    if (!isAdminN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL.',
      );
    }

    final dateStr = _formatDateOnly(date);
    final response = await http.get(
      _buildUri('/webhook/admin/daily-attendance?date=$dateStr'),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Admin daily attendance request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return AdminDailyAttendanceReportData(
        date: dateStr,
        present: 0,
        late: 0,
        absent: 0,
        overtime: 0,
        rows: const [],
        presentEntries: const [],
        lateEntries: const [],
        absentEntries: const [],
        overtimeEntries: const [],
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        return AdminDailyAttendanceReportData.fromJson(data);
      }

      return AdminDailyAttendanceReportData.fromJson(decoded);
    }

    throw Exception('Invalid admin daily attendance response format.');
  }
}