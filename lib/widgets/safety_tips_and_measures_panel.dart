import 'package:flutter/material.dart';
import '../models/safety_tip.dart';
import '../models/preventive_measure.dart';
import '../services/safety_tip_service.dart';
import '../services/preventive_measure_service.dart';

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
  late String selectedCategoryId;

  @override
  void initState() {
    super.initState();
    selectedCategoryId = widget.categories.first['id']!;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tips & Preventive Measures',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: widget.categories.map((cat) {
            final isSelected = selectedCategoryId == cat['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat['name']!),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => selectedCategoryId = cat['id']!),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // SAFETY TIPS SECTION
        const Text(
          'Tips',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: StreamBuilder<List<SafetyTip>>(
            stream: SafetyTipService.getTipsForCategory(selectedCategoryId),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final tips = snapshot.data!;
              return ListView.builder(
                itemCount: tips.length,
                itemBuilder: (context, index) {
                  final tip = tips[index];
                  final title = (tip.level ?? tip.title).isNotEmpty
                      ? (tip.level ?? tip.title)
                      : tip.title; // fallback for older records
                  return Card(
                    color: Colors.green[50],
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(tip.description),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTipDialog(context, tip, title),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // PREVENTIVE MEASURES SECTION
        const Text(
          'Preventive Measures',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Expanded(
          child: StreamBuilder<List<PreventiveMeasure>>(
            stream: PreventiveMeasureService.getMeasuresForCategory(
              selectedCategoryId,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final measures = snapshot.data!;
              return ListView.builder(
                itemCount: measures.length,
                itemBuilder: (context, index) {
                  final measure = measures[index];
                  // Inside ListView.builder for measures
                  return Card(
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[600],
                        child: Text(
                          measure.number, // e.g. "01", "02"
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        measure.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(measure.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showMeasureDialog(context, measure),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => PreventiveMeasureService.deleteMeasure(
                              measure.id,
                              measure
                                  .categoryId, // pass categoryId for renumbering
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Measure'),
            onPressed: () => _showMeasureDialog(context, null),
          ),
        ),
      ],
    );
  }

  void _showTipDialog(BuildContext context, SafetyTip tip, String title) {
    // Only description is editable, title is immutable
    final descriptionController = TextEditingController(text: tip.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tip Description'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Immutable title, shown as plain text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
              if (descriptionController.text.trim().isEmpty) return;
              final updated = tip.copyWith(
                description: descriptionController.text.trim(),
              );
              await SafetyTipService.updateTip(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showMeasureDialog(BuildContext context, PreventiveMeasure? measure) {
    final titleController = TextEditingController(text: measure?.title ?? '');
    final descriptionController = TextEditingController(
      text: measure?.description ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          measure == null
              ? 'Add Preventive Measure'
              : 'Edit Preventive Measure',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
              if (titleController.text.trim().isEmpty ||
                  descriptionController.text.trim().isEmpty)
                return;
              final model = PreventiveMeasure(
                id: measure?.id ?? '',
                categoryId: selectedCategoryId,
                title: titleController.text.trim(),
                description: descriptionController.text.trim(),
                isActive: true,
                order: measure?.order ?? 0,
                number: measure?.number ?? '',
              );
              if (measure == null) {
                await PreventiveMeasureService.addMeasure(model);
              } else {
                await PreventiveMeasureService.updateMeasure(model);
              }
              Navigator.pop(context);
            },
            child: Text(measure == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }
}
