class Post {
  final int? id;
  final String title;
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Post({
    this.id,
    required this.title,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Post to a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create a Post from a Map (from database)
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // Create a copy of Post with some fields replaced
  Post copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Post(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
}
