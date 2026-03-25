class Post {
  final int? id;
  final String title;
  final String description;
  final DateTime? timestamp;

  Post({
    this.id,
    required this.title,
    required this.description,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String)
          : null,
    );
  }

  Post copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? timestamp,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
