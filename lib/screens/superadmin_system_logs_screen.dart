import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import 'package:go_router/go_router.dart';

class SuperAdminSystemLogsScreen extends StatefulWidget {
  const SuperAdminSystemLogsScreen({super.key});

  @override
  State<SuperAdminSystemLogsScreen> createState() =>
      _SuperAdminSystemLogsScreenState();
}

class _SuperAdminSystemLogsScreenState
    extends State<SuperAdminSystemLogsScreen> {
  void _onDrawerItemSelected(int index) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final isSuperadmin = args is Map && args['role'] == 'superadmin';

      if (isSuperadmin) {
      // Superadmin drawer: [0:Dashboard, 1:AdminMgmt, 2:Notif, 3:Settings, 4:SystemLogs, 5:UserMgmt]
      switch (index) {
        case 0:
          context.go('/superadmin-dashboard?role=superadmin');
          break;
        case 1:
          context.go('/admins?role=superadmin');
          break;
        case 2:
          context.go('/superadmin-notifications?role=superadmin');
          break;
        case 3:
          context.go('/superadmin-settings?role=superadmin');
          break;
        case 4:
          context.go('/superadmin-system-logs?role=superadmin');
          break;
        case 5:
          context.go('/users?role=superadmin');
          break;
      }
    } else {
      // Admin drawer: [0:Dashboard, 1:UserMgmt, 2:Notif, 3:Settings, 4:SystemLogs]
      switch (index) {
        case 0:
          context.go('/dashboard?role=admin');
          break;
        case 1:
          context.go('/users?role=admin');
          break;
        case 2:
          context.go('/notifications?role=admin');
          break;
        case 3:
          context.go('/settings?role=admin');
          break;
        case 4:
          context.go('/system-logs?role=admin');
          break;
      }
    }
  }

  void _onLogout() {
    context.go('/login');
  }

  // Comprehensive sample log data combining both versions
  final List<Map<String, dynamic>> _superAdminSystemLogs = [
    {
      'dateTime': '2025-01-15 14:35',
      'user': 'CDRRMO Admin',
      'action': 'Notification Posted',
      'category': 'Content Management',
      'status': 'Success',
      'details':
          'Posted emergency alert: Flash flood warning for Barangay Central',
      'icon': Icons.notifications,
      'color': Colors.green,
      'severity': 'High',
    },
    {
      'dateTime': '2025-01-15 14:30',
      'user': 'CDRRMO Admin',
      'action': 'User Login',
      'category': 'Authentication',
      'status': 'Success',
      'details': 'Admin successfully logged into the system',
      'icon': Icons.login,
      'color': Colors.blue,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-15 13:20',
      'user': 'System Admin',
      'action': 'User Account Created',
      'category': 'User Management',
      'status': 'Success',
      'details': 'New user account created for Maria Santos',
      'icon': Icons.person_add,
      'color': Colors.purple,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-15 12:15',
      'user': 'System Admin',
      'action': 'Emergency Hotline Updated',
      'category': 'System Configuration',
      'status': 'Success',
      'details': 'Updated Fire Department hotline: 117 -> 911-FIRE',
      'icon': Icons.phone,
      'color': Colors.orange,
      'severity': 'High',
    },
    {
      'dateTime': '2025-01-15 11:45',
      'user': 'CDRRMO Admin',
      'action': 'Alert Deactivated',
      'category': 'Content Management',
      'status': 'Success',
      'details': 'Deactivated weather advisory alert',
      'icon': Icons.notifications_off,
      'color': Colors.grey,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-15 11:20',
      'user': 'System Admin',
      'action': 'User Role Updated',
      'category': 'User Management',
      'status': 'Success',
      'details': 'Changed John Doe role from Volunteer to Emergency Responder',
      'icon': Icons.security,
      'color': Colors.indigo,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-15 10:30',
      'user': 'CDRRMO Admin',
      'action': 'Mass Notification Sent',
      'category': 'Content Management',
      'status': 'Success',
      'details': 'Emergency evacuation notice sent to 1,247 mobile users',
      'icon': Icons.campaign,
      'color': Colors.red,
      'severity': 'Critical',
    },
    {
      'dateTime': '2025-01-15 09:15',
      'user': 'System Admin',
      'action': 'Database Backup',
      'category': 'System Maintenance',
      'status': 'Success',
      'details': 'Automatic daily backup completed successfully (2.4GB)',
      'icon': Icons.backup,
      'color': Colors.green,
      'severity': 'Low',
    },
    {
      'dateTime': '2025-01-15 08:45',
      'user': 'CDRRMO Admin',
      'action': 'Login Attempt Failed',
      'category': 'Authentication',
      'status': 'Failed',
      'details': 'Invalid password attempt from IP: 192.168.1.100',
      'icon': Icons.error,
      'color': Colors.red,
      'severity': 'Critical',
    },
    {
      'dateTime': '2025-01-15 08:00',
      'user': 'System Admin',
      'action': 'System Restart',
      'category': 'System Maintenance',
      'status': 'Success',
      'details': 'System successfully restarted for maintenance updates',
      'icon': Icons.restart_alt,
      'color': Colors.blue,
      'severity': 'High',
    },
    {
      'dateTime': '2025-01-14 23:30',
      'user': 'Auto System',
      'action': 'Data Synchronization',
      'category': 'System Maintenance',
      'status': 'Success',
      'details': 'Mobile app data synchronized with central database',
      'icon': Icons.sync,
      'color': Colors.teal,
      'severity': 'Low',
    },
    {
      'dateTime': '2025-01-14 22:15',
      'user': 'CDRRMO Admin',
      'action': 'Emergency Contact Added',
      'category': 'System Configuration',
      'status': 'Success',
      'details': 'Added new emergency contact: Rescue Team Alpha (09123456789)',
      'icon': Icons.contact_emergency,
      'color': Colors.orange,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-14 21:45',
      'user': 'System Admin',
      'action': 'User Account Deleted',
      'category': 'User Management',
      'status': 'Success',
      'details': 'Deleted inactive user account: John Smith',
      'icon': Icons.person_remove,
      'color': Colors.red,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-14 20:30',
      'user': 'CDRRMO Admin',
      'action': 'Alert Template Created',
      'category': 'Content Management',
      'status': 'Success',
      'details': 'Created new alert template for typhoon warnings',
      'icon': Icons.edit_notifications,
      'color': Colors.purple,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-14 19:15',
      'user': 'System Admin',
      'action': 'Permission Updated',
      'category': 'User Management',
      'status': 'Success',
      'details': 'Updated admin permissions for CDRRMO Admin',
      'icon': Icons.admin_panel_settings,
      'color': Colors.green,
      'severity': 'High',
    },
    {
      'dateTime': '2025-01-14 18:00',
      'user': 'Auto System',
      'action': 'Log Cleanup',
      'category': 'System Maintenance',
      'status': 'Success',
      'details': 'Cleaned up old system logs (30 days+)',
      'icon': Icons.cleaning_services,
      'color': Colors.blue,
      'severity': 'Low',
    },
    {
      'dateTime': '2025-01-14 17:45',
      'user': 'CDRRMO Admin',
      'action': 'User Export',
      'category': 'User Management',
      'status': 'Success',
      'details': 'Exported user list to CSV format (250 users)',
      'icon': Icons.download,
      'color': Colors.green,
      'severity': 'Low',
    },
    {
      'dateTime': '2025-01-14 16:30',
      'user': 'System Admin',
      'action': 'Security Scan',
      'category': 'System Maintenance',
      'status': 'Warning',
      'details':
          'Completed automated security vulnerability scan - 2 minor issues found',
      'icon': Icons.security,
      'color': Colors.orange,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-14 15:15',
      'user': 'CDRRMO Admin',
      'action': 'Notification Scheduled',
      'category': 'Content Management',
      'status': 'Success',
      'details': 'Scheduled weather update notification for tomorrow 6AM',
      'icon': Icons.schedule_send,
      'color': Colors.orange,
      'severity': 'Medium',
    },
    {
      'dateTime': '2025-01-14 14:00',
      'user': 'System Admin',
      'action': 'Configuration Update',
      'category': 'System Configuration',
      'status': 'Success',
      'details': 'Updated mobile app configuration settings',
      'icon': Icons.settings,
      'color': Colors.grey,
      'severity': 'Low',
    },
    {
      'dateTime': '2025-01-14 13:30',
      'user': 'Unknown User',
      'action': 'Unauthorized Access Attempt',
      'category': 'Security',
      'status': 'Failed',
      'details': 'Failed login attempt with invalid credentials',
      'icon': Icons.warning,
      'color': Colors.red,
      'severity': 'Critical',
    },
    {
      'dateTime': '2025-01-14 12:45',
      'user': 'Auto System',
      'action': 'Performance Monitor',
      'category': 'System Maintenance',
      'status': 'Warning',
      'details': 'CPU usage exceeded 85% threshold for 10 minutes',
      'icon': Icons.monitor,
      'color': Colors.orange,
      'severity': 'Medium',
    },
  ];

  // Enhanced filter variables - ALL FEATURES COMBINED
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedSeverity = 'All';
  String _selectedDateRange = 'All Time';
  // bool _isCompactView = true; // Removed: always use detailed view

  // Filtered logs
  List<Map<String, dynamic>> _filteredLogs = [];

  @override
  void initState() {
    super.initState();
    _filteredLogs = List.from(_superAdminSystemLogs);
    // Debug print to check if logs are loaded
    // ignore: avoid_print
    print(
      'SuperAdminSystemLogsScreen: _superAdminSystemLogs.length = \\${_superAdminSystemLogs.length}, _filteredLogs.length = \\${_filteredLogs.length}',
    );
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_superAdminSystemLogs);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        return log['user'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            log['action'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            log['details'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            log['category'].toString().toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((log) => log['category'] == _selectedCategory)
          .toList();
    }

    // Apply status filter
    if (_selectedStatus != 'All') {
      filtered = filtered
          .where((log) => log['status'] == _selectedStatus)
          .toList();
    }

    // Apply severity filter
    if (_selectedSeverity != 'All') {
      filtered = filtered
          .where((log) => log['severity'] == _selectedSeverity)
          .toList();
    }

    // Apply date range filter
    DateTime now = DateTime.now();
    if (_selectedDateRange == 'Today') {
      String today = now.toString().split(' ')[0];
      filtered = filtered
          .where((log) => log['dateTime'].startsWith(today))
          .toList();
    } else if (_selectedDateRange == 'Yesterday') {
      final yesterday = now.subtract(const Duration(days: 1));
      String yest = yesterday.toString().split(' ')[0];
      filtered = filtered
          .where((log) => log['dateTime'].startsWith(yest))
          .toList();
    } else if (_selectedDateRange == 'Last 7 Days') {
      final last7 = now.subtract(const Duration(days: 7));
      filtered = filtered.where((log) {
        DateTime? logDate = DateTime.tryParse(log['dateTime']);
        return logDate != null && logDate.isAfter(last7);
      }).toList();
    } else if (_selectedDateRange == 'Last 14 Days') {
      final last14 = now.subtract(const Duration(days: 14));
      filtered = filtered.where((log) {
        DateTime? logDate = DateTime.tryParse(log['dateTime']);
        return logDate != null && logDate.isAfter(last14);
      }).toList();
    } else if (_selectedDateRange == 'Last 30 Days (1 month)') {
      final last30 = now.subtract(const Duration(days: 30));
      filtered = filtered.where((log) {
        DateTime? logDate = DateTime.tryParse(log['dateTime']);
        return logDate != null && logDate.isAfter(last30);
      }).toList();
    } else if (_selectedDateRange == 'Last 90 Days (3 months)') {
      final last90 = now.subtract(const Duration(days: 90));
      filtered = filtered.where((log) {
        DateTime? logDate = DateTime.tryParse(log['dateTime']);
        return logDate != null && logDate.isAfter(last90);
      }).toList();
    }

    setState(() {
      _filteredLogs = filtered;
      // Debug print to check filtered logs after applying filters
      // ignore: avoid_print
      print(
        'APPLY FILTERS: _superAdminSystemLogs.length = \\${_superAdminSystemLogs.length}, _filteredLogs.length = \\${_filteredLogs.length}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSuperadmin =
        (ModalRoute.of(context)?.settings.arguments is Map &&
        (ModalRoute.of(context)?.settings.arguments as Map)['role'] ==
            'superadmin');
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F7),
      drawer: AdminDrawer(
        selectedIndex: 4,
        role: isSuperadmin ? 'superadmin' : 'admin', // <-- FIXED HERE!
        onItemSelected: _onDrawerItemSelected,
        onLogout: _onLogout,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d5f3f),
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.list_alt_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'System Logs',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Welcome, CDRRMO',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... (rest of your widget tree unchanged) ...
              const Text(
                'System Activity Logs',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Stay informed on what’s happening behind the scenes',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              // Search and filter row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search logs by user, action, details...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Filters row
              Row(
                children: [
                  // Category
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items:
                          [
                                'All',
                                'User Management',
                                'Authentication',
                                'Content Management',
                                'System Maintenance',
                                'System Configuration',
                                'Security',
                              ]
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text('  $cat'),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val!;
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: ['All', 'Success', 'Failed', 'Warning']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text('  $status'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val!;
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Date Range
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedDateRange,
                      items:
                          [
                                'All Time',
                                'Today',
                                'Yesterday',
                                'Last 7 Days',
                                'Last 14 Days',
                                'Last 30 Days (1 month)',
                                'Last 90 Days (3 months)',
                              ]
                              .map(
                                (range) => DropdownMenuItem(
                                  value: range,
                                  child: Text('  $range'),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDateRange = val!;
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: 'Date Range',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Severity
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSeverity,
                      items: ['All', 'Low', 'Medium', 'High', 'Critical']
                          .map(
                            (sev) => DropdownMenuItem(
                              value: sev,
                              child: Text('  $sev'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedSeverity = val!;
                        });
                        _applyFilters();
                      },
                      decoration: InputDecoration(
                        labelText: 'Severity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Summary badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2d5f3f).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${_filteredLogs.length} of ${_superAdminSystemLogs.length} logs',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d5f3f),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        Text(
                          '${_filteredLogs.where((log) => log['status'] == 'Success').length} Success',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Text(
                          '${_filteredLogs.where((log) => log['status'] == 'Failed').length} Failed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Export button
                  PopupMenuButton<String>(
                    onSelected: (String format) {
                      _exportLogs(format);
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<String>(
                        value: 'xlsx',
                        child: Row(
                          children: [
                            Icon(
                              Icons.table_chart,
                              size: 18,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Export as XLSX',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'pdf',
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 18,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Export as PDF',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'xml',
                        child: Row(
                          children: [
                            Icon(Icons.code, size: 18, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'Export as XML',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.download,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Export',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Logs Table
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2d5f3f),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  'Date/Time ↓',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  'User',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'Action',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  'Status',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: Text(
                                  'Severity',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Table Body (scrollable)
                      Expanded(
                        child: _filteredLogs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _superAdminSystemLogs.isEmpty
                                          ? 'No system logs available.'
                                          : 'No logs match your search or filter.',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _superAdminSystemLogs.isEmpty
                                          ? 'System logs will appear here when available.'
                                          : 'Try adjusting your search or filter criteria.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredLogs.length,
                                itemBuilder: (context, index) {
                                  return _buildReadableDetailedLogRow(
                                    _filteredLogs[index],
                                    index,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // ...existing code...
  }

  // READABLE Compact log row - Shows ~10-12 logs per screen with normal text
  Widget _buildReadableCompactLogRow(Map<String, dynamic> log, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ), // Comfortable padding
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Date/Time (readable)
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  log['dateTime'].split(' ')[0],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  log['dateTime'].split(' ')[1],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // User (with status dot)
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: log['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    log['user'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Action
          SizedBox(
            width: 170,
            child: Row(
              children: [
                Icon(log['icon'], size: 18, color: log['color']),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        log['action'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        log['category'],
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status
          SizedBox(
            width: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: log['status'] == 'Success'
                    ? Colors.green.withValues(alpha: 0.1)
                    : log['status'] == 'Failed'
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: log['status'] == 'Success'
                      ? Colors.green
                      : log['status'] == 'Failed'
                      ? Colors.red
                      : Colors.orange,
                  width: 1,
                ),
              ),
              child: Text(
                log['status'],
                style: TextStyle(
                  color: log['status'] == 'Success'
                      ? Colors.green
                      : log['status'] == 'Failed'
                      ? Colors.red
                      : Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Details
          SizedBox(
            width: 420,
            child: Text(
              log['details'],
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  // READABLE Detailed log row with all information
  Widget _buildReadableDetailedLogRow(Map<String, dynamic> log, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Date/Time
          Expanded(
            flex: 2,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    log['dateTime'].split(' ')[0],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    log['dateTime'].split(' ')[1],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          // User
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: log['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    log['user'],
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Action
          Expanded(
            flex: 3,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log['icon'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      log['icon'],
                      size: 20,
                      color: log['color'] ?? Colors.black,
                    ),
                  ),
                if (log['icon'] != null) const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        log['action'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 18,
                        ), // Increased indent for subtitle
                        child: Text(
                          log['category'] ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: log['status'] == 'Success'
                      ? Colors.green.withOpacity(0.1)
                      : log['status'] == 'Failed'
                      ? Colors.red.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: log['status'] == 'Success'
                        ? Colors.green
                        : log['status'] == 'Failed'
                        ? Colors.red
                        : Colors.orange,
                    width: 1,
                  ),
                ),
                child: Text(
                  log['status'],
                  style: TextStyle(
                    color: log['status'] == 'Success'
                        ? Colors.green
                        : log['status'] == 'Failed'
                        ? Colors.red
                        : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Severity
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSeverityColor(log['severity']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getSeverityColor(log['severity']),
                    width: 1,
                  ),
                ),
                child: Text(
                  log['severity'],
                  style: TextStyle(
                    color: _getSeverityColor(log['severity']),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          // Details
          Expanded(
            flex: 5,
            child: Text(
              log['details'],
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.orange;
      case 'Medium':
        return Colors.blue;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Enhanced Export Function with Multiple Formats
  void _exportLogs(String format) {
    String message;
    Color backgroundColor;
    IconData icon;

    switch (format) {
      case 'xlsx':
        message = '${_filteredLogs.length} logs exported to XLSX successfully!';
        backgroundColor = Colors.green;
        icon = Icons.table_chart;
        break;
      case 'pdf':
        message = '${_filteredLogs.length} logs exported to PDF successfully!';
        backgroundColor = Colors.red;
        icon = Icons.picture_as_pdf;
        break;
      case 'xml':
        message = '${_filteredLogs.length} logs exported to XML successfully!';
        backgroundColor = Colors.orange;
        icon = Icons.code;
        break;
      default:
        message = 'Export completed successfully!';
        backgroundColor = Colors.blue;
        icon = Icons.download;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Here you would implement actual file viewing logic
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${format.toUpperCase()} file...'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
