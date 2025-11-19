import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/admin_drawer.dart';
import '../models/user.dart';
import '../services/user_service.dart';

import 'package:go_router/go_router.dart'; // <-- Import go_router

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  void _navigateToSuperadminDashboard() {
    context.go('/superadmin-dashboard?role=superadmin');
  }

  final List<String> _barangays = [
    'Bagong Silang',
    'Calendola',
    'Chrysanthemum',
    'Cuyab',
    'Estrella',
    'Fatima',
    'GSIS',
    'Landayan',
    'Langgam',
    'Laram',
    'Magsaysay',
    'Maharlika',
    'Narra',
    'Nueva',
    'Pacita 1',
    'Pacita 2',
    'Poblacion',
    'Riverside',
    'Rosario',
    'Sampaguita',
    'San Antonio',
    'San Lorenzo Ruiz',
    'San Roque',
    'San Vicente',
    'Santo Niño',
    'United Bayanihan',
    'United Better Living',
  ];

  String _selectedBarangay = '';

  // Firebase-connected state
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for user form
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _suffixController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedRole = 'Emergency Responder';
  String? _editingUserId;

  // Filter and Sort State Variables
  String _userSearchQuery = '';
  String _selectedRoleFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _isSuperadmin = false;

  // Track if initial setup is done to prevent multiple route handling
  bool _initialSetupDone = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only handle route arguments once
    if (!_initialSetupDone) {
      _initialSetupDone = true;

      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        if (args['filterRole'] == 'Emergency Responder') {
          setState(() {
            _selectedRoleFilter = 'Emergency Responder';
          });
        }
        _isSuperadmin = args['role'] == 'superadmin';

        // Handle showing add user dialog
        if (args['showAddUser'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final preselectRole = args['preselectRole'] is String
                ? args['preselectRole'] as String
                : null;
            _showAddUserDialog(preselectRole: preselectRole);
          });
        }
      }
      _applyFiltersAndSorting();
    }
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;

    try {
      setState(() => _isLoading = true);
      final users = await UserService.getUsers();

      if (mounted) {
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
        _applyFiltersAndSorting();
      }
    } catch (e) {
      print('Error loading users: $e'); // Debug print
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFiltersAndSorting() {
    if (!mounted) return;

    List<UserModel> filtered = List.from(_allUsers);

    // Search filter
    if (_userSearchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.fullName.toLowerCase().contains(
              _userSearchQuery.toLowerCase(),
            ) ||
            user.phoneNumber.toLowerCase().contains(
              _userSearchQuery.toLowerCase(),
            ) ||
            user.fullAddress.toLowerCase().contains(
              _userSearchQuery.toLowerCase(),
            );
      }).toList();
    }

    // Role filter
    if (_selectedRoleFilter != 'All') {
      filtered = filtered
          .where((user) => user.role == _selectedRoleFilter)
          .toList();
    }

    // Status filter
    if (_selectedStatusFilter != 'All') {
      filtered = filtered
          .where((user) => user.status == _selectedStatusFilter)
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      String aValue = '';
      String bValue = '';
      switch (_sortBy) {
        case 'name':
          aValue = a.fullName;
          bValue = b.fullName;
          break;
        case 'contact':
          aValue = a.phoneNumber;
          bValue = b.phoneNumber;
          break;
        case 'address':
          aValue = a.fullAddress;
          bValue = b.fullAddress;
          break;
        case 'role':
          aValue = a.role;
          bValue = b.role;
          break;
      }
      int comparison = aValue.toLowerCase().compareTo(bValue.toLowerCase());
      return _sortAscending ? comparison : -comparison;
    });

    if (mounted) {
      setState(() {
        _filteredUsers = filtered;
      });
    }
  }

  void _showAddUserDialog({String? preselectRole}) {
    _clearForm();
    _editingUserId = null;
    if (preselectRole != null) {
      _selectedRole = preselectRole;
    } else {
      _selectedRole = 'Emergency Responder';
    }
    _showUserDialog('Add Mobile User');
  }

  void _showEditUserDialog(UserModel user) {
    _firstNameController.text = user.firstName;
    _middleNameController.text = user.middleName ?? '';
    _lastNameController.text = user.lastName;
    _suffixController.text = user.suffix ?? '';
    _contactController.text = user.phoneNumber;
    _addressController.text = user.houseAddress;
    _selectedBarangay = user.barangay;
    _selectedRole = user.role;
    _editingUserId = user.id;
    _showUserDialog('Edit Mobile User');
  }

  void _showUserDialog(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                width: 600,
                height: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _firstNameController,
                        inputFormatters: [_nameInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'First Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _lastNameController,
                        inputFormatters: [_nameInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'Last Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _middleNameController,
                        inputFormatters: [_nameInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'Middle Name (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _suffixController,
                        inputFormatters: [_nameInputFormatter],
                        decoration: const InputDecoration(
                          labelText: 'Suffix (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.text_fields),
                          hintText: 'Jr., Sr., III, etc.',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ], // <-- ADD THIS
                        decoration: const InputDecoration(
                          labelText: 'Contact Number (09XXXXXXXXX) *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Enter 11-digit mobile number',
                          helperText:
                              'Must start with 09 and be 11 digits total',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'House/Street Address *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Block/Lot, Street, Subdivision, etc.',
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedBarangay.isNotEmpty
                            ? _selectedBarangay
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Barangay *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        items: _barangays.map((barangay) {
                          return DropdownMenuItem<String>(
                            value: barangay,
                            child: Text(barangay),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedBarangay = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value:
                            ([
                              'Emergency Responder',
                              'Community Leader',
                              'Users',
                            ].contains(_selectedRole))
                            ? _selectedRole
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Emergency Responder',
                            child: Text('Emergency Responder'),
                          ),
                          DropdownMenuItem(
                            value: 'Community Leader',
                            child: Text('Community Leader'),
                          ),
                          DropdownMenuItem(
                            value: 'Users',
                            child: Text('Users'),
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
                      onPressed: _isSaving
                          ? null
                          : () {
                              // Reset saving state when canceling
                              if (mounted) setState(() => _isSaving = false);
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _isSaving ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              _validateAndSaveUser(context, setDialogState);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSaving
                            ? Colors.grey
                            : Color(0xFF2d5f3f),
                      ),
                      child: _isSaving
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Saving...'),
                              ],
                            )
                          : const Text('Save'),
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

  Future<void> _validateAndSaveUser(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    // Prevent multiple saves
    if (_isSaving) return;

    print('Starting validation...'); // Debug print

    // Basic validation
    if (_firstNameController.text.trim().isEmpty) {
      _showErrorSnackBar('First Name is required');
      return;
    }
    if (_lastNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Last Name is required');
      return;
    }
    if (_contactController.text.trim().isEmpty) {
      _showErrorSnackBar('Contact Number is required');
      return;
    }
    if (!_contactController.text.startsWith('09') ||
        _contactController.text.length != 11) {
      _showErrorSnackBar('Contact Number must start with 09 and be 11 digits');
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(_contactController.text)) {
      _showErrorSnackBar('Contact Number must contain only numbers');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      _showErrorSnackBar('Address is required');
      return;
    }
    if (_selectedBarangay.isEmpty) {
      _showErrorSnackBar('Please select a barangay');
      return;
    }

    print('Basic validation passed'); // Debug print

    // Set saving state
    if (mounted) setState(() => _isSaving = true);
    setDialogState(() => _isSaving = true);

    try {
      // Check for duplicate phone number
      print('Checking duplicate phone...'); // Debug print
      final existingUser = await UserService.getUserByPhone(
        _contactController.text
      );

      final phoneExists = existingUser != null && existingUser.id != _editingUserId; 

      if (phoneExists) {
        _showErrorSnackBar('This mobile number is already registered');
        // Reset saving state when validation fails
        if (mounted) setState(() => _isSaving = false);
        setDialogState(() => _isSaving = false);
        return;
      }

      print('No duplicate found, creating user...'); // Debug print

      // Create user object
      final user = UserModel(
        id: _editingUserId ?? '',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        middleName: _middleNameController.text.trim().isNotEmpty
            ? _middleNameController.text.trim()
            : null,
        suffix: _suffixController.text.trim().isNotEmpty
            ? _suffixController.text.trim()
            : null,
        phoneNumber: _contactController.text,
        houseAddress: _addressController.text.trim(),
        barangay: _selectedBarangay,
        role: _selectedRole,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      print('User object created: ${user.fullName}'); // Debug print

      if (_editingUserId == null) {
        // Add new user
        print('Adding new user...'); // Debug print
        final newUserId = await UserService.addUser(user);
        print('User added with ID: $newUserId'); // Debug print

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Success! Mobile user "${user.fullName}" has been added',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Update existing user
        print('Updating existing user...'); // Debug print
        await UserService.updateUser(_editingUserId!, user);
        print('User updated'); // Debug print

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ Success! Mobile user "${user.fullName}" has been updated',
              ),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Clear form and reload data
      _clearForm();
      print('Reloading users...'); // Debug print
      await _loadUsers();
      print('Users reloaded'); // Debug print

      // Close dialog
      if (mounted && Navigator.of(dialogContext).canPop()) {
        Navigator.of(dialogContext).pop();
        print('Dialog closed'); // Debug print
      }
    } catch (e) {
      print('Error saving user: $e'); // Debug print
      _showErrorSnackBar('Error saving user: $e');
    } finally {
      // Always reset saving state in finally block
      if (mounted) {
        setState(() => _isSaving = false);
        print('Main saving state reset'); // Debug print
      }
      setDialogState(() => _isSaving = false);
      print('Dialog saving state reset'); // Debug print
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteConfirmation(UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${user.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (user.id != null) {
                  _deleteUser(user.id!);
                }
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

  Future<void> _deleteUser(String userId) async {
    try {
      await UserService.deleteUser(userId);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mobile user deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _firstNameController.clear();
    _middleNameController.clear();
    _lastNameController.clear();
    _suffixController.clear();
    _contactController.clear();
    _addressController.clear();
    _selectedRole = 'Emergency Responder';
    _selectedBarangay = '';
  }

  bool _isValidName(String name) {
    final namePattern = RegExp(r'^[a-zA-ZñÑ\s\-]+$');
    return namePattern.hasMatch(name.trim()) && name.trim().isNotEmpty;
  }

  TextInputFormatter get _nameInputFormatter {
    return FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZñÑ\s\-]'));
  }

  void _exportUsers(String format) {
    String message;
    switch (format) {
      case 'xlsx':
        message = 'Users exported as XLSX file successfully!';
        break;
      case 'pdf':
        message = 'Users exported as PDF file successfully!';
        break;
      case 'xml':
        message = 'Users exported as XML file successfully!';
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: _isSuperadmin ? 5 : 1,
        role: _isSuperadmin ? 'superadmin' : 'admin',
        onItemSelected: (index) {
          if (index == 5 || _isSaving) return;
          final args = ModalRoute.of(context)?.settings.arguments;
          final isSuperadmin = args is Map && args['role'] == 'superadmin';

          if (isSuperadmin) {
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
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_alt_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Mobile App Users Management',
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
                  'Welcome, CDRRMO',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mobile App Users Management',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2d5f3f),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep your community organized and secure',
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
                          // Make both buttons have the same width and height
                          SizedBox(
                            width: 170,
                            height: 48,
                            child: PopupMenuButton<String>(
                              onSelected: (String format) =>
                                  _exportUsers(format),
                              tooltip: 'Export Users',
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
                                const PopupMenuItem<String>(
                                  value: 'xml',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.code,
                                        color: Colors.orange,
                                        size: 18,
                                      ),
                                      SizedBox(width: 12),
                                      Text('Export as XML'),
                                    ],
                                  ),
                                ),
                              ],
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Icon(
                                      Icons.download,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Export Users',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
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
                          SizedBox(
                            width: 170,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _showAddUserDialog,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: const Text('Add Mobile User'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSaving
                                    ? Colors.grey
                                    : Color(0xFF2d5f3f),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                elevation: 2,
                                minimumSize: const Size(170, 48),
                                maximumSize: const Size(170, 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText:
                                'Search users by name, contact, or address...',
                            filled: true,
                            fillColor: Colors.green[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _userSearchQuery = value;
                              _applyFiltersAndSorting();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value:
                              ([
                                'All',
                                'Emergency Responder',
                                'Community Leader',
                                'Users',
                              ].contains(_selectedRoleFilter))
                              ? _selectedRoleFilter
                              : 'All',
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
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All Roles'),
                            ),
                            ...[
                              'Emergency Responder',
                              'Community Leader',
                              'Users',
                            ].map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
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
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value:
                              ([
                                'All',
                                'Active',
                                'Inactive',
                              ].contains(_selectedStatusFilter))
                              ? _selectedStatusFilter
                              : 'All',
                          decoration: InputDecoration(
                            labelText: 'Filter by Status',
                            filled: true,
                            fillColor: Colors.green[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All Status'),
                            ),
                            DropdownMenuItem(
                              value: 'Active',
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: 'Inactive',
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatusFilter = value!;
                              _applyFiltersAndSorting();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
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
                          '${_filteredUsers.length} of ${_allUsers.length} users',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Sort by:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value:
                              ([
                                'name',
                                'contact',
                                'address',
                                'role',
                              ].contains(_sortBy))
                              ? _sortBy
                              : 'name',
                          underline: const SizedBox(),
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          items: const [
                            DropdownMenuItem(
                              value: 'name',
                              child: Text('Name'),
                            ),
                            DropdownMenuItem(
                              value: 'contact',
                              child: Text('Contact Number'),
                            ),
                            DropdownMenuItem(
                              value: 'address',
                              child: Text('Address'),
                            ),
                            DropdownMenuItem(
                              value: 'role',
                              child: Text('Role'),
                            ),
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
                          _sortAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
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
                            dataRowColor:
                                WidgetStateProperty.resolveWith<Color?>((
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
                                  'Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Contact Number',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Address',
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
                                  'Status',
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
                            rows: _filteredUsers.map((user) {
                              final isActive = user.isVerified;
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: const Color(
                                            0xFF2d5f3f,
                                          ),
                                          foregroundColor: Colors.white,
                                          radius: 22,
                                          child: Text(
                                            user.fullName[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Text(
                                          user.fullName,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user.phoneNumber,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user.fullAddress,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      user.role,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.green[50]
                                            : Colors.red[50],
                                        border: Border.all(
                                          color: isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 12,
                                            color: isActive
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            user.status,
                                            style: TextStyle(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                          onPressed: _isSaving
                                              ? null
                                              : () => _showEditUserDialog(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          tooltip: 'Delete',
                                          onPressed: _isSaving
                                              ? null
                                              : () => _showDeleteConfirmation(
                                                  user,
                                                ),
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
                  ),
                ],
              ),
            ),
    );
  }
}
