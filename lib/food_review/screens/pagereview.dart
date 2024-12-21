import 'dart:convert';
import 'package:lohkan_app/screens/homepage.dart';
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
 // This will hold the current filter type

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
      Map<String, dynamic> topRatedDishes = {};
      for (var entry in entries) {
        String key = "${entry.fields.name}_${entry.fields.foodType}";
        if (!processedReviews.containsKey(key)) {
          processedReviews[key] = {
            'details': entry,
            'count': 1,
            'totalRating': entry.fields.rating
          };
        } else {
          processedReviews[key]['count']++;
          processedReviews[key]['totalRating'] += entry.fields.rating;
        }
      }
      processedReviews.forEach((key, value) {
        double avgRating = value['totalRating'] / value['count'];
        if (topRatedDishes.length < 3 || avgRating > topRatedDishes.values.last['avgRating']) {
          if (topRatedDishes.length == 3) {
            var keyToRemove = topRatedDishes.keys.last;
            topRatedDishes.remove(keyToRemove);
          }
          topRatedDishes[key] = {
            'details': value['details'],
            'avgRating': avgRating
          };
          topRatedDishes = Map.fromEntries(
            topRatedDishes.entries.toList()
              ..sort((e1, e2) => e2.value['avgRating'].compareTo(e1.value['avgRating']))
          );
        }
      });
      return {
        'reviews': processedReviews,
        'topRated': topRatedDishes.values.toList() // This list contains only the top 3 dishes
      };
    } else {
      throw Exception('Failed to load reviews');
    }
  }

    // Function to show popup
  void _showAddReviewDialog(BuildContext context) {
  // final request = Provider.of<CookieRequest>(context); // pakai yg di web pbp
  final request = context.read<CookieRequest>();

  // Controllers for text fields
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

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
                    String normalizedFoodName = toTitleCase(foodNameController.text.trim());
  

                    // Perform POST request
                    var response = await request.postJson(
                      'http://127.0.0.1:8000/food-review/create-review-flutter/',
                      jsonEncode({
                        'name': normalizedFoodName,
                        'food_type': selectedFoodType,
                        'rating': selectedRating,
                        'comments': commentsController.text,
                      }),
                    );
                  

                    if (response["message"].contains("successfully") || response['statusCode'] == 201) {
                      // print("SUKSES");
                      // Refetch the reviews to update the state
                      futureFoodReviews = fetchAndProcessReviews();

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Review successfully created!"),
                        backgroundColor: Colors.green,
                      ));
                      // print("MEONG");

                      // Close the modal
                      Navigator.pop(context);

                      // Trigger a state update to refresh the page
                      setState(() {});
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

    return Scaffold(
      body: Column(
        children: [
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
                 var reviews = snapshot.data!['reviews'].entries.where((MapEntry<String, dynamic> entry) {
                    var reviewDetails = entry.value['details'];
                    bool matchesFilter = filter == 'All' || reviewDetails.fields.foodType == filter;
                    bool matchesSearch = _searchQuery.isEmpty || reviewDetails.fields.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    return matchesFilter && matchesSearch;
                  }).map((e) => e.value).toList();
                  var topRatedDishes = snapshot.data!['topRated'];
                 
                  List<String> categories = ['All', 'Main Course', 'Dessert', 'Drinks', 'Snacks'];
                  return CustomScrollView(
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                            child: SizedBox(height: 20), // Space at the top
                      ),
                      


                      // Top Rated Dishes
                      SliverToBoxAdapter(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Top-Rated Dishes in LohKan",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D0000)),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                               ...List.generate(snapshot.data!['topRated'].length, (int index) =>
                                _buildTopRatedDishCard(snapshot.data!['topRated'][index], index)
                               ),
                              ],
                            ),
                          ),
                        ),
                      
                      // See How Others Rate the Food
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'See How Others Rate the Food 😍',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6D0000)),
                                textAlign: TextAlign.right,
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
                            SizedBox(height: 20),  // Adjust the height value to get the desired spacing
                          ],
                        ),
                      ),
                      SliverAppBar(
                        floating: true,
                        snap: true,
                        pinned: true,
                        title: Container(
                          height: 52, // Tetapkan tinggi yang cukup untuk chip dan padding
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              bool isSelected = filter == categories[index]; // Menentukan apakah chip saat ini terpilih
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0), // Spasi antar chip
                                child: ChoiceChip(
                                  labelPadding: EdgeInsets.symmetric(horizontal: 12.0), // Padding dalam chip
                                  label: Text(
                                    categories[index],
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      filter = selected ? categories[index] : 'All';
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Colors.grey[200], // Warna background untuk chip yang tidak terpilih
                                  selectedColor: Color(0xFF6D0000), // Warna untuk chip yang terpilih
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black), // Gaya teks
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Di dalam SliverArea setelah SliverAppBar dan sebelum SliverGrid
                      SliverList(
                        delegate: SliverChildListDelegate([
                          if (reviews.isEmpty && _searchQuery.isNotEmpty || reviews.isEmpty && filter != 'All')
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: Text("No Reviews Found 😢", style: TextStyle(fontSize: 18, color: Color(0xFF9B3C3C))),
                              ),
                            ),
                            // Menampilkan "No Reviews Found" jika tidak ada review yang cocok setelah filtering
                        
                        ]),
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
                                        toTitleCase(review['details'].fields.name),
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
                                          '${review['count']} Reviews',
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
              }
            ),
          ),
        ]
      )
    );
  }

  String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return '';
  }).join(' ');
}

  Widget _buildTopRatedDishCard(Map<String, dynamic> dish, int index) {
  String formattedName = toTitleCase(dish['details'].fields.name); // Format the name
  List<IconData> icons = [Icons.looks_one, Icons.looks_two, Icons.looks_3];
  List<Color> colors = [Color(0xFFFFD700), Color(0xFFC0C0C0), Color(0xFFCD7F32)];

  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 3,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: colors[index % 3],
          child: Icon(icons[index % 3], color: Colors.white),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                 dish['details'].fields.foodType,
                style: TextStyle(color: Colors.grey[600]),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 5),
                  Text(
                    '${dish['avgRating'].toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
}
