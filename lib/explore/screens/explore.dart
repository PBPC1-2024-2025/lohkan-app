import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lohkan_app/explore/models/food.dart';
import 'package:lohkan_app/explore/screens/food_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'dart:ui_web' as ui_web;
import 'dart:html';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Future<List<Food>> fetchFood(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/explore/json/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Melakukan konversi data json menjadi object Food
    List<Food> listFood = [];
    for (var d in data) {
      if (d != null) {
        listFood.add(Food.fromJson(d));
      }
    }
    return listFood;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
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
                  child: Text(
                    'Search',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: fetchFood(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  Text(
                    'Belum ada data food pada lohkan.',
                    style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                  ),
                  SizedBox(height: 8),
                ],
              );
            } else {
              return AlignedGridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // var _imageUrl = snapshot.data![index].fields.imageLink;

                  var _imageUrl =
                      'https://asset.kompas.com/crops/N8WTCiVClutwEkjIgCykYbt1e2Q=/142x72:863x553/1200x800/data/photo/2022/09/27/633297e88244b.jpg';
                  return Container(
                    height: MediaQuery.of(context).size.width / 3,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FoodPage(
                                  food: snapshot.data![index],
                                )),
                      ),
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
    );
  }
}
