import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/screens/form_edit.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'explore.dart';

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
          title: Container(
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
                  onTap: () => {},
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(_bookMarkColor),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: const Color(0x66696969),
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
