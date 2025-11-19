import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/user_role_pie_chart.dart';
import '../widgets/new_users_bar_chart.dart';
import '../widgets/notifications_line_chart.dart';
import '../widgets/post_category_pie_chart.dart';
import '../widgets/system_errors_bar_chart.dart';
import '../widgets/logins_timeline_chart.dart';
import 'users_management_screen.dart';
import 'package:go_router/go_router.dart';


class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  void _showUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(width: 900, height: 600, child: UsersScreen()),
      ),
    );
  }

  void _onDrawerItemSelected(int index) {
    if (index == 0) {
      context.go('/superadmin-dashboard?role=superadmin');
      return;
    }
    switch (index) {
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
  }
  void _onLogout() {
    context.go('/login');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: 0,
        role: 'superadmin',
        onItemSelected: _onDrawerItemSelected,
        onLogout: _onLogout,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.dashboard_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Superadmin Dashboard',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Color(0xFF2d5f3f),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 24.0),
            child: Center(
              child: Text(
                'Welcome, Superadmin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: const Color(0xFF2d5f3f),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(Icons.warning, color: Colors.white, size: 48),
                            SizedBox(height: 12),
                            Text(
                              'CDRRMO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Warning System',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 8),
                            Chip(
                              label: Text(
                                'ONLINE',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                    Flexible(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                            Icons.admin_panel_settings,
                            '6', // Update this to match your actual admin count if needed
                            'Admins',
                            onTap: () => _showCardModal(
                              'Admins',
                              icon: Icons.admin_panel_settings,
                              value: '6',
                            ),
                          ),
                          _buildSummaryCard(
                            Icons.contact_phone,
                            '5',
                            'Emergency Hotlines',
                            onTap: () => _showCardModal(
                              'Emergency Hotlines',
                              icon: Icons.contact_phone,
                              value: '5',
                            ),
                          ),
                          _buildSummaryCard(
                            Icons.notifications_active,
                            '3',
                            'Alerts',
                            onTap: () => _showCardModal(
                              'Alerts',
                              icon: Icons.notifications_active,
                              value: '3',
                            ),
                          ),
                          _buildSummaryCard(
                            Icons.people,
                            '4',
                            'Users',
                            onTap: () => _showCardModal(
                              'Users',
                              icon: Icons.people,
                              value: '4',
                            ),
                          ),
                          _buildSummaryCard(
                            Icons.admin_panel_settings,
                            'ONLINE',
                            'Superadmin',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            const Text(
              'A quick snapshot of everything that matters',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.pie_chart, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'User Roles Distribution',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Shows the proportion of Emergency Responders, Community Leaders, and Users in the system.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const UserRolePieChart(),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey[200],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.bar_chart, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'New Users Per Month',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Displays the number of new users registered each month.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const NewUsersBarChart(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: 650, // Make the card taller for balance
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.show_chart, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  'Notifications Sent Over Time',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Visualizes the number of notifications sent to users over time.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.6, // Wider for line chart
                                child: NotificationsLineChart(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.pie_chart, color: Colors.black54),
                                SizedBox(width: 8),
                                Text(
                                  'Post Category Distribution',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Shows the breakdown of posts by their assigned categories.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color.fromARGB(255, 194, 194, 194),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: PostCategoryPieChart(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.settings, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'System Errors by Type',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Displays the frequency of different error types encountered by the system.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const SystemErrorsBarChart(),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 200,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.grey[200],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.show_chart, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Logins by Time of Day',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Shows when users are most active by tracking logins throughout the day.',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const LoginsTimelineChart(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    IconData icon,
    String value,
    String label, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: const Color(0xFF43A047),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCardModal(String label, {IconData? icon, String? value}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: const Color(0xFF43A047)),
            if (icon != null) const SizedBox(width: 8),
            Text(label),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ],
        ),
        content: const Text('Choose an action:'),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSection(label, 'view');
            },
            icon: const Icon(Icons.visibility, color: Color(0xFF43A047)),
            label: const Text(
              'View',
              style: TextStyle(color: Color(0xFF43A047)),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToSection(label, 'add');
            },
            icon: const Icon(Icons.add, color: Color(0xFF43A047)),
            label: const Text(
              'Add',
              style: TextStyle(color: Color(0xFF43A047)),
            ),
          ),
        ],
      ),
    );
  }

 void _navigateToSection(String label, String action) {
    // We'll use context.go with query params instead of Navigator
    if (label == 'Admins') {
      if (action == 'view') {
        context.go('/admins?role=superadmin');
      } else if (action == 'add') {
        context.go('/admins?role=superadmin&showAddAdmin=true');
      }
    } else if (label == 'Emergency Hotlines') {
      if (action == 'view') {
        context.go('/superadmin-settings?role=superadmin&showHotlines=true');
      } else if (action == 'add') {
        context.go('/superadmin-settings?role=superadmin&showHotlines=true&addHotline=true');
      }
    } else if (label == 'Alerts') {
      if (action == 'view') {
        context.go('/superadmin-notifications?role=superadmin');
      } else if (action == 'add') {
        context.go('/superadmin-notifications?role=superadmin&showAddAlert=true');
      }
    } else if (label == 'Users') {
      if (action == 'view') {
        context.go('/users?role=superadmin');
      } else if (action == 'add') {
        context.go('/users?role=superadmin&showAddUser=true');
      }
    }
  }
}
