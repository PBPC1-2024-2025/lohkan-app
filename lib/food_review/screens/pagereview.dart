import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'see_reviews.dart'; // Ensure this points to your DetailScreen

class PageFoodReview extends StatefulWidget {
  const PageFoodReview({Key? key}) : super(key: key);

  @override
  _PageFoodReviewState createState() => _PageFoodReviewState();
}

class _PageFoodReviewState extends State<PageFoodReview> {
  String _searchQuery = '';
  late Future<Map<String, dynamic>> futureFoodReviews;
  final _formKey = GlobalKey<FormState>();
  String currentSearchTerm = '';
  String filter = 'All'; 
  String _foodName = "";
  String _foodType = ""; // Default value
  int _rating = 0;
  String _comments = ""; // This will hold the current filter type

  @override
  void initState() {
    super.initState();
    futureFoodReviews = fetchAndProcessReviews();
  }

  Future<Map<String, dynamic>> fetchAndProcessReviews() async {
  var url = Uri.parse('http://127.0.0.1:8000/food-review/json/');
  final response = await http.get(url);
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


    // Function to show popup
  void _showAddReviewDialog(BuildContext context) {
  final request = Provider.of<CookieRequest>(context, listen: false);

  // Controllers for text fields
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  TextEditingController searchController = TextEditingController();


  // State variables for dropdown selections
  String? selectedFoodType;
  int? selectedRating = 1;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Write a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: foodNameController,
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedFoodType,
                items: ['Main Course', 'Dessert', 'Drinks', 'Snacks'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedFoodType = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Select Food Type',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<int>(
                value: selectedRating,
                items: List.generate(5, (index) => index + 1).map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedRating = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Rating (1-5)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: commentsController,
                decoration: InputDecoration(
                  labelText: 'Comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your comments';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Perform POST request
                    var response = await http.post(
                      Uri.parse('http://127.0.0.1:8000/food-review/create-review-flutter/'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode({
                        'name': foodNameController.text,
                        'food_type': selectedFoodType,
                        'rating': selectedRating,
                        'comments': commentsController.text,
                      }),
                    );
                  

                    if (response.statusCode == 201 || response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Review successfully created!"),
                        backgroundColor: Colors.green,
                      ));
                      Navigator.pop(context); // Close the modal after submitting
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("There was an issue submitting your review. Please try again."),
                        backgroundColor: Colors.red,
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF9B3C3C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Publish!'),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
   Future<List<ReviewEntry>> fetchReviews(CookieRequest request) async {
      final response = await request.get('http://127.0.0.1:8000/food-review/create-review-flutter/json');

      if (response.statusCode == 200) {
        // Decode the JSON response into a list of dynamic objects
        List<dynamic> jsonResponse = jsonDecode(response.body);

        // Filter and convert the JSON objects to ReviewEntry instances only if they match the search query
        return jsonResponse.map((d) => ReviewEntry.fromJson(d)).where((review) {
          return review.fields.name.toLowerCase().contains(_searchQuery.toLowerCase()) && 
                (filter == 'All' || review.fields.foodType == filter);
        }).toList();
      } else {
        throw Exception('Failed to fetch reviews');
      }
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () {_showAddReviewDialog(context);},
              child: Text('Rate Your Food'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF9B3C3C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          
          
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureFoodReviews,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  // Filter the reviews according to the search query and the selected filter
                  var reviews = snapshot.data!.entries.where((MapEntry<String, dynamic> entry) {
                    var reviewDetails = entry.value['details'];
                    bool matchesFilter = filter == 'All' || reviewDetails.fields.foodType == filter;
                    bool matchesSearch = _searchQuery.isEmpty || reviewDetails.fields.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesFilter && matchesSearch;
                  }).map((e) => e.value).toList();

                 
              List<String> categories = ['All', 'Main Course', 'Dessert', 'Drinks', 'Snacks'];
              return CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'See How Others Rate the Food 😍',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D0000)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Search Food',
                              suffixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                               
                              });
                            },
                          ),
                        ),
                      ],
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
            };
          }),
        ),
      ],
    )
    );
  }
}

