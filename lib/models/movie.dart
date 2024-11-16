// lib/models/movie.dart
class Movie {
  final int id;
  final String title;
  final String summary;
  final String? imageUrl;

  Movie({
    required this.id,
    required this.title,
    required this.summary,
    this.imageUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final show = json['show'];
    return Movie(
      id: show['id'],
      title: show['name'],
      summary: show['summary'] ?? 'No summary available',
      imageUrl: show['image']?['medium'] ?? show['image']?['original'],
    );
  }
}