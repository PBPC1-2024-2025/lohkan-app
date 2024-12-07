import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/ask_recipe/screens/create_recipe.dart';
import 'package:lohkan_app/ask_recipe/models/recipe_entry.dart';

class AskRecipeScreen extends StatefulWidget {
  const AskRecipeScreen({super.key});

  @override
  _AskRecipeScreenState createState() => _AskRecipeScreenState();
}

class _AskRecipeScreenState extends State<AskRecipeScreen> {
  late Future<List<AskRecipeEntry>> _recipesFuture;

  // Fungsi untuk fetch data resep dari API
  Future<List<AskRecipeEntry>> _fetchRecipes(CookieRequest request) async {
    final String apiUrl = 'http://127.0.0.1:8000/ask_recipe/json/'; 

    try {
      final response = await request.get(apiUrl);
      
      if (response is List) {
        return List<AskRecipeEntry>.from(
          response.map((x) => AskRecipeEntry.fromJson(x))
        );
      } else {
        throw Exception('Invalid data format');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }

  // Method untuk me-refresh daftar resep
  void _refreshRecipes() {
    setState(() {
      // Memperbarui future dengan fetch ulang data resep
      _recipesFuture = _fetchRecipes(
        Provider.of<CookieRequest>(context, listen: false)
      );
    });
  }

  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _recipesFuture = _fetchRecipes(request);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Group', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak input untuk mencari resep (tetap sama)
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Recipe',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Menggunakan FutureBuilder dengan _recipesFuture yang bisa direfresh
              Expanded(
                child: FutureBuilder<List<AskRecipeEntry>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No recipes available.'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final recipe = snapshot.data![index];
                        return _buildRecipeGroup(
                          title: recipe.fields.title,
                          description: recipe.fields.ingredients,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateRecipeScreen(
                onRecipeAdded: _refreshRecipes,
              );
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 96, 7, 7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget untuk membuat group resep (tetap sama)
  Widget _buildRecipeGroup({
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        onTap: () {},
      ),
    );
  }
}