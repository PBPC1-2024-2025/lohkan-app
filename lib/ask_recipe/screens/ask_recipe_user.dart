import 'package:flutter/material.dart';
import 'package:lohkan_app/ask_recipe/screens/chat_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/ask_recipe/models/recipe_entry.dart';
import 'package:lohkan_app/ask_recipe/screens/view_recipe.dart';

class AskRecipeScreenUser extends StatefulWidget {
  final String username;
  final bool isAdmin; 

  const AskRecipeScreenUser({super.key, required this.username, this.isAdmin = false});

  @override
  State<AskRecipeScreenUser> createState() => _AskRecipeScreenUserState();
}

class _AskRecipeScreenUserState extends State<AskRecipeScreenUser> {
  late Future<List<AskRecipeEntry>> _recipesFuture;
  String searchQuery = ''; // Menyimpan kata kunci pencarian

  Future<List<AskRecipeEntry>> _fetchRecipes(CookieRequest request) async {
    final String apiUrl = 'http://10.0.2.2:8000/ask_recipe/json/';

    try {
      final response = await request.get(apiUrl);

      if (response is List<dynamic>) {
        List<AskRecipeEntry> listRecipes = [];
        for (var d in response) {
          if (d != null) {
            listRecipes.add(AskRecipeEntry.fromJson(d));
          }
        }
        return listRecipes;
      } else {
        throw Exception('Invalid response format: Expected a List');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e');
    }
  }

  // Fungsi untuk memperbarui kata kunci pencarian dan memfilter resep
  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _fetchRecipes(
          Provider.of<CookieRequest>(context, listen: false));
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ask Recipe',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Search Bar with proper placeholder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: _updateSearchQuery, // Menangani perubahan teks
                      decoration: InputDecoration(
                        hintText: 'Find Recipe',
                        hintStyle: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[680],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Recipe List
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

                      // Filter resep berdasarkan searchQuery
                      final filteredRecipes = snapshot.data!
                          .where((recipe) =>
                              recipe.fields.title
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                          .toList();

                      if (filteredRecipes.isEmpty) {
                        return const Center(child: Text('No recipes match your search.'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          final String recipeId = recipe.pk; // No need to parse to int
                           final String groupId = recipe.fields.group;  // Make sure this field exists in your model

                          return _buildRecipeGroup(
                            title: recipe.fields.title,
                            imageUrl: recipe.fields.imageUrl,
                            ingredients: recipe.fields.ingredients,
                            instructions: recipe.fields.instructions,
                            cookingTime: recipe.fields.cookingTime,
                            servings: recipe.fields.servings,
                            recipeId: recipeId,
                            groupId: groupId,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGroup({
    required String title,
    required String imageUrl,
    required String ingredients,
    required String instructions,
    required int cookingTime,
    required int servings,
    required String recipeId,
    required String groupId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                groupId: groupId, 
                groupName: title,
                currentUserName: widget.username,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          elevation: 2, // Shadow effect
          side: BorderSide(color: Colors.grey[300]!), // Border color
          minimumSize: const Size.fromHeight(80),
          padding: const EdgeInsets.all(12),
        ),
        child: Row(
          children: [
            // Recipe Image
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Recipe Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),

            // Book Icon (Button)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(
                      title: title,
                      imageUrl: imageUrl,
                      ingredients: ingredients,
                      instructions: instructions,
                      cookingTime: cookingTime,
                      servings: servings,
                      recipeId: recipeId,
                      isAdmin: widget.isAdmin,
                      onRecipeUpdated: _refreshRecipes,
                    ),
                  ),
                );
              },
              child: Icon(
                Icons.menu_book_rounded,
                color: Colors.grey[700],
                size: 45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}