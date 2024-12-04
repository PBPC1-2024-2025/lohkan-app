import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailScreen extends StatelessWidget {
  final String foodName;
  final String foodType;

  DetailScreen({required this.foodName, required this.foodType});

  Future<Map<String, dynamic>> fetchReviews() async {
    final Uri url = Uri.parse('http://127.0.0.1:8000/food-review/reviews/food/$foodName/$foodType/?format=json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews for $foodName of type $foodType');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for $foodName", style: TextStyle(color: Colors.white)), 
        backgroundColor: Color(0xFF6D0000),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            var reviews = snapshot.data!['reviews'] as List<dynamic>;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure elements stretch to full width
                children: [
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF6D0000), // Dark red color as per your design
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Internal padding
                    margin: EdgeInsets.symmetric(horizontal: 50), // Margin for the sides
                    child: Text(
                      "Type: $foodType",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Text color is white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text("${snapshot.data!['average_rating'].toStringAsFixed(1)}", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ),
                  Center(
                    child: Text(snapshot.data!['rating_label'], style: TextStyle(fontSize: 18, color: Colors.red)),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF9B3C3C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: Center(
                      child: Text('Back to Main Reviews', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 20),
                  ...reviews.map((review) => ReviewCard(review: review)).toList(),
                ],
              ),
            );
          } else {
            return Text("No reviews found");
          }
        },
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final dynamic review;

  ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero, // Remove margin for full width
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text("Reviewed by: ${review['username']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text("${review['rating']} Stars\n${review['comments']}", style: TextStyle(fontSize: 16)),
        isThreeLine: true,
      ),
    );
  }
}
