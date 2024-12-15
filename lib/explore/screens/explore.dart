import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/models/food.dart';
import 'package:lohkan_app/explore/screens/food_page.dart';
import 'package:lohkan_app/explore/screens/form_add.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ExploreScreen extends StatefulWidget {
  final String username;
  const ExploreScreen({super.key, required this.username});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  String _selectedFilter = '';
  Widget _buildFilterButton(String type) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: _selectedFilter == type
            ? const Color(0xFF550000)
            : Colors.grey.shade400,
      ),
      onPressed: () {
        setState(() {
          _selectedFilter =
              _selectedFilter == type ? '' : type; // Toggle filter
        });
      },
      child: _buildFilterButtonText(type, _selectedFilter),
    );
  }

  Widget _buildFilterButtonText(String type, String selected) {
    if (type == 'Type.MC') {
      String text = 'Main Course';
      if (selected == type) {
        return Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      } else {
        return Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        );
      }
    } else if (type == 'Type.DS') {
      String text0 = 'Dessert';
      if (selected == type) {
        return Text(
          text0,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      } else {
        return Text(
          text0,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        );
      }
    } else if (type == 'Type.DR') {
      String text1 = 'Drinks';
      if (selected == type) {
        return Text(
          text1,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      } else {
        return Text(
          text1,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        );
      }
    } else {
      String text2 = 'Snacks';
      if (selected == type) {
        return Text(
          text2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        );
      } else {
        return Text(
          text2,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 16,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    Future<List<Food>> fetchFood(CookieRequest request) async {
      final response = await request.get('http://marla-marlena-lohkan.pbp.cs.ui.ac.id/explore/json/');

      // Melakukan decode response menjadi bentuk json
      var data = response;

      // Melakukan konversi data json menjadi object Food
      List<Food> listFood = [];
      for (var d in data) {
        if (d != null) {
          var food = Food.fromJson(d);
          bool matchesSearch = _searchQuery.isEmpty ||
              food.fields.name.toLowerCase().contains(_searchQuery);
          bool matchesType = _selectedFilter.isEmpty ||
              food.fields.type.toString() == _selectedFilter;
          if (matchesSearch && matchesType) {
            listFood.add(Food.fromJson(d));
          }
        }
      }
      return listFood;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      topLeft: Radius.circular(10)),
                  color: Colors.grey.shade200,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: MediaQuery.of(context).size.height * 0.05,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    color: Colors.grey.shade200,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    width: MediaQuery.of(context).size.height * 0.6,
                    child: TextField(
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 16),
                      cursorColor: Colors.grey.shade600,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600, fontSize: 16),
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.username == 'admin'
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFoodForm(
                    username: widget.username,
                  ),
                ),
              ).then((value) {
                if (value) {
                  setState(() {});
                }
              }),
              backgroundColor: const Color(0xFF550000),
              shape: CircleBorder(),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
      body: Column(children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterButton('Type.MC'),
                const SizedBox(width: 10),
                _buildFilterButton('Type.DS'),
                const SizedBox(width: 10),
                _buildFilterButton('Type.DR'),
                const SizedBox(width: 10),
                _buildFilterButton('Type.SN'),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 13,
          child: FutureBuilder(
            future: fetchFood(request),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Text(
                        'Belum ada data makanan atau minuman pada lohkan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                } else {
                  if (snapshot.data.length == 0) {
                    return Center(
                      child: Text(
                        'Makanan atau minuman tidak ditemukan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    );
                  }
                  return AlignedGridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var _imageUrl = snapshot.data![index].fields.imageLink;
                      return Container(
                        height: MediaQuery.of(context).size.width / 3,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FoodPage(
                                      food: snapshot.data![index],
                                      username: widget.username,
                                    )),
                          ).then((value) {
                            if (value) {
                              setState(() {});
                            }
                          }),
                          child: CachedNetworkImage(
                              imageUrl: _imageUrl,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  height: MediaQuery.of(context).size.width / 3,
                                  width: MediaQuery.of(context).size.width / 3,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) => const Center(
                                    child: SizedBox(
                                      width: 80.0,
                                      height: 80.0,
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }
              }
            },
          ),
        ),
      ]),
    );
  }
}
