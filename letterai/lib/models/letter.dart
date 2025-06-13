import 'package:uuid/uuid.dart';

class Letter {
  final String id;
  final String title;
  final String content;
  final String categoryId;
  final String subcategoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTemplate;
  
  Letter({
    String? id,
    required this.title,
    required this.content,
    required this.categoryId,
    required this.subcategoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isTemplate = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
       
  Letter copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Letter(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isTemplate: isTemplate,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isTemplate': isTemplate,
    };
  }
  
  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      categoryId: json['categoryId'],
      subcategoryId: json['subcategoryId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isTemplate: json['isTemplate'] ?? false,
    );
  }
}
