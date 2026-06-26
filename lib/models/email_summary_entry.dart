class EmailSummaryEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final String title;
  final List<String> eventTimes;
  final List<String> locations;
  final List<String> emailAddresses;
  final List<String> phoneNumbers;

  EmailSummaryEntry({
    required this.id,
    required this.createdAt,
    required this.text,
    required this.title,
    this.eventTimes = const [],
    this.locations = const [],
    this.emailAddresses = const [],
    this.phoneNumbers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'title': title,
      'text': text,
      'eventTimes': eventTimes,
      'locations': locations,
      'emailAddresses': emailAddresses,
      'phoneNumbers': phoneNumbers,
    };
  }

  factory EmailSummaryEntry.fromMap(Map<String, dynamic> map) {
    return EmailSummaryEntry(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      title: map['title'] as String,
      text: map['text'] as String,
      eventTimes: List<String>.from(map['eventTimes'] ?? []),
      locations: List<String>.from(map['locations'] ?? []),
      emailAddresses: List<String>.from(map['emailAddresses'] ?? []),
      phoneNumbers: List<String>.from(map['phoneNumbers'] ?? []),
    );
  }

  EmailSummaryEntry copyWith({
    String? title,
    List<String>? eventTimes,
    List<String>? locations,
    List<String>? phoneNumbers,
    List<String>? emailAddresses,
  }) {
    return EmailSummaryEntry(
      id: id,
      createdAt: createdAt,
      text: text,
      title: title ?? this.title,
      eventTimes: eventTimes ?? this.eventTimes,
      locations: locations ?? this.locations,
      emailAddresses: emailAddresses ?? this.emailAddresses,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
    );
  }
}