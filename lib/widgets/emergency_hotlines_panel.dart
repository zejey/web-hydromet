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
          return const Center(child: Text("Error loading hotlines"));
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
              child: ListView.builder(
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
                            onPressed: () =>
                                HotlineService.deleteHotline(hotline.id),
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
              TextField(
                controller: iconTypeController,
                decoration: const InputDecoration(labelText: 'Icon Type'),
              ),
              TextField(
                controller: iconColorController,
                decoration: const InputDecoration(
                  labelText: 'Icon Color (hex)',
                ),
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
              final model = EmergencyHotline(
                id:
                    hotline?.id ??
                    nameController.text.trim().toLowerCase().replaceAll(
                      ' ',
                      '_',
                    ),
                serviceName: nameController.text.trim(),
                phoneNumber: phoneController.text.trim(),
                category: categoryController.text.trim(),
                priority: int.tryParse(priorityController.text.trim()) ?? 1,
                isActive: isActive.value,
                iconType: iconTypeController.text.trim(),
                iconColor: iconColorController.text.trim(),
              );
              if (hotline == null) {
                await HotlineService.addHotline(model);
              } else {
                await HotlineService.updateHotline(model);
              }
              Navigator.pop(context);
            },
            child: Text(hotline == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
