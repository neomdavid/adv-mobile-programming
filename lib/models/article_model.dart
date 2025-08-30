class Article {
  final int userId;
  final int id;
  final String title;
  final String body;
  final List<String>? tags;
  final String? createdAt;
  final String? updatedAt;
  
  Article({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
    this.tags,
    this.createdAt,
    this.updatedAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
