import 'package:flutter/material.dart';

import '../../../models/admin_employee_summary.dart';
import '../../../services/n8n_api.dart';
import '../../../theme/app_theme.dart';
import 'admin_employee_profile_page.dart';

class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({super.key});

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  List<AdminEmployeeSummary> _employees = [];
  int _total = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await N8nApi.postAdminEmployees();
      if (!mounted) return;

      final success = response['success'] == true;
      if (!success) {
        final msg = (response['message'] ?? 'Request failed').toString();
        setState(() {
          _employees = [];
          _total = 0;
          _loading = false;
          _error = msg.isEmpty ? 'Could not load employees.' : msg;
        });
        return;
      }

      final raw = response['employees'];
      final totalRaw = response['total'];
      final list = <AdminEmployeeSummary>[];

      if (raw is List) {
        for (final item in raw) {
          if (item is Map<String, dynamic>) {
            list.add(AdminEmployeeSummary.fromJson(item));
          } else if (item is Map) {
            list.add(
              AdminEmployeeSummary.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      }

      setState(() {
        _employees = list;
        _total = totalRaw is int
            ? totalRaw
            : int.tryParse(totalRaw?.toString() ?? '') ?? list.length;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _employees = [];
        _total = 0;
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              const Expanded(
                child: Text(
                  'Employee List',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: AppTheme.teal,
            onRefresh: _load,
            child: _buildBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Center(
            child: FilledButton(
              onPressed: _load,
              style: FilledButton.styleFrom(backgroundColor: AppTheme.teal),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    if (_employees.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Text(
            'No employees (total: $_total)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black.withOpacity(0.45),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _employees.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$_total employee${_total == 1 ? '' : 's'}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black.withOpacity(0.55),
                fontSize: 13,
              ),
            ),
          );
        }
        final emp = _employees[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminEmployeeProfilePage(
                      userId: emp.userId,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    _EmployeeAvatar(url: emp.profileImageUrl),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emp.fullName.trim().isEmpty ? '—' : emp.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emp.userId.trim().isEmpty ? '—' : emp.userId,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmployeeAvatar extends StatelessWidget {
  const _EmployeeAvatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final trimmed = url.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: trimmed.isNotEmpty
          ? Image.network(
              trimmed,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/images/avatar.png',
      width: 56,
      height: 56,
      fit: BoxFit.cover,
    );
  }
}
