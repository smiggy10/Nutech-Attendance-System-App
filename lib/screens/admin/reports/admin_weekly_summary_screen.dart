import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';

class AdminWeeklySummaryScreen extends StatefulWidget {
  const AdminWeeklySummaryScreen({super.key});

  static const route = '/admin/weekly-summary';

  @override
  State<AdminWeeklySummaryScreen> createState() => _AdminWeeklySummaryScreenState();
}

class _AdminWeeklySummaryScreenState extends State<AdminWeeklySummaryScreen> {
  // Use DateTimeRange to store a start and end date
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  
  late Future<_WeeklyDataPackage?> _weeklyData;

  @override
  void initState() {
    super.initState();
    _weeklyData = _fetchWeeklySummary();
  }

  Future<_WeeklyDataPackage?> _fetchWeeklySummary() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    // Simulated return null for "No Records" state
    return null; 
  }

  // Updated to pick a range instead of a single day
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.teal,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
        _weeklyData = _fetchWeeklySummary();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format the range for display: "Mar 7 - Mar 14, 2026"
    final df = DateFormat('MMM d');
    final yf = DateFormat('yyyy');
    String rangeText = "${df.format(_selectedRange.start)} - ${df.format(_selectedRange.end)}, ${yf.format(_selectedRange.end)}";

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
                      // MATCHED LOGO SECTION: From Overview Page
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
                      
                      // MATCHED TITLE BAR: From Overview Page
                      Column(
                        children: [
                          Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'Weekly Summary Report',
                                style: TextStyle(
                                  fontSize: 26, 
                                  fontWeight: FontWeight.w800, 
                                  color: Colors.black.withOpacity(0.8)
                                ),
                              ),
                            ),
                          ),
                          Divider(color: Colors.black.withOpacity(0.15), thickness: 1, height: 1),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _FilterCard(
                              text: 'Period: $rangeText',
                              actionText: 'Change',
                              onTap: () => _selectDateRange(context),
                            ),
                            const SizedBox(height: 20), 
                            
                            FutureBuilder<_WeeklyDataPackage?>(
                              future: _weeklyData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 120),
                                    child: CircularProgressIndicator(color: AppTheme.teal),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return _buildStatusMessage("Could not connect to database");
                                }

                                final dataPackage = snapshot.data;

                                if (dataPackage == null || dataPackage.summaryRows.isEmpty) {
                                  return Column(
                                    children: [
                                      _buildStatsRow(total: '0', p: '0', l: '0', a: '0'),
                                      const SizedBox(height: 14),
                                      _buildSectionDivider('Daily Report'), 
                                      const SizedBox(height: 10),
                                      _buildEmptyStateCard("No records found for this period"),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    _buildStatsRow(
                                      total: dataPackage.totalEmployees,
                                      p: dataPackage.presentCount,
                                      l: dataPackage.lateCount,
                                      a: dataPackage.absentCount,
                                    ), 
                                    const SizedBox(height: 14),
                                    _buildSectionDivider('Weekly Totals'),
                                    const SizedBox(height: 10),
                                    _TotalsCard(rows: dataPackage.summaryRows),
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

  // --- UI Builders ---

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

  Widget _buildStatusMessage(String message) {
    return _TableCard(
      child: Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildStatsRow({
    required String total, 
    required String p, 
    required String l, 
    required String a
  }) {
    return Row(
      children: [
        Expanded(child: _MiniStatCard(label: 'Total\nEmployees', value: total, color: const Color(0xFF1FA651))),
        const SizedBox(width: 8),
        Expanded(child: _MiniStatCard(label: 'Present', value: p, color: const Color(0xFF148A8F))),
        const SizedBox(width: 8),
        Expanded(child: _MiniStatCard(label: 'Late', value: l, color: const Color(0xFFE74C3C))),
        const SizedBox(width: 8),
        Expanded(child: _MiniStatCard(label: 'Absent', value: a, color: const Color(0xFFF39C12))),
      ],
    );
  }

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
        Expanded(child: Divider(color: Colors.black.withOpacity(0.25), thickness: 1)),
      ],
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
}

// --- Supporting Models ---

class _WeeklyDataPackage {
  final String totalEmployees;
  final String presentCount;
  final String lateCount;
  final String absentCount;
  final List<_TotalsRow> summaryRows;

  _WeeklyDataPackage({
    required this.totalEmployees,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.summaryRows,
  });
}

class _TotalsRow {
  final String left, right;
  const _TotalsRow(this.left, this.right);
}

// --- Reusable Components ---

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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6))],
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
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, height: 1.1)),
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

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.rows});
  final List<_TotalsRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(rows[i].left)),
                  Text(rows[i].right, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            if (i != rows.length - 1) Divider(height: 1, color: Colors.black.withOpacity(0.12)),
          ],
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 6))
          ],
        ),
        child: child, 
      );
}