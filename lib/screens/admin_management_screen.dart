import 'package:flutter/material.dart';
import '../widgets/admin_drawer.dart';
import 'package:flutter/services.dart';
import '../services/admin_management_service.dart';

class AdminManagementScreen extends StatefulWidget {
  final String role;
  const AdminManagementScreen({super.key, this.role = 'admin'});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final AdminManagementService _adminService = AdminManagementService();

  List<Map<String, dynamic>> _admins = [];
  List<Map<String, dynamic>> _filteredAdmins = [];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roleController = TextEditingController();
  String _selectedRole = 'admin';
  String? _editingAdminId;

  // Filtering and sorting
  String _adminSearchQuery = '';
  String _selectedRoleFilter = 'All';
  String _sortBy = 'username';
  bool _sortAscending = true;

  bool _handledInitialArgs = false;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  Future<void> _fetchAdmins() async {
    final admins = await _adminService.fetchAdmins();
    setState(() {
      _admins = admins;
      _applyFiltersAndSorting();
    });
  }

  void _applyFiltersAndSorting() {
    List<Map<String, dynamic>> filtered = List.from(_admins);
    if (_adminSearchQuery.isNotEmpty) {
      filtered = filtered.where((admin) {
        return (admin['username'] ?? '').toLowerCase().contains(
              _adminSearchQuery.toLowerCase(),
            ) ||
            (admin['email'] ?? '').toLowerCase().contains(
              _adminSearchQuery.toLowerCase(),
            );
      }).toList();
    }
    if (_selectedRoleFilter != 'All') {
      filtered = filtered
          .where((admin) => admin['role'] == _selectedRoleFilter)
          .toList();
    }
    filtered.sort((a, b) {
      String aValue = '';
      String bValue = '';
      switch (_sortBy) {
        case 'username':
          aValue = a['username'] ?? '';
          bValue = b['username'] ?? '';
          break;
        case 'email':
          aValue = a['email'] ?? '';
          bValue = b['email'] ?? '';
          break;
        case 'role':
          aValue = a['role'] ?? '';
          bValue = b['role'] ?? '';
          break;
      }
      int comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      return _sortAscending ? comparison : -comparison;
    });
    setState(() {
      _filteredAdmins = filtered;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_handledInitialArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['showAddUser'] == true || args['showAddAdmin'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAddAdminDialog();
          });
        }
      }
      _handledInitialArgs = true;
    }
  }

  void _showAddAdminDialog() {
    _clearForm();
    _editingAdminId = null;
    _showAdminDialog('Add Admin');
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    _nameController.text = admin['username'] ?? '';
    _emailController.text = admin['email'] ?? '';
    _selectedRole = admin['role'] ?? 'admin';
    _editingAdminId = admin['id'];
    _showAdminDialog('Edit Admin');
  }

  void _showAdminDialog(String title) {
    String? nameError;
    String? emailError;
    bool showAllErrors = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void validateFields() {
              setDialogState(() {
                nameError = null;
                emailError = null;
                if (_nameController.text.trim().isEmpty) {
                  nameError = 'Username is required';
                }
                if (_emailController.text.trim().isEmpty) {
                  emailError = 'Email is required';
                } else if (!_emailController.text.contains('@')) {
                  emailError = 'Invalid email';
                }
              });
            }

            void showAllFieldErrors() {
              setDialogState(() {
                showAllErrors = true;
              });
              validateFields();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              validateFields();
            });

            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[a-zA-Z0-9_]+$'),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Username *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                          errorText:
                              (showAllErrors || _nameController.text.isNotEmpty)
                              ? nameError
                              : null,
                        ),
                        onChanged: (_) => validateFields(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.email),
                          errorText:
                              (showAllErrors ||
                                  _emailController.text.isNotEmpty)
                              ? emailError
                              : null,
                        ),
                        onChanged: (_) => validateFields(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: (['superadmin', 'admin'].contains(_selectedRole))
                            ? _selectedRole
                            : 'admin',
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'superadmin',
                            child: Text('Superadmin'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedRole = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        showAllFieldErrors();
                        if (nameError == null && emailError == null) {
                          _validateAndSaveAdmin(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2d5f3f),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _validateAndSaveAdmin(BuildContext dialogContext) async {
    if (_editingAdminId == null) {
      await _adminService.addAdmin({
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✅ Success! Admin "${_nameController.text.trim()}" has been added to the system',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      await _adminService.editAdmin(_editingAdminId!, {
        'username': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✅ Success! Admin "${_nameController.text.trim()}" has been updated successfully',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    Navigator.of(dialogContext).pop();
    await _fetchAdmins();
    _clearForm();
  }

  void _showDeleteConfirmation(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text(
            'Are you sure you want to delete ${admin['username']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAdmin(admin['id']);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAdmin(String adminId) async {
    await _adminService.deleteAdmin(adminId);
    await _fetchAdmins();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Admin deleted successfully!')),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _selectedRole = 'admin';
    _editingAdminId = null;
  }

  void _exportAdmins(String format) {
    String message;
    switch (format) {
      case 'xlsx':
        message = 'Admins exported as XLSX file successfully!';
        break;
      case 'pdf':
        message = 'Admins exported as PDF file successfully!';
        break;
      default:
        message = 'Export completed!';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              format == 'xlsx'
                  ? Icons.table_chart
                  : format == 'pdf'
                  ? Icons.picture_as_pdf
                  : Icons.code,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: 1,
        role: widget.role,
        // ... (drawer navigation code unchanged)
        onItemSelected: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              if (widget.role == 'superadmin') {
                Navigator.pushReplacementNamed(
                  context,
                  '/superadmin-dashboard',
                  arguments: {'role': 'superadmin'},
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  '/dashboard',
                  arguments: {'role': widget.role},
                );
              }
              break;
            case 1:
              Navigator.pushReplacementNamed(
                context,
                '/admins',
                arguments: {'role': widget.role},
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                widget.role == 'superadmin'
                    ? '/superadmin-notifications'
                    : '/notifications',
                arguments: {'role': widget.role},
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(
                context,
                '/superadmin-settings',
                arguments: {'role': widget.role},
              );
              break;
            case 4:
              Navigator.pushReplacementNamed(
                context,
                '/superadmin-system-logs',
                arguments: {'role': widget.role},
              );
              break;
            case 5:
              Navigator.pushReplacementNamed(
                context,
                '/users',
                arguments: {'role': widget.role},
              );
          }
        },
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: const Color(0xFF2d5f3f),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.admin_panel_settings, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Admin Management',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                child: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              const Positioned(
                right: 24,
                child: Text(
                  'Welcome, Superadmin',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top controls (search, filter, add, export)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Admin Management',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2d5f3f),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage admin accounts for the system',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String format) => _exportAdmins(format),
                        tooltip: 'Export Admins',
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'xlsx',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.table_chart,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                SizedBox(width: 12),
                                Text('Export as XLSX'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'pdf',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                SizedBox(width: 12),
                                Text('Export as PDF'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Export Admins',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: InkWell(
                        onTap: _showAddAdminDialog,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF2d5f3f),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2d5f3f).withOpacity(0.3),
                                blurRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Search and filters
            Row(
              children: [
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search admins by username or email...',
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _adminSearchQuery = value;
                        _applyFiltersAndSorting();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Role filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedRoleFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by Role',
                      filled: true,
                      fillColor: Colors.green[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'All', child: Text('All Roles')),
                      ...['superadmin', 'admin'].map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRoleFilter = value!;
                        _applyFiltersAndSorting();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Admin count
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_filteredAdmins.length} of ${_admins.length} admins',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sorting
            Row(
              children: [
                Text('Sort by:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                    items: const [
                      DropdownMenuItem(
                        value: 'username',
                        child: Text('Username'),
                      ),
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'role', child: Text('Role')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _sortBy = value!;
                        _applyFiltersAndSorting();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  ),
                  onPressed: () {
                    setState(() {
                      _sortAscending = !_sortAscending;
                      _applyFiltersAndSorting();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Admin data table
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFF2d5f3f),
                    ),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    dataRowMinHeight: 56,
                    dataRowMaxHeight: 72,
                    columnSpacing: 32,
                    horizontalMargin: 24,
                    dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.green[100];
                      }
                      return Colors.white;
                    }),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Role',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    rows: _filteredAdmins.map((admin) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              admin['username'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          DataCell(
                            Text(
                              admin['email'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          DataCell(
                            Text(
                              admin['role'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 22,
                                  ),
                                  tooltip: 'Edit',
                                  onPressed: () => _showEditAdminDialog(admin),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  tooltip: 'Delete',
                                  onPressed: () =>
                                      _showDeleteConfirmation(admin),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
