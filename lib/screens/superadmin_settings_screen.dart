import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/emergency_hotlines_panel.dart';
import '../widgets/safety_tips_and_measures_panel.dart';
import 'package:go_router/go_router.dart';

class SuperadminSettingsScreen extends StatefulWidget {
  const SuperadminSettingsScreen({super.key});

  @override
  State<SuperadminSettingsScreen> createState() =>
      _SuperadminSettingsScreenState();
}

class _SuperadminSettingsScreenState extends State<SuperadminSettingsScreen> {
  bool _handledInitialArgs = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitialArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['showHotlines'] == true) {
          if (selectedSetting != 'Emergency Hotlines') {
            setState(() {
              selectedSetting = 'Emergency Hotlines';
            });
          }
          if (args['addHotline'] == true) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAddHotlineDialog();
            });
          }
        }
      }
      _handledInitialArgs = true;
    }
  }

  // Tips data structure (tabbed, matching user side)
  Map<String, List<Map<String, String>>> tips = {
    'Air': [
      {
        'title': 'Air Quality Index (AQI) - Health Guidelines',
        'content':
            '• 0-50: Good. Outdoor activities are safe.\n'
            '• 51-100: Moderate. Sensitive individuals may reduce outdoor activities.\n'
            '• 101-150: Unhealthy for sensitive groups. Limit outdoor activities, wear masks.\n'
            '• 151-200: Unhealthy. Everyone should avoid prolonged outdoor activities.\n'
            '• 201-300: Very Unhealthy. Stay indoors, use air purifiers.\n'
            '• 301+: Hazardous. Health emergency, stay indoors and follow official guidelines.',
      },
      {
        'title': 'Air Quality Preventive Measures',
        'content':
            '• Ban open burning, monitor emissions\n'
            '• Plant more trees, promote biking\n'
            '• Teach proper waste disposal\n'
            '• Install air quality sensors',
      },
    ],
    'Heat': [
      {
        'title': 'Heat Index - Safety Measures',
        'content':
            '• <26°C: Safe. Normal outdoor activities.\n'
            '• 27-32°C: Caution. Drink water, take breaks.\n'
            '• 33-41°C: Extreme Caution. Limit outdoor activities, wear light clothing.\n'
            '• 42-51°C: Danger. Avoid outdoor activities, stay in cool areas.\n'
            '• >52°C: Extreme Danger. Stay indoors, seek medical help if needed.',
      },
      {
        'title': 'How to Overcome/Prevention',
        'content':
            '• Drink water regularly\n'
            '• Take breaks in shade\n'
            '• Wear light, loose clothing\n'
            '• Adjust schedules during extreme heat',
      },
    ],
    'Flood': [
      {
        'title': 'Flood Safety & Emergency Response',
        'content':
            '• 0-0.5m: Alert Level 1. Prepare emergency kit, monitor updates.\n'
            '• 0.5-1.3m: Alert Level 2. Prepare to evacuate, move valuables up.\n'
            '• 1.3m+: Critical Level 3. Evacuate immediately, do not cross flood waters.',
      },
      {
        'title': 'Flood Safety Tips',
        'content':
            '• Never walk or drive through flood waters\n'
            '• Move to higher ground\n'
            '• Keep emergency kit ready\n'
            '• Listen to official announcements',
      },
    ],
    'Typhoon': [
      {
        'title': 'Typhoon Safety & Preparedness',
        'content':
            '• Signal #1: Secure loose objects\n'
            '• Signal #2: Stay indoors\n'
            '• Signal #3: Suspend classes/work\n'
            '• Signal #4: Complete shutdown\n'
            '• Signal #5: Evacuate if ordered',
      },
      {
        'title': 'Typhoon Preparation Checklist',
        'content':
            '• Prepare emergency kit\n'
            '• Secure windows\n'
            '• Charge devices\n'
            '• Listen to weather updates',
      },
    ],
  };

  final TextEditingController _tipTitleController = TextEditingController();
  final TextEditingController _tipContentController = TextEditingController();
  String selectedTab = 'Air';
  int? editingTipIndex;

  void _showAddTipDialog() {
    _tipTitleController.clear();
    _tipContentController.clear();
    editingTipIndex = null;
    String? titleError;
    String? contentError;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Tip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tipTitleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: titleError,
                ),
              ),
              TextField(
                controller: _tipContentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  errorText: contentError,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  titleError = _tipTitleController.text.trim().isEmpty
                      ? 'Title is required'
                      : null;
                  contentError = _tipContentController.text.trim().isEmpty
                      ? 'Content is required'
                      : null;
                });
                if (titleError == null && contentError == null) {
                  this.setState(() {
                    tips[selectedTab]!.add({
                      'title': _tipTitleController.text,
                      'content': _tipContentController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTipDialog(int index) {
    _tipTitleController.text = tips[selectedTab]![index]['title']!;
    _tipContentController.text = tips[selectedTab]![index]['content']!;
    editingTipIndex = index;
    String? titleError;
    String? contentError;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Tip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tipTitleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  errorText: titleError,
                ),
              ),
              TextField(
                controller: _tipContentController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  errorText: contentError,
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  titleError = _tipTitleController.text.trim().isEmpty
                      ? 'Title is required'
                      : null;
                  contentError = _tipContentController.text.trim().isEmpty
                      ? 'Content is required'
                      : null;
                });
                if (titleError == null && contentError == null) {
                  this.setState(() {
                    tips[selectedTab]![editingTipIndex!] = {
                      'title': _tipTitleController.text,
                      'content': _tipContentController.text,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteTip(int index) {
    setState(() {
      tips[selectedTab]!.removeAt(index);
    });
  }

  // Sample data for System Backup
  List<Map<String, String>> systemBackups = [
    {
      'date': '2025-08-15 14:30',
      'status': 'Completed',
      'file': 'backup_2025_08_15.zip',
    },
    {
      'date': '2025-08-10 09:00',
      'status': 'Completed',
      'file': 'backup_2025_08_10.zip',
    },
    {
      'date': '2025-08-01 18:45',
      'status': 'Failed',
      'file': 'backup_2025_08_01.zip',
    },
  ];

  String? selectedSetting;

  List<Map<String, String>> emergencyHotlines = [
    {'name': 'OFFICE OF THE MAYOR', 'phone': '(02) 8808-2020 loc. 401'},
    {
      'name': 'SAN PEDRO CDRRMO\nSAN PEDRO AKTIBO RESCUE CREW',
      'phone': '(02) 8403-2648',
    },
    {
      'name': 'SAN PEDRO CDRRMO\nSAN PEDRO AKTIBO RESCUE CREW',
      'phone': '0998 594 1743',
    },
    {'name': 'CITY FIRE AUXILIARY UNIT', 'phone': '(02) 8363-9392'},
    {
      'name': 'BUREAU OF FIRE PROTECTION\nCITY OF SAN PEDRO',
      'phone': '(02) 8808-0617',
    },
    {
      'name': 'BUREAU OF FIRE PROTECTION\nCITY OF SAN PEDRO',
      'phone': '0942 834 7377',
    },
    {
      'name': 'SAN PEDRO COMPONENT\nCITY POLICE STATION',
      'phone': '(02) 8567-3381',
    },
    {
      'name': 'SAN PEDRO COMPONENT\nCITY POLICE STATION',
      'phone': '(02) 8641-1548',
    },
    {'name': 'MERALCO', 'phone': '16211'},
    {'name': 'JOSE L. AMANTE\nEMERGENCY HOSPITAL', 'phone': '(02) 8868-5284'},
    {'name': 'JOSE L. AMANTE\nEMERGENCY HOSPITAL', 'phone': '(02) 8478-5709'},
    {'name': 'GAVINO ALVAREZ\nLYING-IN CLINIC', 'phone': '(02) 8519-0249'},
    {'name': 'GAVINO ALVAREZ\nLYING-IN CLINIC', 'phone': '(02) 8478-6270'},
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int? editingIndex;

  void _showAddHotlineDialog() {
    _nameController.clear();
    _phoneController.clear();
    editingIndex = null;
    String? nameError;
    String? phoneError;
    final hotlineRegExp = RegExp(r'^[\d\s\-\+\(\)]+$');
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Emergency Hotline'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: nameError,
                ),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Hotline',
                  errorText: phoneError,
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  nameError = _nameController.text.trim().isEmpty
                      ? 'Name is required'
                      : null;
                  final phoneText = _phoneController.text.trim();
                  if (phoneText.isEmpty) {
                    phoneError = 'Hotline is required';
                  } else if (!hotlineRegExp.hasMatch(phoneText)) {
                    phoneError =
                        'Hotline must contain only numbers or special characters';
                  } else {
                    phoneError = null;
                  }
                });
                if (nameError == null && phoneError == null) {
                  this.setState(() {
                    emergencyHotlines.add({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                    });
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHotlineDialog(int index) {
    _nameController.text = emergencyHotlines[index]['name']!;
    _phoneController.text = emergencyHotlines[index]['phone']!;
    editingIndex = index;
    String? nameError;
    String? phoneError;
    final hotlineRegExp = RegExp(r'^[\d\s\-\+\(\)]+$');
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Emergency Hotline'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: nameError,
                ),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Hotline',
                  errorText: phoneError,
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  nameError = _nameController.text.trim().isEmpty
                      ? 'Name is required'
                      : null;
                  final phoneText = _phoneController.text.trim();
                  if (phoneText.isEmpty) {
                    phoneError = 'Hotline is required';
                  } else if (!hotlineRegExp.hasMatch(phoneText)) {
                    phoneError =
                        'Hotline must contain only numbers or special characters';
                  } else {
                    phoneError = null;
                  }
                });
                if (nameError == null && phoneError == null) {
                  this.setState(() {
                    emergencyHotlines[editingIndex!] = {
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                    };
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteHotline(int index) {
    setState(() {
      emergencyHotlines.removeAt(index);
    });
  }

  Widget _buildRightPanel() {
    if (selectedSetting == 'Emergency Hotlines') {
      return const EmergencyHotlinesPanel();
    } else if (selectedSetting == 'Super Admin Permissions') {
      final List<Map<String, dynamic>> superAdminPermissions = [
        {
          'name': 'Manage Admin',
          'description': 'Add, edit, or remove admin accounts.',
          'enabled': true,
        },
        {
          'name': 'View Dashboard',
          'description': 'Access and view the main dashboard and analytics.',
          'enabled': true,
        },
        {
          'name': 'Manage Emergency Hotlines',
          'description': 'Add, edit, or remove emergency hotline entries.',
          'enabled': true,
        },
        {
          'name': 'System Backup',
          'description': 'Initiate and download system backup files.',
          'enabled': true,
        },
        {
          'name': 'View System Logs',
          'description': 'Access logs of system activities and events.',
          'enabled': true,
        },
        {
          'name': 'Manage Notifications',
          'description':
              'Send, edit, or delete system notifications and alerts.',
          'enabled': true,
        },
        {
          'name': 'Access Settings',
          'description': 'Modify system settings and configurations.',
          'enabled': true,
        },
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Super Admin Permissions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: superAdminPermissions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final perm = superAdminPermissions[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      perm['enabled'] ? Icons.check_circle : Icons.cancel,
                      color: perm['enabled'] ? Colors.green : Colors.red,
                    ),
                    title: Text(perm['name']),
                    subtitle: Text(perm['description']),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (selectedSetting == 'Tips') {
      final categories = [
        {'id': 'air_quality', 'name': 'Air'},
        {'id': 'heat_index', 'name': 'Heat'},
        {'id': 'flood_safety', 'name': 'Flood'},
        {'id': 'typhoon_safety', 'name': 'Typhoon'},
      ];
      return SafetyTipsAndMeasuresPanel(categories: categories);
    }
    // Default placeholder for other settings
    return const Center(
      child: Text(
        'Select a setting from the left to view or manage details.',
        style: TextStyle(color: Colors.black38, fontSize: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: 3,
        role: 'superadmin',
        onLogout: () {
          context.go('/login');
        },
        
        onItemSelected: (index) {
          if (index == 3) return; // Already on Settings
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
        },
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d5f3f),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.settings, color: Colors.white),
            SizedBox(width: 10),
            Text('Settings', style: TextStyle(fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Center(
              child: Text(
                'Welcome, CDRRMO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4FAF4),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side: Settings cards
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Settings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 0,
                      ),
                      children: [
                        _SettingsCard(
                          icon: Icons.group,
                          iconColor: Colors.red,
                          title: 'Emergency Hotlines',
                          buttonColor: Colors.red,
                          onConfigure: () {
                            setState(() {
                              selectedSetting = 'Emergency Hotlines';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsCard(
                          icon: Icons.cloud_upload,
                          iconColor: Colors.green,
                          title: 'System Backup',
                          buttonColor: Colors.green,
                          onConfigure: () {
                            setState(() {
                              selectedSetting = 'System Backup';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsCard(
                          icon: Icons.security,
                          iconColor: Colors.purple,
                          title: 'Super Admin Permissions',
                          buttonColor: Colors.purple,
                          onConfigure: () {
                            setState(() {
                              selectedSetting = 'Super Admin Permissions';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _SettingsCard(
                          icon: Icons.lightbulb_outline,
                          iconColor: Colors.amber,
                          title: 'Tips',
                          buttonColor: Colors.amber,
                          onConfigure: () {
                            setState(() {
                              selectedSetting = 'Tips';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right side: Dynamic content
            Expanded(
              flex: 3,
              child: Container(
                // Remove fixed height and let it expand
                constraints: const BoxConstraints(
                  minHeight: 0,
                  maxHeight: double.infinity,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                padding: const EdgeInsets.all(16),
                child: _buildRightPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color buttonColor;
  final VoidCallback? onConfigure;

  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.buttonColor,
    this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: onConfigure,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text('Configure'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
