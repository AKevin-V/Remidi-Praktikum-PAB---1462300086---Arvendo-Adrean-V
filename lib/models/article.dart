class Article {
  final int id;
  final String title;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String url;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? '',
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'url': url,
    };
  }
}
