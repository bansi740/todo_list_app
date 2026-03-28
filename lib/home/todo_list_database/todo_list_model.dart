import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class Todo {
  String? id;
  String? title;
  String? description;
  bool? isDone;
  DateTime? createdAt;
  DateTime? reminderAt;
  bool? isDeleted;
  bool? isPinned;
  bool? isSynced; // <-- NEW

  Todo({
    this.id,
    this.title,
    this.description,
    this.isDone,
    this.createdAt,
    this.reminderAt,
    this.isDeleted,
    this.isPinned,
    this.isSynced,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? reminderAt,
    bool? isDeleted,
    bool? isPinned,
    bool? isSynced,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      reminderAt: reminderAt ?? this.reminderAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson({bool forFirestore = false}) {
    return {
      'id': id,
      'title': title,

      'description': description,
      'isDone': forFirestore ? (isDone ?? false) : ((isDone ?? false) ? 1 : 0),
      'createdAt': forFirestore
          ? (createdAt ?? FieldValue.serverTimestamp())
          : createdAt?.toIso8601String(),
      'reminderAt': reminderAt?.toIso8601String(),
      'isDeleted': forFirestore ? (isDeleted ?? false) : ((isDeleted ?? false) ? 1 : 0),
      'isPinned': forFirestore ? (isPinned ?? false) : ((isPinned ?? false) ? 1 : 0),
      'isSynced': forFirestore ? (isSynced ?? false) : ((isSynced ?? false) ? 1 : 0),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isDone: map['isDone'] == true || map['isDone'] == 1,
      createdAt: parseDate(map['createdAt']),
      reminderAt: parseDate(map['reminderAt']),
      isDeleted: map['isDeleted'] == true || map['isDeleted'] == 1,
      isPinned: map['isPinned'] == true || map['isPinned'] == 1,
      isSynced: map['isSynced'] == true || map['isSynced'] == 1,
    );
  }

  String get formattedDate {
    final date = createdAt ?? DateTime.now(); // fallback if null
    return DateFormat('d MMM yyyy, hh:mm a').format(date);
  }

  String get timeAgo {
    if (createdAt == null) return "No date";
    return timeago.format(createdAt!, locale: 'en_short');
  }
}