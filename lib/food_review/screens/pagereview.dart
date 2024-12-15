import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';
import 'see_reviews.dart'; // Ensure this points to your DetailScreen

class PageFoodReview extends StatefulWidget {
  const PageFoodReview({Key? key}) : super(key: key);

  @override
  _PageFoodReviewState createState() => _PageFoodReviewState();
}

class _PageFoodReviewState extends State<PageFoodReview> {
  late Future<Map<String, dynamic>> futureFoodReviews;
  String filter = 'All';  // This will hold the current filter type

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
        if (!processedReviews.containsKey(key)) {
          processedReviews[key] = {
            'details': entry,
            'count': 1
          };
        } else {
          processedReviews[key]['count']++;
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureFoodReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var reviews = snapshot.data!.values.toList().where((r) {
              if (filter == 'All') return true;
              return r['details'].fields.foodType == filter;
            }).toList();
            List<String> categories = ['All', 'Main Course', 'Dessert', 'Drinks', 'Snacks'];
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'See How Others Rate the Food 😍',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D0000)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: true,
                  // backgroundColor: Colors.white,
                  title: Wrap(
                    spacing: 8.0,
                    alignment: WrapAlignment.center,
                    children: List<Widget>.generate(categories.length, (int index) {
                      return ChoiceChip(
                        label: Text(categories[index]),
                        selected: filter == categories[index],
                        onSelected: (bool selected) {
                          setState(() {
                            filter = selected ? categories[index] : 'All';
                          });
                        },
                      );
                    }),
                  ),
                ),
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 0.8,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      var review = reviews[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.all(10), // Adjust this value to increase the space around each card
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                foodName: review['details'].fields.name,
                                foodType: review['details'].fields.foodType,
                              ),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['details'].fields.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6D0000),
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'Type: ${review['details'].fields.foodType}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF9B3C3C),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text(
                                    'See Reviews (${review['count']})',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(
                                          foodName: review['details'].fields.name,
                                          foodType: review['details'].fields.foodType,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: reviews.length,
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No reviews available'));
          }
        },
      ),
    );
  }
}
