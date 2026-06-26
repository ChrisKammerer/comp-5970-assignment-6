import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:email_summarizer/providers/email_summary_provider.dart';
import 'package:email_summarizer/screens/email_entry_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_summarizer/widgets/entry_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController controller;
  late final EmailSummaryProvider provider;

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

  Future<void> _processAndNavigate() async {
    await provider.processText();

    if (!mounted) return;

    // processText calls addEntry which prepends, so newest is always first
    final newEntry = provider.entries.firstOrNull;
    if (newEntry == null) return;

    _navigateToDetails(newEntry);
  }

  void _navigateToDetails(EmailSummaryEntry entry) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EmailEntryDetailScreen(entry: entry),
      ),
    );
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

    return Scaffold(
      appBar: AppBar(title: const Text('Email summarizer')),
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
            if (provider.entries.isEmpty)
              const Text('No entries yet.')
            else
              ...provider.entries.map(
                (entry) => EntryCard(
                  entry: entry,
                  onDelete: () => provider.removeEntry(entry.id),
                  onEdit: () => _navigateToDetails(entry)
                ),
              ),
          ],
        ),
      ),
    );
  }
}
