import 'dart:convert';
import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const emailSummaryEntriesKey = 'email_summaries';

  Future<void> saveEntries(List<EmailSummaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedEntries = entries
        .map((entry) => jsonEncode(entry.toMap()))
        .toList();
    await prefs.setStringList(emailSummaryEntriesKey, encodedEntries);
  }

  Future<List<EmailSummaryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEntries = prefs.getStringList(emailSummaryEntriesKey) ?? [];

    return storedEntries.map((entryJson) {
      final decoded = jsonDecode(entryJson) as Map<String, dynamic>;
      return EmailSummaryEntry.fromMap(decoded);
    })
    .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
