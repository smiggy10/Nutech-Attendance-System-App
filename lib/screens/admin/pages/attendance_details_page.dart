import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class AttendanceDetailsPage extends StatelessWidget {
  const AttendanceDetailsPage({super.key, required this.type});

  /// Expected values: "on_time" or "late"
  final String type;

  bool get _isLatePage => type == 'late';
  String get _title => _isLatePage ? 'Late Today' : 'On Time Today';

  List<AttendanceEmployee> get _employees {
    // Frontend-only source for now; replace with API provider later.
    final all = AttendanceDetailsMockRepository.allEmployees;
    if (_isLatePage) {
      return all.where((e) => e.isLate).toList();
    }
    return all.where((e) => !e.isLate).toList();
  }

  @override
  Widget build(BuildContext context) {
    final employees = _employees;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppTheme.teal,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: employees.isEmpty
                    ? Center(
                        child: Text(
                          'No attendance records available.',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.45),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final emp = employees[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.white,
                              elevation: 1,
                              shadowColor: Colors.black26,
                              borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _EmployeeAvatar(imageAsset: emp.image),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            emp.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            emp.userId,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: Colors.black.withOpacity(0.5),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text(
                                                'Check-in: ${emp.checkIn}',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black.withOpacity(0.72),
                                                ),
                                              ),
                                              if (_isLatePage && emp.isLate) ...[
                                                const SizedBox(width: 8),
                                                const _LateBadge(),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Check-out: ${emp.checkOut}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black.withOpacity(0.72),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LateBadge extends StatelessWidget {
  const _LateBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE74C3C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCF3F31)),
      ),
      child: const Text(
        'LATE',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  const _EmployeeAvatar({required this.imageAsset});

  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        imageAsset,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      ),
    );
  }
}

class AttendanceEmployee {
  const AttendanceEmployee({
    required this.name,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.isLate,
    required this.image,
  });

  final String name;
  final String userId;
  final String checkIn;
  final String checkOut;
  final bool isLate;
  final String image;

  /// Future-ready mapper for n8n/backend payloads.
  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployee(
      name: (json['name'] ?? '0').toString(),
      userId: (json['userId'] ?? '0').toString(),
      checkIn: (json['checkIn'] ?? '0').toString(),
      checkOut: (json['checkOut'] ?? '0').toString(),
      isLate: json['isLate'] == true,
      image: (json['image'] ?? 'assets/images/avatar.png').toString(),
    );
  }
}

class AttendanceDetailsMockRepository {
  AttendanceDetailsMockRepository._();

  static final List<AttendanceEmployee> allEmployees =
      _seedData.map(AttendanceEmployee.fromJson).toList();

  static const List<Map<String, dynamic>> _seedData = [
    {
      'name': '0',
      'userId': '0',
      'checkIn': '0',
      'checkOut': '0',
      'isLate': true,
      'image': 'assets/images/avatar.png',
    },
    {
      'name': '0',
      'userId': '0',
      'checkIn': '0',
      'checkOut': '0',
      'isLate': false,
      'image': 'assets/images/avatar.png',
    },
    {
      'name': '0',
      'userId': '0',
      'checkIn': '0',
      'checkOut': '0',
      'isLate': true,
      'image': 'assets/images/avatar.png',
    },
    {
      'name': '0',
      'userId': '0',
      'checkIn': '0',
      'checkOut': '0',
      'isLate': false,
      'image': 'assets/images/avatar.png',
    },
  ];
}
