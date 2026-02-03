import 'package:flutter/material.dart';
import '../models/emergency_hotline.dart';
import '../services/hotline_service.dart';

class EmergencyHotlinesPanel extends StatelessWidget {
  const EmergencyHotlinesPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EmergencyHotline>>(
      stream: HotlineService.getHotlinesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "Error loading hotlines",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "${snapshot.error}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: () {
                    HotlineService.stopPolling();
                    HotlineService.getHotlinesStream();
                  },
                ),
              ],
            ),
          );
        }
        
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final hotlines = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Hotlines',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: hotlines.isEmpty 
                ? _buildEmptyState(context)
                : ListView.builder(
                    itemCount: hotlines.length,
                    itemBuilder: (context, index) {
                      final hotline = hotlines[index];
                      return Card(
                        color: hotline.isActive
                            ? const Color(0xFFE8FAF0)
                            : Colors.red[50],
                        child: ListTile(
                          leading: Icon(
                            Icons.phone,
                            color: Color(
                              int.parse(
                                hotline.iconColor.replaceFirst('#', '0xff'),
                              ),
                            ),
                          ),
                          title: Text(
                            hotline.serviceName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(hotline.phoneNumber),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showHotlineDialog(context, hotline),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(context, hotline),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Hotline'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _showHotlineDialog(context, null),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_disabled,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Emergency Hotlines Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get started by adding your first emergency hotline.\nHelp people reach emergency services quickly!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 24),
            label: const Text('Add Your First Hotline'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: () => _showHotlineDialog(context, null),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmergencyHotline hotline) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hotline'),
        content: Text(
          'Are you sure you want to delete "${hotline.serviceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await HotlineService.deleteHotline(hotline.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hotline deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting hotline: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHotlineDialog(BuildContext context, EmergencyHotline? hotline) {
    final nameController = TextEditingController(
      text: hotline?.serviceName ?? '',
    );
    final phoneController = TextEditingController(
      text: hotline?.phoneNumber ?? '',
    );
    final categoryController = TextEditingController(
      text: hotline?.category ?? '',
    );
    final priorityController = TextEditingController(
      text: hotline?.priority.toString() ?? '1',
    );
    final iconTypeController = TextEditingController(
      text: hotline?.iconType ?? 'call',
    );
    final iconColorController = TextEditingController(
      text: hotline?.iconColor ?? '#2196F3',
    );
    final isActive = ValueNotifier<bool>(hotline?.isActive ?? true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          hotline == null ? 'Add Emergency Hotline' : 'Edit Emergency Hotline',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number(s)'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: priorityController,
                decoration: const InputDecoration(labelText: 'Priority'),
                keyboardType: TextInputType.number,
              ),
              ValueListenableBuilder(
                valueListenable: isActive,
                builder: (context, value, _) => SwitchListTile(
                  title: const Text('Active'),
                  value: value,
                  onChanged: (val) => isActive.value = val,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate inputs
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a service name')),
                );
                return;
              }
              
              if (phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a phone number')),
                );
                return;
              }
              
              final model = EmergencyHotline(
                id: hotline?.id, // only set if editing
                serviceName: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
                category: categoryController.text.trim(),
                priority: int.tryParse(priorityController.text.trim()) ?? 1,
                isActive: isActive.value,
                iconType: iconTypeController.text.trim(),
                iconColor: iconColorController.text.trim(),
              );              

              try {
                if (hotline == null) {
                  await HotlineService.addHotline(model);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hotline added successfully')),
                  );
                } else {
                  await HotlineService.updateHotline(model);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hotline updated successfully')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(hotline == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
