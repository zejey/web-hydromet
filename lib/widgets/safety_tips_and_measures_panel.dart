import 'package:flutter/material.dart';
import '../services/safety_tip_service.dart';

class SafetyTipsAndMeasuresPanel extends StatefulWidget {
  final List<Map<String, String>> categories;
  const SafetyTipsAndMeasuresPanel({required this.categories, Key? key})
      : super(key: key);

  @override
  State<SafetyTipsAndMeasuresPanel> createState() =>
      _SafetyTipsAndMeasuresPanelState();
}

class _SafetyTipsAndMeasuresPanelState
    extends State<SafetyTipsAndMeasuresPanel> {
  final _safetyService = SafetyTipService();
  
  late String selectedCategoryId;
  late int selectedCategoryIntId;
  
  List<Map<String, dynamic>> _tips = [];
  bool _isLoadingTips = false;
  String? _errorTips;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.categories.first['id']!;
    // Map category IDs to integers (assuming your categories are named like 'air_quality', etc.)
    selectedCategoryIntId = _getCategoryIntId(selectedCategoryId);
    _loadTips();
  }

  // Map category string IDs to database integer IDs
  int _getCategoryIntId(String categoryId) {
    switch (categoryId) {
      case 'air_quality':
        return 1;
      case 'heat_index':
        return 2;
      case 'flood_safety':
        return 3;
      case 'typhoon_safety':
        return 4;
      default:
        return 1;
    }
  }

  Future<void> _loadTips() async {
    setState(() {
      _isLoadingTips = true;
      _errorTips = null;
    });

    try {
      final tips = await _safetyService.getTipsForCategory(selectedCategoryIntId);
      setState(() {
        _tips = tips;
        _isLoadingTips = false;
      });
    } catch (e) {
      setState(() {
        _errorTips = e.toString();
        _isLoadingTips = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Tips & Measures',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        // Category tabs
        Wrap(
          spacing: 8,
          children: widget.categories.map((cat) {
            final isSelected = selectedCategoryId == cat['id'];
            return ChoiceChip(
              label: Text(cat['name']!),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedCategoryId = cat['id']!;
                  selectedCategoryIntId = _getCategoryIntId(cat['id']!);
                });
                _loadTips();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Tips list header with add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Safety Tips',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Tip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d5f3f),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () => _showAddTipDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tips list
        Expanded(
          child: _isLoadingTips
              ? const Center(child: CircularProgressIndicator())
              : _errorTips != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 8),
                          Text('Error: $_errorTips'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadTips,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _tips.isEmpty
                      ? const Center(
                          child: Text(
                            'No tips yet. Click "Add Tip" to create one.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tips.length,
                          itemBuilder: (context, index) {
                            final tip = _tips[index];
                            final tipId = tip['id'] as int;
                            final rangeLabel = tip['range_label'] ?? '';
                            final level = tip['level'] ?? '';
                            final details = (tip['details'] as List<dynamic>?) ?? [];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: Colors.green[50],
                              child: ExpansionTile(
                                title: Text(
                                  '$rangeLabel - $level',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${details.length} guidelines'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Colors.green),
                                      tooltip: 'Add guideline',
                                      onPressed: () => _showAddDetailDialog(context, tipId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Edit tip',
                                      onPressed: () => _showEditTipDialog(context, tip),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete tip',
                                      onPressed: () => _confirmDeleteTip(context, tipId),
                                    ),
                                  ],
                                ),
                                children: [
                                  if (details.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No guidelines yet. Click + to add one.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  else
                                    ...details.map((detail) {
                                      final detailId = detail['id'] as int;
                                      final description = detail['description'] ?? '';
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.fiber_manual_record, size: 8),
                                        title: Text(description),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          onPressed: () => _confirmDeleteDetail(context, detailId),
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  // ==================== ADD TIP DIALOG ====================
  void _showAddTipDialog(BuildContext context) {
    final rangeLabelController = TextEditingController();
    final levelController = TextEditingController();
    final colorController = TextEditingController(text: '#4CAF50');
    String? rangeLabelError;
    String? levelError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Safety Tip'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: rangeLabelController,
                  decoration: InputDecoration(
                    labelText: 'Range Label (e.g., "0-50")',
                    errorText: rangeLabelError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: levelController,
                  decoration: InputDecoration(
                    labelText: 'Level (e.g., "Good", "Moderate")',
                    errorText: levelError,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: 'Color (hex)',
                    border: OutlineInputBorder(),
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
                setDialogState(() {
                  rangeLabelError = rangeLabelController.text.trim().isEmpty
                      ? 'Range label is required'
                      : null;
                  levelError = levelController.text.trim().isEmpty
                      ? 'Level is required'
                      : null;
                });

                if (rangeLabelError == null && levelError == null) {
                  try {
                    await _safetyService.createTip(
                      categoryId: selectedCategoryIntId,
                      rangeLabel: rangeLabelController.text.trim(),
                      level: levelController.text.trim(),
                      color: colorController.text.trim(),
                      orderNum: _tips.length,
                    );
                    Navigator.pop(context);
                    _loadTips();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tip added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d5f3f),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EDIT TIP DIALOG ====================
  void _showEditTipDialog(BuildContext context, Map<String, dynamic> tip) {
    final tipId = tip['id'] as int;
    final rangeLabelController = TextEditingController(text: tip['range_label'] ?? '');
    final levelController = TextEditingController(text: tip['level'] ?? '');
    final colorController = TextEditingController(text: tip['color'] ?? '#4CAF50');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Safety Tip'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rangeLabelController,
                decoration: const InputDecoration(
                  labelText: 'Range Label',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: levelController,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (hex)',
                  border: OutlineInputBorder(),
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
              try {
                await _safetyService.updateTip(tipId, {
                  'range_label': rangeLabelController.text.trim(),
                  'level': levelController.text.trim(),
                  'color': colorController.text.trim(),
                });
                Navigator.pop(context);
                _loadTips();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tip updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2d5f3f),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ==================== ADD DETAIL DIALOG ====================
  void _showAddDetailDialog(BuildContext context, int tipId) {
    final descriptionController = TextEditingController();
    String? descriptionError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Guideline'),
          content: TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Guideline description',
              errorText: descriptionError,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setDialogState(() {
                  descriptionError = descriptionController.text.trim().isEmpty
                      ? 'Description is required'
                      : null;
                });

                if (descriptionError == null) {
                  try {
                    await _safetyService.addTipDetail(
                      tipId: tipId,
                      description: descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                    _loadTips();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Guideline added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2d5f3f),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CONFIRM DELETE TIP ====================
  void _confirmDeleteTip(BuildContext context, int tipId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tip'),
        content: const Text('Are you sure you want to delete this tip? All guidelines will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _safetyService.deleteTip(tipId);
                Navigator.pop(context);
                _loadTips();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tip deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ==================== CONFIRM DELETE DETAIL ====================
  void _confirmDeleteDetail(BuildContext context, int detailId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guideline'),
        content: const Text('Are you sure you want to delete this guideline?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _safetyService.deleteTipDetail(detailId);
                Navigator.pop(context);
                _loadTips();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Guideline deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
