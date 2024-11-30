import 'package:flutter/material.dart';
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';
import 'package:lohkan_app/food_review/screens/see_reviews.dart';
import 'package:http/http.dart' as http;

class PageReviewScreen extends StatefulWidget {
  @override
  _PageReviewScreenState createState() => _PageReviewScreenState();
}

class _PageReviewScreenState extends State<PageReviewScreen> {
  Future<List<ProductEntry>>? futureReviews;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureReviews = fetchReviews();
  }

  Future<List<ProductEntry>> fetchReviews() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/food-review/json'));
    if (response.statusCode == 200) {
      return productEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top-Rated Dishes in LohKan'),
      ),
      body: FutureBuilder<List<ProductEntry>>(
        future: futureReviews,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ProductEntry>? reviews = snapshot.data;
            return ListView.builder(
              itemCount: reviews?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews![index].fields.name),
                  subtitle: Text('${reviews[index].fields.foodType} - ${reviews[index].fields.rating} Stars'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(review: reviews[index])));
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}

