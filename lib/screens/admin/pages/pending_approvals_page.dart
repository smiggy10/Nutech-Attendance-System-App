import 'package:flutter/material.dart';
import 'package:nutech_app/theme/app_theme.dart';
import 'package:nutech_app/widgets/nutech_background.dart';
import '../../../services/n8n_api.dart';

// Simple utility class to track rejected employees across screens
class RejectedEmployeesTracker {
  static final Set<String> _rejectedIds = {};

  static void addRejected(String airtableId) {
    _rejectedIds.add(airtableId);
  }

  static bool isRejected(String airtableId) {
    return _rejectedIds.contains(airtableId);
  }

  static List<Map<String, dynamic>> filterRejected(
    List<Map<String, dynamic>> items,
  ) {
    return items.where((item) {
      final airtableId = (item['airtableId'] ?? '').toString();
      return !_rejectedIds.contains(airtableId);
    }).toList();
  }
}

class PendingApprovalsPage extends StatefulWidget {
  const PendingApprovalsPage({super.key});

  @override
  State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
}

class _PendingApprovalsPageState extends State<PendingApprovalsPage> {
  List<Map<String, dynamic>> _pending = [];
  bool _loading = true;
  String? _errorText;
  final Set<String> _actionInProgress = {};
  bool _isBulkProcessing = false;
  int _bulkProcessed = 0;
  int _bulkTotal = 0;
  String? _bulkAction;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final response = await N8nApi.getAdminPending();
      if (!mounted) return;

      final success = response['success'] == true;
      final message = response['message']?.toString();

      if (!success) {
        setState(() {
          _loading = false;
          _errorText = message ?? 'No current pending approvals';
        });
        return;
      }

      final list = response['pending'];
      final items = list is List
          ? List<Map<String, dynamic>>.from(
              list.map(
                (e) => e is Map<String, dynamic> ? e : <String, dynamic>{},
              ),
            )
          : <Map<String, dynamic>>[];

      final filteredItems = RejectedEmployeesTracker.filterRejected(items);

      setState(() {
        _pending = filteredItems;
        _loading = false;
        _errorText = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = 'Failed to load: $e';
      });
    }
  }

  Future<bool> _performAction(
    Map<String, dynamic> item,
    String action, {
    bool showSnackBar = true,
  }) async {
    final airtableId = (item['airtableId'] ?? '').toString();
    final email = (item['email'] ?? '').toString();
    final fullName = (item['fullName'] ?? '').toString();

    if (airtableId.isEmpty || email.isEmpty) {
      setState(() {
        _errorText = 'Missing required fields for this registration.';
      });
      return false;
    }

    setState(() {
      _actionInProgress.add(airtableId);
      _errorText = null;
    });

    var didSucceed = false;
    try {
      final response = await N8nApi.adminAction(
        airtableId: airtableId,
        email: email,
        fullName: fullName,
        action: action,
      );

      if (!mounted) return false;

      final success = response['success'] == true;
      final message = response['message']?.toString() ?? '';
      didSucceed = success;

      if (showSnackBar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : (action == 'Accept'
                      ? 'Employee accepted successfully.'
                      : 'Registration rejected successfully.'),
            ),
            backgroundColor:
                success
                    ? (action == 'Accept' ? Colors.green : Colors.red)
                    : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (success) {
        setState(() {
          _pending.removeWhere(
            (row) => row['airtableId'].toString() == airtableId,
          );
        });

        if (action == 'Reject') {
          RejectedEmployeesTracker.addRejected(airtableId);
        }
      } else if (message.isNotEmpty) {
        setState(() {
          _errorText = message;
        });
      }
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        _errorText = 'Request failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _actionInProgress.remove(airtableId);
        });
      }
    }

    return didSucceed;
  }

  Future<void> _handleAction(Map<String, dynamic> item, String action) async {
    if (_isBulkProcessing || _actionInProgress.isNotEmpty) return;
    await _performAction(item, action);
  }

  Future<bool> _confirmBulkAction(String action) async {
    final verb = action == 'Accept' ? 'accept' : 'reject';
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${action} All Employees'),
            content: Text(
              'Are you sure you want to $verb all pending employees?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      action == 'Accept' ? AppTheme.teal : const Color(0xFFE24B33),
                ),
                child: Text('$action All'),
              ),
            ],
          ),
    );
    return result == true;
  }

  Future<void> _runBulkAction(String action) async {
    if (_isBulkProcessing || _loading || _pending.isEmpty) return;

    final confirmed = await _confirmBulkAction(action);
    if (!confirmed || !mounted) return;

    final queue = List<Map<String, dynamic>>.from(_pending);
    final initialCount = queue.length;
    var successCount = 0;

    setState(() {
      _isBulkProcessing = true;
      _bulkAction = action;
      _bulkProcessed = 0;
      _bulkTotal = initialCount;
      _errorText = null;
    });

    for (final item in queue) {
      if (!mounted) return;
      final ok = await _performAction(item, action, showSnackBar: false);
      if (ok) successCount++;
      if (!mounted) return;
      setState(() {
        _bulkProcessed += 1;
      });
    }

    if (!mounted) return;
    setState(() {
      _isBulkProcessing = false;
      _bulkAction = null;
      _bulkProcessed = 0;
      _bulkTotal = 0;
    });

    final failedCount = initialCount - successCount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failedCount == 0
              ? '$action All completed: $successCount employee${successCount == 1 ? '' : 's'} processed.'
              : '$action All finished: $successCount succeeded, $failedCount failed.',
        ),
        backgroundColor: failedCount == 0 ? Colors.green : Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar completely to remove top navigation bar
      body: NutechBackground(
        bottomAsset: 'assets/images/ui/bottombackground2.png',
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Branding Header - Logo now acts as the refresh trigger
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: GestureDetector(
                          onTap: (_loading || _actionInProgress.isNotEmpty) ? null : _loadPending,
                          child: Container(
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
                      ),
                      
                      // Removed the "Pending Approvals" Text and Dividers section here
                      
                      const SizedBox(height: 10),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorText != null && _pending.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_errorText!,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: _loadPending,
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else if (_pending.isEmpty && _errorText == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No pending registrations',
                              style: TextStyle(fontSize: 16, color: AppTheme.muted),
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _TableCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_errorText != null) ...[
                                  Text(_errorText!,
                                      style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                                  const SizedBox(height: 10),
                                ],
                                const Padding(
                                  padding: EdgeInsets.only(left: 4, bottom: 10),
                                  child: Text('Employees',
                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: ElevatedButton.icon(
                                          onPressed: (_isBulkProcessing ||
                                                  _actionInProgress.isNotEmpty ||
                                                  _pending.isEmpty)
                                              ? null
                                              : () => _runBulkAction('Accept'),
                                          icon: const Icon(Icons.done_all, size: 18),
                                          label: const Text(
                                            'Accept All',
                                            style: TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.teal,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 42,
                                        child: ElevatedButton.icon(
                                          onPressed: (_isBulkProcessing ||
                                                  _actionInProgress.isNotEmpty ||
                                                  _pending.isEmpty)
                                              ? null
                                              : () => _runBulkAction('Reject'),
                                          icon: const Icon(Icons.clear_all, size: 18),
                                          label: const Text(
                                            'Reject All',
                                            style: TextStyle(fontWeight: FontWeight.w700),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFE24B33),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isBulkProcessing) ...[
                                  const SizedBox(height: 10),
                                  LinearProgressIndicator(
                                    value: _bulkTotal == 0
                                        ? null
                                        : _bulkProcessed / _bulkTotal,
                                    color: _bulkAction == 'Accept'
                                        ? AppTheme.teal
                                        : const Color(0xFFE24B33),
                                    backgroundColor: Colors.black.withOpacity(0.08),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${_bulkAction ?? 'Processing'} ${_bulkProcessed.toString()}/${_bulkTotal.toString()}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(0.6),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _pending.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = _pending[index];
                                    return _buildEmployeeRow(item);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Action Button (Back)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _actionInProgress.isNotEmpty ? null : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE6E7EA),
                      foregroundColor: const Color(0xFF5B5F66),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Back',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeRow(Map<String, dynamic> item) {
    final airtableId = (item['airtableId'] ?? '').toString();
    final fullName = (item['fullName'] ?? '').toString();
    final email = (item['email'] ?? '').toString();
    final contactNumber = (item['contactNumber'] ?? '').toString();

    final isProcessingThisRow = _actionInProgress.contains(airtableId);
    final isAnyActionInProgress = _actionInProgress.isNotEmpty || _isBulkProcessing;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFF5B5F66),
                child: Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName.isNotEmpty ? fullName : '—',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email.isNotEmpty ? email : '—',
                      style: const TextStyle(fontSize: 13, color: AppTheme.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppTheme.muted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            contactNumber.isNotEmpty ? contactNumber : '—',
                            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.muted.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isAnyActionInProgress ? null : () => _handleAction(item, 'Accept'),
                    child: isProcessingThisRow
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 20, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Accept',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE24B33),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppTheme.muted.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: isAnyActionInProgress ? null : () => _handleAction(item, 'Reject'),
                    child: isProcessingThisRow
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 20, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Reject',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ],
                          ),
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}