import 'attendance_logs_service.dart';
import 'user_profile_service.dart';

class DashboardData {
  final String displayName;
  final String profileImageUrl;
  final String statusLabel;
  final String statusHeadline;
  final String statusSubtext;
  final bool isCurrentlyActive;
  final int todayMinutes;
  final int weeklyMinutes;
  final List<int> weekdayMinutes; // Monday to Friday
  final String todayClockIn;
  final String todayClockOut;
  final String todayDevice;
  final String todayRemarks;
  // Field added to store the RFID/Card number for the UI
  final String todayCardNo;

  const DashboardData({
    required this.displayName,
    required this.profileImageUrl,
    required this.statusLabel,
    required this.statusHeadline,
    required this.statusSubtext,
    required this.isCurrentlyActive,
    required this.todayMinutes,
    required this.weeklyMinutes,
    required this.weekdayMinutes,
    required this.todayClockIn,
    required this.todayClockOut,
    required this.todayDevice,
    required this.todayRemarks,
    required this.todayCardNo,
  });

  double get progress => (todayMinutes / 480).clamp(0, 1).toDouble();

  bool get hasOvertime => todayMinutes > 480;

  String get todayHoursLabel => AttendanceLogEntry.formatMinutes(todayMinutes);

  String get weeklyHoursLabel =>
      AttendanceLogEntry.formatMinutes(weeklyMinutes);
}

class DashboardService {
  DashboardService._();

  static Future<DashboardData> fetchDashboard({
    String? fallbackUserName,
  }) async {
    final profile = await UserProfileService.fetchCurrentUserProfile();
    final logs = await AttendanceLogsService.fetchCurrentUserLogs();

    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);

    final todayEntries = logs.where((e) => e.dayKey == todayKey).toList();

    final int weekday = now.weekday; // 1=Mon, 7=Sun
    final weekStart = todayKey.subtract(Duration(days: weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final weekEntries = logs.where((entry) {
      return !entry.dayKey.isBefore(weekStart) && !entry.dayKey.isAfter(weekEnd);
    }).toList();

    final todayMinutes =
        todayEntries.fold<int>(0, (sum, entry) => sum + entry.totalMinutes);

    final weeklyMinutes =
        weekEntries.fold<int>(0, (sum, entry) => sum + entry.totalMinutes);

    final weekdayMinutes = List<int>.generate(5, (index) {
      final day = weekStart.add(Duration(days: index));
      return weekEntries
          .where((entry) => entry.dayKey == day)
          .fold<int>(0, (sum, entry) => sum + entry.totalMinutes);
    });

    final latestToday = todayEntries.isEmpty ? null : todayEntries.first;

    final hasOpenShift = todayEntries.any(
      (entry) => entry.clockIn.isNotEmpty && entry.clockOut.isEmpty,
    );

    final hasTodayRecord = todayEntries.isNotEmpty;

    final statusLabel = hasOpenShift
        ? 'ACTIVE'
        : hasTodayRecord
            ? 'RECORDED'
            : 'INACTIVE';

    final statusHeadline = hasOpenShift
        ? 'Shift in progress'
        : hasTodayRecord
            ? 'Attendance recorded for today'
            : 'No attendance record today';

    String statusSubtext;
    if (hasOpenShift) {
      statusSubtext = latestToday != null && latestToday.clockIn.isNotEmpty
          ? 'Clocked in at ${latestToday.clockIn}'
          : 'Attendance is active';
    } else if (hasTodayRecord) {
      if (latestToday != null && latestToday.clockOut.isNotEmpty) {
        statusSubtext = 'Last clock-out: ${latestToday.clockOut}';
      } else if (latestToday != null && latestToday.clockIn.isNotEmpty) {
        statusSubtext = 'Last clock-in: ${latestToday.clockIn}';
      } else {
        statusSubtext = 'Attendance entry found for today';
      }
    } else {
      statusSubtext = 'Waiting for today’s attendance log';
    }

    final rawName = (profile?.fullName ?? fallbackUserName ?? '').trim();
    final displayName = _friendlyDisplayName(rawName);

    final todayDevice = latestToday == null
        ? ''
        : [
            latestToday.clockInDevice.trim(),
            latestToday.clockOutDevice.trim(),
          ].where((value) => value.isNotEmpty).join(' / ');

    final todayRemarks = latestToday?.remarks.trim() ?? '';

    // Map the card number from the log entry (defaults to empty string if null)
    final todayCardNo = latestToday?.cardNo.trim() ?? '';

    return DashboardData(
      displayName: displayName.isEmpty ? 'Guest' : displayName,
      profileImageUrl: profile?.profileImageUrl.trim() ?? '',
      statusLabel: statusLabel,
      statusHeadline: statusHeadline,
      statusSubtext: statusSubtext,
      isCurrentlyActive: hasOpenShift,
      todayMinutes: todayMinutes,
      weeklyMinutes: weeklyMinutes,
      weekdayMinutes: weekdayMinutes,
      todayClockIn: latestToday?.clockIn.trim() ?? '',
      todayClockOut: latestToday?.clockOut.trim() ?? '',
      todayDevice: todayDevice,
      todayRemarks: todayRemarks,
      todayCardNo: todayCardNo, 
    );
  }

  static String _friendlyDisplayName(String raw) {
    if (raw.trim().isEmpty) return '';

    final pieces = raw
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (pieces.isEmpty) return '';

    final first = pieces.first.toLowerCase();
    return first[0].toUpperCase() + first.substring(1);
  }
}