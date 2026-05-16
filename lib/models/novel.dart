class Novel {
  final int id;
  final String title;
  final String slug;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String? coverPath;
  final String sourceUrl;
  final String sourceSite;
  final int totalChapters;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  Novel({
    required this.id,
    required this.title,
    required this.slug,
    this.author,
    this.description,
    this.coverUrl,
    this.coverPath,
    required this.sourceUrl,
    required this.sourceSite,
    this.totalChapters = 0,
    this.language = 'fr',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      author: json['author'],
      description: json['description'],
      coverUrl: json['cover_url'],
      coverPath: json['cover_path'],
      sourceUrl: json['source_url'] ?? '',
      sourceSite: json['source_site'] ?? '',
      totalChapters: json['total_chapters'] ?? 0,
      language: json['language'] ?? 'fr',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'author': author,
      'description': description,
      'cover_url': coverUrl,
      'cover_path': coverPath,
      'source_url': sourceUrl,
      'source_site': sourceSite,
      'total_chapters': totalChapters,
      'language': language,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}