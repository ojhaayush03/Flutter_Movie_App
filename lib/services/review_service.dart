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
  final reviewRef = _firestore.collection('reviews').doc(); // Create a Firestore document reference

  final review = Review(
    id: reviewRef.id,
    userId: 'anonymous', // Keep user ID as 'anonymous'
    movieId: movieId,
    rating: rating,
    comment: comment,
    createdAt: Timestamp.now(),
  );

  try {
    await reviewRef.set(review.toFirestore()); // ✅ Save to Firestore
    print("Review successfully added to Firestore!");
  } catch (e) {
    print("Error saving review: $e"); // Log any errors
  }
}


Stream<List<Review>> getMovieReviews(String movieId) {
  
  return _firestore
      .collection('reviews')
      .where('movieId', isEqualTo: movieId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        print("Fetched ${snapshot.docs.length} reviews for movieId: $movieId");
        for (var doc in snapshot.docs) {
          print("Review: ${doc.data()}"); // Debugging each review
        }
        return snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();
      });
}


  Future<Review?> getUserReviewForMovie(String movieId) async {
  final user = _auth.currentUser;
  if (user == null) {
    print("User not logged in, returning null");
    return null;
  }

  print("Fetching review for movie: $movieId by user: ${user.uid}");

  final querySnapshot = await _firestore
      .collection('reviews')
      .where('movieId', isEqualTo: movieId)
      .where('userId', isEqualTo: user.uid) // ✅ This will now work correctly
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    print("Review found: ${querySnapshot.docs.first.data()}");
    return Review.fromFirestore(querySnapshot.docs.first);
  }

  print("No review found for movie: $movieId by user: ${user.uid}");
  return null;
}


  // Method to save a review to Firestore
  Future<void> saveReview(String movieId, int rating, String comment) async {
    try {
      final reviewRef = _firestore.collection('reviews').doc(); // Creates a new document
      await reviewRef.set({
        'movieId': movieId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(), // Timestamp when the review was created
      });
      print("Review added successfully!");
    } catch (e) {
      print("Error saving review: $e");
    }
  }
}