// lib/services/review_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addReview({
  required String movieId,
  required double rating,
  required String comment,
}) async {
  // Create a new review document
  final reviewRef = _firestore.collection('reviews').doc();

  final review = Review(
    id: reviewRef.id,
    userId: 'anonymous', // Use 'anonymous' or some default value for unauthenticated users
    movieId: movieId,
    rating: rating,
    comment: comment,
    createdAt: Timestamp.now(),
  );

  // Save to Firestore
  await reviewRef.set(review.toFirestore());
}

  Stream<List<Review>> getMovieReviews(String movieId) {
    return _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList()
        );
  }

  Future<Review?> getUserReviewForMovie(String movieId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final querySnapshot = await _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Review.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }
}