import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

class AdminDailyAttendanceScreen extends StatefulWidget {
  const AdminDailyAttendanceScreen({super.key});

  static const route = '/admin/daily-attendance';

  @override
  State<AdminDailyAttendanceScreen> createState() => _AdminDailyAttendanceScreenState();
}

class _AdminDailyAttendanceScreenState extends State<AdminDailyAttendanceScreen> {
  // FIXED: Initialized with DateTime.now() to ensure it reflects the actual current date
  DateTime _selectedDate = DateTime.now();
  late Future<List<_DailyRow>> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = _fetchAttendanceData();
  }

  Future<List<_DailyRow>> _fetchAttendanceData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // TO SHOW "NO RECORDS FOUND": Return an empty list []
    return [];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.teal),
        ),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _attendanceData = _fetchAttendanceData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM d, yyyy').format(_selectedDate);

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
                      const SizedBox(height: 10),
                      _buildTitleSection(),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _FilterCard(
                              text: 'Date: $formattedDate',
                              actionText: 'Change',
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<List<_DailyRow>>(
                              future: _attendanceData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 50),
                                    child: CircularProgressIndicator(color: AppTheme.teal),
                                  );
                                }

                                final data = snapshot.data ?? [];

                                if (data.isEmpty) {
                                  return Column(
                                    children: [
                                      _buildStatsRow('0', '0', '0', '0'),
                                      const SizedBox(height: 14),
                                      _buildSectionDivider(),
                                      const SizedBox(height: 10),
                                      _TableCard(
                                        child: Container(
                                          height: 200,
                                          alignment: Alignment.center,
                                          child: Text(
                                            "No records found for this period",
                                            style: TextStyle(
                                              color: Colors.black.withOpacity(0.5),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _buildStatsRow('28', '4', '2', '28'),
                                    const SizedBox(height: 14),
                                    _buildSectionDivider(),
                                    const SizedBox(height: 10),
                                    _TableCard(child: _buildDataTable(data)),
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
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: const Center(
            child: Text(
              'Daily Attendance Report',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Daily Report',
            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1)),
      ],
    );
  }

  Widget _buildStatsRow(String p, String l, String a, String o) {
    return Row(
      children: [
        Expanded(child: _MiniStatCard(label: 'Present', value: p, color: AppTheme.teal)),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(label: 'Late', value: l, color: const Color(0xFFE74C3C))),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(label: 'Absent', value: a, color: const Color(0xFFF39C12))),
        const SizedBox(width: 10),
        Expanded(child: _MiniStatCard(label: 'Overtime', value: o, color: const Color(0xFF5DADE2))),
      ],
    );
  }

  Widget _buildDataTable(List<_DailyRow> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 520),
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(color: Colors.black.withOpacity(0.18)),
          columnWidths: const {
            0: FlexColumnWidth(2.2),
            1: FlexColumnWidth(1.2),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(0.9),
            4: FlexColumnWidth(1.2),
          },
          children: [
            _headerRow(),
            ...rows.map((r) => _dataRow(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
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
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE7E7E7)),
      children: ['Employee', 'Time In', 'Time Out', 'Hours', 'Status'].map((t) => 
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
        )
      ).toList(),
    );
  }

  TableRow _dataRow(_DailyRow r) {
    return TableRow(
      children: [
        _cell(Text(r.employee)),
        _cell(Text(r.timeIn)),
        _cell(Text(r.timeOut)),
        _cell(Text(r.hours)),
        _cell(Align(alignment: Alignment.centerLeft, child: _StatusChip(status: r.status))),
      ],
    );
  }

  Widget _cell(Widget child) => Padding(padding: const EdgeInsets.all(10), child: child);
}

class _DailyRow {
  final String employee, timeIn, timeOut, hours, status;
  _DailyRow(this.employee, this.timeIn, this.timeOut, this.hours, this.status);
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.text, required this.actionText, required this.onTap});
  final String text, actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
          InkWell(
            onTap: onTap,
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
      height: 66,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase().trim();
    Color bg = const Color(0xFF17A673);
    if (s == 'late' || s == 'missed out') bg = const Color(0xFFE74C3C);
    else if (s == 'absent') bg = const Color(0xFFF39C12);
    else if (s == 'overtime') bg = const Color(0xFF5DADE2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
    );
  }
}