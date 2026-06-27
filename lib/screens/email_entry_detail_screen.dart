import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:email_summarizer/providers/email_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Factory that owns controllers for a single named field
class FieldControllerGroup {
  final String label;
  final List<TextEditingController> controllers;

  FieldControllerGroup({required this.label, required List<String> values})
      : controllers = values.isNotEmpty
            ? values.map((v) => TextEditingController(text: v)).toList()
            : [TextEditingController()];

  List<String> get values =>
      controllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

  void addController() => controllers.add(TextEditingController());

  void removeController(int index) {
    controllers[index].dispose();
    controllers.removeAt(index);
  }

  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
  }
}

class EmailEntryDetailScreen extends StatefulWidget {
  final EmailSummaryEntry entry;
  const EmailEntryDetailScreen({super.key, required this.entry});

  @override
  State<EmailEntryDetailScreen> createState() => _EmailEntryDetailScreenState();
}

class _EmailEntryDetailScreenState extends State<EmailEntryDetailScreen> {
  late final TextEditingController titleController;
  late final Map<String, FieldControllerGroup> fieldGroups;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;

    titleController = TextEditingController(text: e.title);

    fieldGroups = {
      'eventTimes': FieldControllerGroup(
        label: 'Event time',
        values: e.eventTimes,
      ),
      'locations': FieldControllerGroup(
        label: 'Location',
        values: e.locations,
      ),
      'emailAddresses': FieldControllerGroup(
        label: 'Email address',
        values: e.emailAddresses,
      ),
      'phoneNumbers': FieldControllerGroup(
        label: 'Phone number',
        values: e.phoneNumbers,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit entry'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 24),
            ...fieldGroups.entries.map(
              (entry) => _buildFieldGroup(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldGroup(String key, FieldControllerGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'Add ${group.label.toLowerCase()}',
                onPressed: () => setState(() => group.addController()),
              ),
            ],
          ),
          ...group.controllers.asMap().entries.map((e) {
            final index = e.key;
            final controller = e.value;
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: '${group.label} ${index + 1}',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (group.controllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      tooltip: 'Remove',
                      onPressed: () =>
                          setState(() => group.removeController(index)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await Provider.of<EmailSummaryProvider>(context, listen: false).updateEntry(
      widget.entry.id,
      titleController.text,
      fieldGroups['eventTimes']!.values,
      fieldGroups['locations']!.values,
      fieldGroups['emailAddresses']!.values,
      fieldGroups['phoneNumbers']!.values,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    for (final group in fieldGroups.values) {
      group.dispose();
    }
    super.dispose();
  }
}