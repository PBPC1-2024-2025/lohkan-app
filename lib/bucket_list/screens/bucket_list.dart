import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/bucket_list/components/food_item_card.dart';
import 'package:lohkan_app/bucket_list/models/bucketlist_entry.dart';
import 'package:lohkan_app/explore/models/food.dart';
import 'dart:convert';

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  final _formKey = GlobalKey<FormState>();
  String _collectionName = "";
  int? selectedIndex;

  void refreshList() {
    final request = context.read<CookieRequest>();

    setState(() {
      fetchBucketList(request);
    });
  }

  Future<List<BucketListEntry>> fetchBucketList(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/bucket-list/json/');
    
    // Melakukan decode response menjadi bentuk json
    var data = response;
    
    // Melakukan konversi data json menjadi object BucketListEntry
    List<BucketListEntry> listBucketEntry = [];
    for (var d in data) {
      if (d != null) {
        listBucketEntry.add(BucketListEntry.fromJson(d));
      }
    }
    return listBucketEntry;
  }

  Future<Food> fetchFoodDetails(String foodId, CookieRequest request) async {
    try {
      // debugPrint('Fetching food details for ID: $foodId');
      final response = await request.get('http://127.0.0.1:8000/bucket-list/get-food/$foodId/');
      // debugPrint('Received response: $response');
      
      // Restructure the response to match the expected model
      final modifiedResponse = {
        "model": "explore.food",
        "pk": response['id'],
        "fields": {
          "date": DateTime.now().toString().split(' ')[0], // Current date as fallback
          "name": response['name'],
          "description": response['description'],
          "min_price": response['min_price'],
          "max_price": response['max_price'],
          "image_link": response['image_link'],
          "type": response['type'],
        }
      };
      
      return Food.fromJson(modifiedResponse);
    } catch (e) {
      debugPrint('Error fetching food details: $e');
      throw Exception('Failed to fetch food details: $e');
    }
  }

  // Function to show popup
  void _showCreateCollectionSheet(BuildContext context) {
    final request = context.read<CookieRequest>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust height based on content
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
              children: [
                // top line
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCC7BA),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // title
                    const Text(
                      'Create new collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Popup
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Collection name',
                    hintStyle: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 13
                    ), // Hint text color
                    filled: true, // Enables the background color
                    fillColor: Color(0xFFF9F9F9), // Grayish background color
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000), width: 2), // Thicker red border when focused
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _collectionName = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Collection name cannot be empty!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Send to Django
                      final response = await request.post(
                        'http://127.0.0.1:8000/bucket-list/create-bucket-list-flutter/',
                        jsonEncode({
                          'name': _collectionName,
                        }),
                      );

                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Collection successfully created!"),
                          ));
                          Navigator.pop(context);
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                            content:
                              Text("There seems to be an issue, please try again."),
                          ));
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF550000), // Red background
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Create collection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCollectionSettingsSheet(BuildContext context, String bucketListName, String bucketListId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
            children: [
              // Top line
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCC7BA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              // Edit collection (clickable)
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // print('Edit collection clicked');
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _showEditCollectionSheet(context, bucketListName, bucketListId);
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 16),
                      Text(
                        'Edit collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Remove collection (clickable)
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  showRemoveCollectionDialog(context, bucketListName, bucketListId);
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined),
                      SizedBox(width: 16),
                      Text(
                        'Remove collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCollectionSheet(BuildContext context, String bucketListName, String bucketListId) {
    final request = context.read<CookieRequest>();
    final editFormKey = GlobalKey<FormState>();
    String newName = bucketListName;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adjust height based on content
              crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
              children: [
                // top line
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCC7BA),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // title
                    const Text(
                      'Edit collection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Popup
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: bucketListName,
                  decoration: InputDecoration(
                    hintText: 'Collection name',
                    hintStyle: TextStyle(
                      color: Color(0xFFB3B3B3),
                      fontSize: 13
                    ), // Hint text color
                    filled: true, // Enables the background color
                    fillColor: Color(0xFFF9F9F9), // Grayish background color
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000)),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF550000), width: 2), // Thicker red border when focused
                    ),
                  ),
                  onChanged: (String? value) {
                    newName = value ?? ''; // Update local variable instead of using setState
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Collection name cannot be empty!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (editFormKey.currentState!.validate()) {
                      try {
                        final response = await request.post(
                          'http://127.0.0.1:8000/bucket-list/edit-bucket-list-flutter/$bucketListId/',
                          jsonEncode({
                            'name': newName,
                          }),
                        );
                        debugPrint('Request data: ${jsonEncode({
                          'name': newName,
                        })}');

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Collection successfully edited!"),
                              ),
                            );
                            Navigator.pop(context);
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? "There seems to be an issue, please try again."),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF550000), // Red background
                    foregroundColor: Colors.white, // White text
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Save changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showRemoveCollectionDialog(BuildContext context, String bucketListName, String bucketListId) {
    final request = context.read<CookieRequest>();

    showDialog(
      context: context,
      barrierDismissible: true, // Allow tapping outside to close the modal
      builder: (BuildContext context) {
        return Dialog(
          // insetPadding: const EdgeInsets.symmetric(horizontal: 16), // Full width with padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  'Remove collection $bucketListName?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Notice
                const Text(
                  'Your changes cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Remove Button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final response = await request.post(
                            'http://127.0.0.1:8000/bucket-list/delete-bucket-list-flutter/$bucketListId/',
                            jsonEncode(<String, String>{
                              'delete': 'yes',
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Collection successfully removed!"),
                                ),
                              );
                              Navigator.pop(context); // Close the dialog
                              setState(() {
                                // Reset selectedIndex if it's the last item, 
                                // or adjust it if a previous item still exists
                                if (selectedIndex != null) {
                                  selectedIndex = null;
                                }
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("There seems to be an issue, please try again."),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error: ${e.toString()}"),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF550000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  // main components
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Bucket List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchBucketList(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data!.length == 0) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Want to save food for another time?\nHere is the place!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _showCreateCollectionSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF550000),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(240, 40),
                      ),
                      child: const Text(
                        'Create collection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ]
                )
              );
            } else {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showCreateCollectionSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFFCCC7BA),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: const Text(
                            '+ Add new list',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFCCC7BA),
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (_, index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedIndex == index 
                                      ? const Color(0xFF550000)
                                      : const Color(0xFFD9D9D9),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  ),
                                  child: Text(
                                    "${snapshot.data![index].fields.name}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: selectedIndex == index 
                                        ? Colors.white
                                        : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Only show content if a bucket list is selected
                  if (selectedIndex != null) Expanded(
                    child: Column(
                      children: [
                        // Header container always at the top
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 11, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "${snapshot.data![selectedIndex!].fields.foods.length}",
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const TextSpan(
                                      text: ' item(s)',
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _showCollectionSettingsSheet(context, snapshot.data![selectedIndex!].fields.name, snapshot.data![selectedIndex!].pk);
                                },
                              ),
                            ],
                          ),
                        ),
                        // Content below header
                        Expanded(
                          child: snapshot.data![selectedIndex!].fields.foods.length == 0
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Your bucket list is empty.\nGo get exploring!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ]
                                )
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data![selectedIndex!].fields.foods.length,
                                itemBuilder: (_, idx) {
                                  return FutureBuilder<Food>(
                                    future: fetchFoodDetails(
                                      snapshot.data![selectedIndex!].fields.foods[idx],
                                      request
                                    ),
                                    builder: (context, foodSnapshot) {
                                      if (foodSnapshot.data == null) {
                                        return const Center(child: CircularProgressIndicator());
                                      } else if (foodSnapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (foodSnapshot.hasError) {
                                        return Text('Error: ${foodSnapshot.error}');
                                      } else if (foodSnapshot.hasData) {
                                        return FoodItemCard(
                                          foodId: foodSnapshot.data!.pk,
                                          bucketId: snapshot.data![selectedIndex!].pk,
                                          title: foodSnapshot.data!.fields.name,
                                          description: foodSnapshot.data!.fields.description,
                                          price: '${foodSnapshot.data!.fields.minPrice} - ${foodSnapshot.data!.fields.maxPrice}',
                                          imagePath: foodSnapshot.data!.fields.imageLink,
                                          foodType: '${foodSnapshot.data!.fields.type}',
                                          onRemove: refreshList,
                                        );
                                      } else {
                                        return const Text('No data available');
                                      }
                                    },
                                  );
                                },
                              ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }
          }
        }
      ),
    );
  }
}
