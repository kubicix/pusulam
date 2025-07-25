import 'dart:convert';

class Plan {
  final String id;
  final String title;
  final String description;
  final String theme;
  final String duration;
  final String dailyTime;
  final String content;
  final DateTime createdAt;

  Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.theme,
    required this.duration,
    required this.dailyTime,
    required this.content,
    required this.createdAt,
  });

  // JSON'dan Plan oluştur
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      theme: json['theme'] ?? '',
      duration: json['duration'] ?? '',
      dailyTime: json['dailyTime'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Plan'ı JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'theme': theme,
      'duration': duration,
      'dailyTime': dailyTime,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // SharedPreferences için string formatı
  String toJsonString() => json.encode(toJson());

  // String'den Plan oluştur
  static Plan fromJsonString(String jsonString) {
    return Plan.fromJson(json.decode(jsonString));
  }

  // Kopyalama metodu
  Plan copyWith({
    String? id,
    String? title,
    String? description,
    String? theme,
    String? duration,
    String? dailyTime,
    String? content,
    DateTime? createdAt,
  }) {
    return Plan(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      duration: duration ?? this.duration,
      dailyTime: dailyTime ?? this.dailyTime,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Plan(id: $id, title: $title, theme: $theme, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
