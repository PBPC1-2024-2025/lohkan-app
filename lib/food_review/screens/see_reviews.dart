import 'package:flutter/material.dart';
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';

class DetailScreen extends StatelessWidget {
  final ProductEntry review;

  DetailScreen({required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for ${review.fields.name}"),
        backgroundColor: Colors.red, // Adjust the color to match your theme
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Type: ${review.fields.foodType}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100], // Adjust the color to match your theme
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${review.fields.rating} ★",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Text(
                getRecommendationLabel(review.fields.rating as double),
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
              SizedBox(height: 20),
              for (var comment in review.fields.comments.split('\n')) // Assuming multiple comments are separated by new lines
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ReviewCard(comment: comment),
                ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the main review page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Adjust the button color to match your theme
                  ),
                  child: Text('Back to Main Reviews'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String comment;

  ReviewCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              Text("5.0"), // Assuming the rating for each comment
            ],
          ),
        ],
      ),
    );
  }
}

String getRecommendationLabel(double rating) {
  if (rating >= 4.5) {
    return "Highly Recommended! 🤩";
  } else if (rating >= 4.0) {
    return "Recommended! 😊";
  } else if (rating >= 3.0) {
    return "Fairly Good 😐";
  } else {
    return "Might be better 🤔";
  }
}

