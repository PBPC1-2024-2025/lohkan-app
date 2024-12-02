import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';
import 'see_reviews.dart'; // Ensure this import points to your DetailScreen

class PageFoodReview extends StatefulWidget {
  const PageFoodReview({Key? key}) : super(key: key);

  @override
  _PageFoodReviewState createState() => _PageFoodReviewState();
}

class _PageFoodReviewState extends State<PageFoodReview> {
  late Future<Map<String, dynamic>> futureFoodReviews;

  @override
  void initState() {
    super.initState();
    futureFoodReviews = fetchAndProcessReviews();
  }

  Future<Map<String, dynamic>> fetchAndProcessReviews() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/food-review/json/'));
    if (response.statusCode == 200) {
      List<ReviewEntry> entries = reviewEntryFromJson(response.body);
      Map<String, dynamic> processedReviews = {};
      for (var entry in entries) {
        String key = "${entry.fields.name}_${entry.fields.foodType}";
        if (processedReviews.containsKey(key)) {
          processedReviews[key]['count']++;
        } else {
          processedReviews[key] = {
            'details': entry,
            'count': 1
          };
        }
      }
      return processedReviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('See How Others Rate the Food 😍'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureFoodReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var reviews = snapshot.data!.values.toList();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => DetailScreen(review: review['details']),
                      ));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(review['details'].fields.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('Type: ${review['details'].fields.foodType}'),
                        SizedBox(height: 8),
                        ElevatedButton(
                          child: Text('See Reviews (${review['count']})'),  // Dynamic review count
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(review: review['details']),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No reviews available'));
          }
        },
      ),
    );
  }
}
