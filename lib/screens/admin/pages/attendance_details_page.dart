import 'package:flutter/material.dart';
import '../../../services/n8n_api.dart';
import '../../../theme/app_theme.dart';

class AttendanceDetailsPage extends StatefulWidget {
  const AttendanceDetailsPage({super.key, required this.type});

  /// Expected values: "on_time", "late", "currently_clocked_in", "clocked_out_today", "missing_time_out"
  final String type;

  @override
  State<AttendanceDetailsPage> createState() => _AttendanceDetailsPageState();
}

class _AttendanceDetailsPageState extends State<AttendanceDetailsPage> {
  bool _isLoading = true;
  String? _error;
  List<AttendanceEmployee> _employees = [];

  bool get _isLatePage => widget.type == 'late';

  // --- UPDATED: Dynamic Page Title ---
  String get _title {
    switch (widget.type) {
      case 'on_time': return 'On Time Today';
      case 'late': return 'Late Today';
      case 'currently_clocked_in': return 'Currently Clocked In';
      case 'clocked_out_today': return 'Clocked Out Today';
      case 'missing_time_out': return 'Missing Time-Out';
      default: return 'Attendance Details';
    }
  }

  // --- NEW: Dynamic Header Color based on your screenshot ---
  Color get _headerColor {
    switch (widget.type) {
      case 'late': 
      case 'missing_time_out': 
        return const Color(0xFFE74C3C); // Red for alerts
      case 'clocked_out_today': 
        return Colors.orange; // Orange for clocked out
      case 'on_time':
      case 'currently_clocked_in':
      default: 
        return AppTheme.teal; // Teal for active/good status
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await N8nApi.postAttendanceDetails(type: widget.type);
      
      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _employees = data.map((json) => AttendanceEmployee.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response['message'] ?? 'Failed to load details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // --- UPDATED: Back button matches the theme color ---
                      color: _headerColor, 
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        _title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _headerColor, // Make the title pop!
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildBodyContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: _headerColor));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _fetchData, child: const Text('Retry'))
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return Center(
        child: Text(
          'No attendance records available.',
          style: TextStyle(
            color: Colors.black.withOpacity(0.45),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: _headerColor,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final emp = _employees[index];
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
                    _EmployeeAvatar(imageUrl: emp.image),
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
                              color: widget.type == 'missing_time_out' 
                                      ? Colors.red 
                                      : Colors.black.withOpacity(0.72),
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
  const _EmployeeAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackImage(),
            )
          : _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Image.asset(
      'assets/images/avatar.png',
      width: 56,
      height: 56,
      fit: BoxFit.cover,
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

  factory AttendanceEmployee.fromJson(Map<String, dynamic> json) {
    return AttendanceEmployee(
      name: (json['name'] ?? 'Unknown').toString(),
      userId: (json['userId'] ?? 'Unknown ID').toString(),
      checkIn: (json['checkIn'] ?? '--:--').toString(),
      checkOut: (json['checkOut'] ?? '--:--').toString(),
      isLate: json['isLate'] == true,
      image: (json['image'] ?? '').toString(),
    );
  }
}