// lib/models/review.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String movieId;
  final double rating;
  final String comment;
  final Timestamp createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}