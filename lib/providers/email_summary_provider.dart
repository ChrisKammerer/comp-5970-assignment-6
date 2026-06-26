import 'package:flutter/material.dart';
import 'package:email_summarizer/models/email_summary_entry.dart';
import 'package:email_summarizer/services/storage_service.dart';
import 'package:google_mlkit_entity_extraction/google_mlkit_entity_extraction.dart';
import 'package:uuid/uuid.dart';

class EmailSummaryProvider extends ChangeNotifier {
  List<EmailSummaryEntry> entries = [];
  String text = '';
  bool isProcessing = false;

  final StorageService storageService = StorageService();
  final Uuid uuid = Uuid();
  final entityExtractor = EntityExtractor(
    language: EntityExtractorLanguage.english,
  );

  void updateText(String value) {
    text = value;
    notifyListeners();
  }

  Future<void> loadEntries() async {
    entries = await storageService.loadEntries();
    notifyListeners();
  }

  Future<void> addEntry(
    String title,
    List<String> eventTimes,
    List<String> locations,
    List<String> emailAddresses,
    List<String> phoneNumbers,
  ) async {
    final entry = EmailSummaryEntry(
      id: uuid.v4(),
      createdAt: DateTime.now(),
      eventTimes: eventTimes,
      locations: locations,
      title: title,
      text: text,
      emailAddresses: emailAddresses,
      phoneNumbers: phoneNumbers,
    );

    entries = [entry, ...entries];
    text = '';
    await storageService.saveEntries(entries);
    notifyListeners();
  }

  Future<void> updateEntry(
    String id,
    String? title,
    List<String>? eventTimes,
    List<String>? locations,
    List<String>? phoneNumbers,
    List<String>? emailAddresses,
  ) async {
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      entries[index] = entries[index].copyWith(
        title: title,
        eventTimes: eventTimes,
        locations: locations,
        phoneNumbers: phoneNumbers,
        emailAddresses: emailAddresses,
      );
      await storageService.saveEntries(entries);
      notifyListeners();
    }
  }

  Future<void> removeEntry(String id) async {
    entries = entries.where((entry) => entry.id != id).toList();
    await storageService.saveEntries(entries);
    notifyListeners();
  }

  // Returns true if an annotation is worth keeping for a given type
  bool _isPlausible(EntityType type, String text) {
    switch (type) {
      case EntityType.phone:
        // Needs 7+ digits — filters out zip codes like "94105"
        return RegExp(r'\d').allMatches(text).length >= 7;
      case EntityType.address:
        // Must start with a digit — filters out "off Fremont Street"
        return RegExp(r'^\d').hasMatch(text);
      case EntityType.dateTime:
        // Must be longer than a bare day name like "Thursday"
        return text.length > 10;
      default:
        return true;
    }
  }

  List<String> _extract(
    List<EntityAnnotation> annotations,
    EntityType type,
  ) {
    final seen = <String>{};
    final results = <String>[];

    for (final annotation in annotations) {
      for (final entity in annotation.entities) {
        // Skip URLs entirely
        if (entity.type == EntityType.url) continue;

        if (entity.type == type && _isPlausible(type, annotation.text)) {
          // Deduplicate — e.g. same email appearing in To and CC
          if (seen.add(annotation.text)) {
            results.add(annotation.text);
          }
        }
      }
    }

    return results;
  }

  Future<void> processText() async {
    isProcessing = true;
    notifyListeners();

    try {
      final annotations = await entityExtractor.annotateText(text);

      final eventTimes = _extract(annotations, EntityType.dateTime);
      final locations = _extract(annotations, EntityType.address);
      final emailAddresses = _extract(annotations, EntityType.email);
      final phoneNumbers = _extract(annotations, EntityType.phone);

      await addEntry(
        '', // title left blank for user to fill in on detail screen
        eventTimes,
        locations,
        emailAddresses,
        phoneNumbers,
      );
    } finally {
      // Ensures isProcessing resets even if extraction throws
      isProcessing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    entityExtractor.close();
    super.dispose();
  }
}