import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/screens/form_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'explore.dart';
import 'package:lohkan_app/bucket_list/models/bucketlist_entry.dart';

class FoodPage extends StatefulWidget {
  final food;
  final String username;
  const FoodPage({super.key, this.food, required this.username});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  final _controller = ScrollController();
  var _bookMarkColor = 0x66550000;
  @override
  void initState() {
    super.initState();

    // Setup the listener.
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        bool isTop = _controller.position.pixels == 0;
        if (!isTop) {
          setState(() {
            _bookMarkColor = 0xFF550000;
          });
        }
      } else {
        setState(() {
          _bookMarkColor = 0x66550000;
        });
      }
    });
  }

  void _showBookmarkSheet(BuildContext context, String foodId) {
    final request = context.read<CookieRequest>();
    final bookmarkFormKey = GlobalKey<FormState>();
    String? selectedValue;
    String? selectedId;

    Future<List<BucketListEntry>> fetchBucketList(CookieRequest request) async {
      final response = await request.get('http://marla-marlena-lohkan.pbp.cs.ui.ac.id/bucket-list/json/');
      
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: bookmarkFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                    // Title
                    const Text(
                      'Bookmark food',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // Dropdown with FutureBuilder
                const SizedBox(height: 20),
                FutureBuilder<List<BucketListEntry>>(
                  future: fetchBucketList(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF550000),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return const Text('Error loading bucket lists');
                    }

                    final bucketLists = snapshot.data ?? [];
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFF550000),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                        ),
                        hint: const Text(
                          'Select a bucket list', // Placeholder text
                          style: TextStyle(color: Color(0xFFB3B3B3)), // Optional: Style for the placeholder
                        ),
                        items: bucketLists.map((BucketListEntry bucket) {
                          return DropdownMenuItem<String>(
                            value: bucket.pk.toString(),
                            child: Text(bucket.fields.name),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          selectedId = newValue ?? '';
                          // Find the corresponding name for the selected ID
                          final selectedBucket = bucketLists.firstWhere(
                            (bucket) => bucket.pk.toString() == newValue,
                            orElse: () => throw Exception('Bucket not found'),
                          );
                          selectedValue = selectedBucket.fields.name;
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a bucket list!';
                          }
                          return null;
                        },
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF550000)),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (bookmarkFormKey.currentState!.validate()) {
                      try {
                        final response = await request.post(
                          'http://marla-marlena-lohkan.pbp.cs.ui.ac.id/explore/add-to-bucket-list/$foodId/$selectedId/',
                          jsonEncode({
                            'name': selectedValue,
                          }),
                        );
                        
                        if (context.mounted) {
                          if (response['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Collection successfully updated!"),
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
                    backgroundColor: const Color(0xFF550000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    var foodType = 'Type.MC';
    var typeColor = Colors.green.shade400;
    if (widget.food.fields.type.toString() == 'Type.MC') {
      foodType = 'Main Course';
      typeColor = Colors.green.shade300;
    } else if (widget.food.fields.type.toString() == 'Type.DS') {
      foodType = 'Dessert';
      typeColor = Colors.yellow.shade300;
    } else if (widget.food.fields.type.toString() == 'Type.DR') {
      foodType = 'Drinks';
      typeColor = Colors.pink.shade300;
    } else if (widget.food.fields.type.toString() == 'Type.SN') {
      foodType = 'Snacks';
      typeColor = Colors.red.shade300;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          titleSpacing: 0,
          title: SizedBox(
            width: MediaQuery.of(context).size.width * 1,
            child: const Row(
              children: [
                Text(
                  "Food Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          actions: widget.username != 'admin'
              ? null
              : [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (String value) async {
                        if (value == 'Edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditFoodForm(
                                username: widget.username,
                                food: widget.food,
                              ),
                            ),
                          ).then((value) {
                            if (value) {
                              setState(() {});
                            }
                          });
                        } else {
                          bool confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirm Delete"),
                              content: const Text(
                                  "Are you sure you want to delete this food?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Delete"),
                                ),
                              ],
                            ),
                          );
                          if (confirmDelete) {
                            final response = await request.postJson(
                              "http://marla-marlena-lohkan.pbp.cs.ui.ac.id/explore/delete-food-flutter/${widget.food.pk}/",
                              jsonEncode(
                                <String, String>{
                                  'delete': 'yes',
                                },
                              ),
                            );
                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Food successfully deleted!"),
                                ));
                                Navigator.of(context).pop(true);
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text("Something went wrong, try again."),
                                ));
                              }
                            }
                          }
                        }
                        // Kirim ke Django dan tunggu respons
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Text('Delete'),
                        )
                      ],
                    ),
                  )
                ],
        ),
        extendBody: true,
        body: ListView(
          controller: _controller,
          children: [
            CachedNetworkImage(
                imageUrl: widget.food.fields.imageLink,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.food.fields.name}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${widget.food.fields.description}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.normal),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Category:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          foodType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Price:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'Rp${widget.food.fields.minPrice} - Rp${widget.food.fields.maxPrice}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => {
                    _showBookmarkSheet(context, widget.food.pk)
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(_bookMarkColor),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66696969),
                            spreadRadius: 0,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ]),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Icon(
                        Icons.bookmark_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
