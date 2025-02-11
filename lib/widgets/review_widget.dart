// lib/widgets/review_widget.dart
import 'package:flutter/material.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewWidget extends StatefulWidget {
  final String movieId;
  final String movieTitle;

  const ReviewWidget({
    Key? key, 
    required this.movieId, 
    required this.movieTitle,
  }) : super(key: key);

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  Review? _existingReview;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
  try {
    final review = await _reviewService.getUserReviewForMovie(widget.movieId);
    
    if (mounted) {
      setState(() {
        _existingReview = review;
        
        // If the review exists, populate the form
        if (review != null) {
          _rating = review.rating;
          _commentController.text = review.comment;
        } else {
          // If no review exists, reset the form or handle as needed
          _rating = 0;  // Reset rating to default (0)
          _commentController.clear();  // Clear the comment field
        }
      });
    }
  } catch (e) {
    // Handle error if something goes wrong
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load review: $e')),
    );
  }
}


  void _submitReview() async {
  if (_rating == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a rating')),
    );
    return;
  }

  try {
    await _reviewService.addReview(
      movieId: widget.movieId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    setState(() {});  // Force UI refresh after submission

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review submitted for ${widget.movieTitle}')),
    );

    await _loadExistingReview(); // Reload review after submission
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit review: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Star Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1.0;
                });
              },
            );
          }),
        ),

        // Comment Input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Write your review...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            maxLines: 4,
          ),
        ),

        // Submit Button
        Center(
          child: ElevatedButton(
            onPressed: _submitReview,
            child: Text(_existingReview != null ? 'Update Review' : 'Submit Review'),
          ),
        ),

        // Reviews Stream
        const SizedBox(height: 20),
        const Text(
          'All Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        StreamBuilder<List<Review>>(
          stream: _reviewService.getMovieReviews(widget.movieId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No reviews yet'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final review = snapshot.data![index];
                return ListTile(
                  title: Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < review.rating 
                          ? Icons.star 
                          : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
                  subtitle: Text(review.comment),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
