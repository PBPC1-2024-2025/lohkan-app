import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/bucket_list/components/food_item_card.dart';
import 'package:lohkan_app/bucket_list/models/bucketlist_entry.dart';
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

  void _showCollectionSettingsSheet(BuildContext context) {
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
                  _showEditCollectionSheet(context);
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
                  showRemoveCollectionDialog(context);
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

  void _showEditCollectionSheet(BuildContext context) {
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
              const TextField(
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
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the create action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection edited!')),
                  );
                  Navigator.of(context).pop(); // Close the sheet
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
        );
      },
    );
  }

  void showRemoveCollectionDialog(BuildContext context) {
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
                const Text(
                  'Remove collection hehe?',
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
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF550000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0), // Adjust the value for less circular
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
              return
                Center(
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
                          // Show the bottom sheet when this button is pressed
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
                        // "+ Add new list" button
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

                        // Wrap Expanded with SizedBox to constrain height
                        Expanded(
                          child: SizedBox(
                            height: 32, // Set this to match your "+ Add new list" button height
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (_, index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedIndex = index;  // Update selected index
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedIndex == index 
                                      ? const Color(0xFF550000)  // Selected button color
                                      : const Color(0xFFD9D9D9), // Default gray color
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
                                        ? Colors.white  // Selected button text color
                                        : Colors.black, // Default text color
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
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Vertical alignment
                        crossAxisAlignment: CrossAxisAlignment.start, // Horizontal alignment                      
                        children: [
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
                                        text: "${snapshot.data![index].fields.foods.length}",
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
                                    _showCollectionSettingsSheet(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(itemBuilder: (i, idx) => FoodItemCard(
                            title: "${snapshot.data![index].fields.foods[idx].fields.name}",
                            description: 'Ikan kuning-kuning',
                            price: '40000 - 60000',
                            imagePath: 'assets/resto1.jpeg'
                          ),
                          )
                        ],
                      ),
                    ),
                  )
                ]
              );
            }
          }
        }
      ),

      // EMPTY LIST SCREEN (KEMUNGKINAN UDH GA BUTUH)
      // body: Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       const Text(
      //         'Want to save food for another time?\nHere is the place!',
      //         textAlign: TextAlign.center,
      //         style: TextStyle(fontSize: 16),
      //       ),
      //       const SizedBox(height: 12),
      //       ElevatedButton(
      //         onPressed: () {
      //           // Show the bottom sheet when this button is pressed
      //           _showCreateCollectionSheet(context);
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: const Color(0xFF550000),
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(10),
      //           ),
      //           minimumSize: const Size(240, 40),
      //         ),
      //         child: const Text(
      //           'Create collection',
      //           style: TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.bold,
      //             color: Colors.white,
      //           ),
      //         ),
      //       ),
            
            // ITEM COUNT AND SETTINGS BUTTON ROW
            // const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     mainAxisSize: MainAxisSize.max,
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       RichText(
            //         text: const TextSpan(
            //           style: TextStyle(fontSize: 11, color: Colors.black),
            //           children: [
            //             TextSpan(
            //               text: '2',
            //               style: TextStyle(fontWeight: FontWeight.bold),
            //             ),
            //             TextSpan(
            //               text: ' item(s)',
            //             ),
            //           ],
            //         ),
            //       ),
            //       const Spacer(),
            //       IconButton(
            //         icon: const Icon(
            //           Icons.settings,
            //           color: Colors.black,
            //           size: 16,
            //         ),
            //         onPressed: () {
            //           _showCollectionSettingsSheet(context);
            //         },
            //       ),
            //     ],
            //   ),
            // ),

            // BUCKET LIST BUTTONS LIST
              // ADD NEW LIST BUTTON
            // const SizedBox(height: 20),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 16),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       // add new list button
            //       ElevatedButton(
            //         onPressed: () {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Add new list clicked!')),
            //           );
            //         },
            //         style: ElevatedButton.styleFrom(
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //             side: const BorderSide(
            //               color: Color(0xFFCCC7BA), // Border color
            //               width: 2, // Border thickness
            //             ),
            //           ),
            //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //         ),
            //         child: const Text(
            //           '+ Add new list',
            //           style: TextStyle(
            //             fontSize: 13,
            //             fontWeight: FontWeight.bold,
            //             color: Color(0xFFCCC7BA),
            //           ),
            //         ),
            //       ),

            //       // LIST BUTTON LAINNYA
            //       const SizedBox(width: 8), // Gap between items
            //       ElevatedButton(
            //         onPressed: () {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(content: Text('Bucket list 1 clicked!')),
            //           );
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: const Color(0xFF550000),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            //         ),
            //         child: const Text(
            //           'Bucket list 1',
            //           style: TextStyle(
            //             fontSize: 13,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            
            
      //     ],
      //   ),
      // ),
    );
  }
}
