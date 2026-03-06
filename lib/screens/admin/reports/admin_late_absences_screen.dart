import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

class AdminLateAbsencesScreen extends StatefulWidget {
  const AdminLateAbsencesScreen({super.key});

  static const route = '/admin/late-absences';

  @override
  State<AdminLateAbsencesScreen> createState() => _AdminLateAbsencesScreenState();
}

class _AdminLateAbsencesScreenState extends State<AdminLateAbsencesScreen> {
  late Future<_LAReportPackage?> _reportData;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _reportData = _fetchLateAbsences();
  }

  Future<void> _changeDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.teal),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _reportData = _fetchLateAbsences();
      });
    }
  }

  Future<_LAReportPackage?> _fetchLateAbsences() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return null; 
  }

  @override
  Widget build(BuildContext context) {
    final String dateString = DateFormat('MMMM d, yyyy').format(_selectedDate);

    return Scaffold(
      body: NutechBackground(
        bottomAsset: 'assets/images/ui/bottombackground2.png',
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // LOGO SECTION: Exact match to AdminOverviewPage
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: Image.asset(
                              'assets/images/branding/nutechlogo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10), // Matched spacing
                      _buildTitleBar(),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _FilterCard(
                              text: 'Date: $dateString',
                              actionText: 'Change',
                              onTap: _changeDate,
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<_LAReportPackage?>(
                              future: _reportData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 100),
                                    child: CircularProgressIndicator(color: AppTheme.teal),
                                  );
                                }

                                final data = snapshot.data;

                                if (data == null || data.rows.isEmpty) {
                                  return Column(
                                    children: [
                                      _buildStatsRow(late: '0', absent: '0'),
                                      const SizedBox(height: 20),
                                      _buildEmptyStateCard("No records found for this date"),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _buildStatsRow(late: data.totalLate, absent: data.totalAbsent),
                                    const SizedBox(height: 20),
                                    _buildTable(data),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable(_LAReportPackage data) {
    return _TableCard(
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: TableBorder.all(
          color: Colors.black.withOpacity(0.18),
          width: 1,
        ),
        columnWidths: const {
          0: FlexColumnWidth(2.6),
          1: FlexColumnWidth(1.0),
          2: FlexColumnWidth(1.0),
        },
        children: [
          _headerRow(),
          for (final r in data.rows) _dataRow(r),
        ],
      ),
    );
  }

  Widget _buildTitleBar() {
    return Column(
      children: [
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Text(
              'Late & Absences',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black),
            ),
          ),
        ),
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildStatsRow({required String late, required String absent}) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            label: 'Total Late',
            value: late,
            color: const Color(0xFFE74C3C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            label: 'Total Absent',
            value: absent,
            color: const Color(0xFFF39C12),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard(String message) {
    return _TableCard(
      child: Container(
        height: 240,
        alignment: Alignment.center,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black.withOpacity(0.4),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Export Report', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE6E7EA),
                  foregroundColor: const Color(0xFF5B5F66),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE7E7E7)),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text('Employees', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text('Late', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text('Absent', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  TableRow _dataRow(_LArow r) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.black,
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.black54),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(r.name)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Center(child: Text('${r.late}')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Center(child: Text('${r.absent}')),
        ),
      ],
    );
  }
}

// Supporting Models remains the same as your input
class _LAReportPackage {
  final String totalLate;
  final String totalAbsent;
  final List<_LArow> rows;
  const _LAReportPackage({required this.totalLate, required this.totalAbsent, required this.rows});
}

class _LArow {
  final String name;
  final int late;
  final int absent;
  const _LArow(this.name, this.late, this.absent);
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.text, required this.actionText, required this.onTap});
  final String text, actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500))),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppTheme.tealSoft, borderRadius: BorderRadius.circular(8)),
              child: Text(actionText, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.teal)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}