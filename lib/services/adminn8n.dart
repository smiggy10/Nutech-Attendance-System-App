import 'dart:convert';
import 'package:http/http.dart' as http;

const String kAdminN8nBaseUrl = String.fromEnvironment(
  'N8N_BASE_URL',
  defaultValue: 'https://smiggybayhon.app.n8n.cloud',
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

class AdminDailyAttendanceRow {
  final String employee;
  final String userId;
  final String? timeIn;
  final String? timeOut;
  final double hours;
  final String status;

  const AdminDailyAttendanceRow({
    required this.employee,
    required this.userId,
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
      userId: (json['userId'] ?? '').toString(),
      timeIn: json['timeIn']?.toString(),
      timeOut: json['timeOut']?.toString(),
      hours: toDouble(json['hours']),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class AdminDailyAttendanceReportData {
  final String date;
  final int present;
  final int late;
  final int absent;
  final int overtime;
  final List<AdminDailyAttendanceRow> rows;

  const AdminDailyAttendanceReportData({
    required this.date,
    required this.present,
    required this.late,
    required this.absent,
    required this.overtime,
    required this.rows,
  });

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

    return AdminDailyAttendanceReportData(
      date: (json['date'] ?? '').toString(),
      present: toInt(json['present']),
      late: toInt(json['late']),
      absent: toInt(json['absent']),
      overtime: toInt(json['overtime']),
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