import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:email_summarizer/providers/email_summary_provider.dart';
import 'package:email_summarizer/screens/email_entry_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_summarizer/widgets/entry_card.dart';

enum EntrySortMode { dateNewest, dateOldest, titleAZ, titleZA }

extension EntrySortModeLabel on EntrySortMode {
  String get label => switch (this) {
        EntrySortMode.dateNewest => 'Newest first',
        EntrySortMode.dateOldest => 'Oldest first',
        EntrySortMode.titleAZ => 'Title A–Z',
        EntrySortMode.titleZA => 'Title Z–A',
      };

  IconData get icon => switch (this) {
        EntrySortMode.dateNewest => Icons.arrow_downward,
        EntrySortMode.dateOldest => Icons.arrow_upward,
        EntrySortMode.titleAZ => Icons.sort_by_alpha,
        EntrySortMode.titleZA => Icons.sort_by_alpha,
      };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController controller;
  late final EmailSummaryProvider provider;
  EntrySortMode _sortMode = EntrySortMode.dateNewest;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = context.read<EmailSummaryProvider>();
      provider.loadEntries();
      provider.addListener(_syncControllerWithProvider);
    });
  }

  void _syncControllerWithProvider() {
    final providerText = provider.text;
    if (controller.text != providerText) {
      controller.value = controller.value.copyWith(
        text: providerText,
        selection: TextSelection.collapsed(offset: providerText.length),
      );
    }
  }

  List<EmailSummaryEntry> _sorted(List<EmailSummaryEntry> entries) {
    final list = [...entries];
    switch (_sortMode) {
      case EntrySortMode.dateNewest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case EntrySortMode.dateOldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case EntrySortMode.titleAZ:
        list.sort((a, b) =>
            (a.title).toLowerCase().compareTo((b.title).toLowerCase()));
      case EntrySortMode.titleZA:
        list.sort((a, b) =>
            (b.title).toLowerCase().compareTo((a.title).toLowerCase()));
    }
    return list;
  }

  Future<void> _processAndNavigate() async {
    await provider.processText();
    if (!mounted) return;
    final newEntry = provider.entries.firstOrNull;
    if (newEntry == null) return;
    _navigateToDetails(newEntry);
  }

  void _navigateToDetails(EmailSummaryEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailEntryDetailScreen(entry: entry),
      ),
    );
  }

  void _showSortMenu() async {
    final selected = await showModalBottomSheet<EntrySortMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Sort entries',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            ...EntrySortMode.values.map(
              (mode) => ListTile(
                leading: Icon(mode.icon),
                title: Text(mode.label),
                trailing: _sortMode == mode
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onTap: () => Navigator.pop(context, mode),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null && selected != _sortMode) {
      setState(() => _sortMode = selected);
    }
  }

  @override
  void dispose() {
    provider.removeListener(_syncControllerWithProvider);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmailSummaryProvider>();
    final sorted = _sorted(provider.entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email summarizer'),
        actions: [
          if (provider.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort entries',
              onPressed: _showSortMenu,
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Paste your email here',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Analyze emails for important details'),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              minLines: 6,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste an email...',
                border: OutlineInputBorder(),
              ),
              onChanged: provider.updateText,
            ),
            const SizedBox(height: 16),
            if (provider.isProcessing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: provider.isProcessing || provider.text.trim().isEmpty
                  ? null
                  : _processAndNavigate,
              icon: const Icon(Icons.search),
              label: const Text('Process entry'),
            ),
            const SizedBox(height: 16),
            if (sorted.isEmpty)
              const Text('No entries yet.')
            else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _sortMode.label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              ...sorted.map(
                (entry) => EntryCard(
                  entry: entry,
                  onDelete: () => provider.removeEntry(entry.id),
                  onEdit: () => _navigateToDetails(entry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}