import 'n8n_api.dart';
import 'user_session.dart';

class AttendanceLogEntry {
  final DateTime date;
  final String status;
  final String clockIn;
  final String clockOut;
  final String clockInDevice;
  final String clockOutDevice;
  final int totalMinutes;
  final int overtimeMinutes;
  final String site;
  final String remarks;
  final String cardNo; // Added field

  const AttendanceLogEntry({
    required this.date,
    required this.status,
    required this.clockIn,
    required this.clockOut,
    required this.clockInDevice,
    required this.clockOutDevice,
    required this.totalMinutes,
    required this.overtimeMinutes,
    required this.site,
    required this.remarks,
    required this.cardNo, // Added to constructor
  });

  factory AttendanceLogEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceLogEntry(
      date: _parseDate(json['date']),
      status: (json['status'] ?? '').toString(),
      clockIn: (json['clockIn'] ?? '').toString(),
      clockOut: (json['clockOut'] ?? '').toString(),
      clockInDevice: (json['clockInDevice'] ?? '').toString(),
      clockOutDevice: (json['clockOutDevice'] ?? '').toString(),
      totalMinutes: _toInt(json['totalMinutes']),
      overtimeMinutes: _toInt(json['overtimeMinutes']),
      site: (json['site'] ?? '').toString(),
      remarks: (json['remarks'] ?? '').toString(),
      cardNo: (json['cardNo'] ?? '').toString(), // Map from JSON
    );
  }

  static DateTime _parseDate(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    if (value.isEmpty) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return DateTime(parsed.year, parsed.month, parsed.day);
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static int _toInt(dynamic raw) {
    if (raw == null) return 0;
    if (raw is int) return raw;
    return int.tryParse(raw.toString()) ?? 0;
  }

  DateTime get dayKey => DateTime(date.year, date.month, date.day);

  String get totalHoursLabel => formatMinutes(totalMinutes);
  String get overtimeLabel => formatMinutes(overtimeMinutes);

  static String formatMinutes(int minutes) {
    final hrs = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hrs}h ${mins}m';
  }
}

class AttendanceLogsService {
  AttendanceLogsService._();

  static Future<List<AttendanceLogEntry>> fetchCurrentUserLogs() async {
    final identifier = UserSession.loginIdentifier;

    if (identifier == null || identifier.isEmpty) {
      return [];
    }

    final response = await N8nApi.getUserLogs(identifier: identifier);

    final success = response['success'] == true;
    final message = (response['message'] ?? '').toString();
    final data = response['data'];

    if (!success) {
      throw Exception(message.isEmpty ? 'Failed to fetch logs.' : message);
    }

    final List<dynamic> rawLogs;
    if (data is Map<String, dynamic> && data['logs'] is List) {
      rawLogs = data['logs'] as List<dynamic>;
    } else if (data is List) {
      rawLogs = data;
    } else {
      rawLogs = [];
    }

    final logs = rawLogs
        .whereType<Map>()
        .map((item) => AttendanceLogEntry.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();

    logs.sort((a, b) {
      final dateCompare = b.date.compareTo(a.date);
      if (dateCompare != 0) return dateCompare;
      return b.clockIn.compareTo(a.clockIn);
    });

    return logs;
  }
}