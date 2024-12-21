import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailScreen extends StatelessWidget {
  final String foodName;
  final String foodType;

  DetailScreen({required this.foodName, required this.foodType});

  Future<Map<String, dynamic>> fetchReviews() async {
    final Uri url = Uri.parse('http://10.0.2.2:8000/food-review/reviews/food/$foodName/$foodType/?format=json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reviews for $foodName of type $foodType');
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleCaseFoodName = toTitleCase(foodName);
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for $titleCaseFoodName", style: TextStyle(color: Colors.white)), 
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
                    padding: EdgeInsets.symmetric(horizontal: 90, vertical: 5), // Internal padding
                    margin: EdgeInsets.symmetric(horizontal: 30), // Margin for the sides
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
    
    int starCount = int.parse(review['rating'].toString());
    List<Widget> stars = List.generate(5, (index) {
      return Icon(
        index < starCount ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      );
    });

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),  // changes position of shadow
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review['username'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: stars,
          ),
          SizedBox(height: 8),
          Text(
            review['comments'],
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}


// Fungsi untuk mengubah string ke title case
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}