import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lohkan_app/ask_recipe/screens/chat_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/ask_recipe/screens/create_recipe.dart';
import 'package:lohkan_app/ask_recipe/models/recipe_entry.dart'; // Import file model
import 'package:lohkan_app/ask_recipe/screens/view_recipe.dart';

// Widget untuk layar utama admin
class AskRecipeScreenAdmin extends StatefulWidget {
  final String username;
  final bool isAdmin;
  
  // Konstruktor untuk menerima username dan status admin
  const AskRecipeScreenAdmin({super.key, required this.username, this.isAdmin = true});

  @override
  State<AskRecipeScreenAdmin> createState() => _AskRecipeScreenAdminState();
}

class _AskRecipeScreenAdminState extends State<AskRecipeScreenAdmin> {
  late Future<List<AskRecipeEntry>> _recipesFuture;
  String searchQuery = ''; // Menyimpan kata kunci pencarian

  // Fungsi untuk mengambil daftar resep dari API
  Future<List<AskRecipeEntry>> _fetchRecipes(CookieRequest request) async {
    final String apiUrl = 'http://10.0.2.2:8000/ask_recipe/json/';

    try {
      final response = await request.get(apiUrl);

      if (response is List<dynamic>) {
        List<AskRecipeEntry> listRecipes = [];
        for (var d in response) {
          if (d != null) {
            listRecipes.add(AskRecipeEntry.fromJson(d)); // Menambah resep ke dalam list
          }
        }
        return listRecipes;
      } else {
        throw Exception('Invalid response format: Expected a List');
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e'); // Menangani error saat fetch data
    }
  }

  // Fungsi untuk memperbarui kata kunci pencarian
  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Fungsi untuk merefresh daftar resep setelah menambah atau menghapus resep
  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _fetchRecipes(
          Provider.of<CookieRequest>(context, listen: false));
    });
  }

  // Fungsi untuk inisialisasi state dan mengambil resep ketika halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _recipesFuture = _fetchRecipes(request); // Memanggil fungsi fetch untuk mendapatkan resep
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
                // Header dengan judul dan tombol untuk menambah resep baru
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
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CreateRecipeScreen(onRecipeAdded: _refreshRecipes); // Dialog untuk menambah resep
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800000),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar untuk mencari resep
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: _updateSearchQuery, // Memperbarui kata kunci pencarian
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

                // Daftar resep yang telah difilter berdasarkan pencarian
                Expanded(
                  child: FutureBuilder<List<AskRecipeEntry>>(
                    future: _recipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator()); // Menampilkan loading saat menunggu data
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}')); // Menampilkan error jika terjadi kesalahan
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No recipes available.')); // Menampilkan pesan jika tidak ada resep
                      }

                      // Memfilter resep berdasarkan kata kunci pencarian
                      final filteredRecipes = snapshot.data!
                          .where((recipe) =>
                              recipe.fields.title
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()))
                          .toList();

                      if (filteredRecipes.isEmpty) {
                        return const Center(child: Text('No recipes match your search.')); // Pesan jika tidak ada resep yang sesuai pencarian
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          final String recipeId = recipe.pk; // ID resep
                          final String groupId = recipe.fields.group;  // ID grup resep

                          return _buildRecipeGroup(
                            title: recipe.fields.title,
                            imageUrl: recipe.fields.imageUrl,
                            ingredients: recipe.fields.ingredients,
                            instructions: recipe.fields.instructions,
                            cookingTime: recipe.fields.cookingTime,
                            servings: recipe.fields.servings,
                            recipeId: recipeId, // ID resep
                            groupId: groupId, // ID grup
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

  // Widget untuk membangun tampilan grup resep
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
    return Dismissible(
      key: Key(recipeId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Recipe'),
              content: Text('Are you sure you want to delete "$title"?'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        _deleteRecipe(recipeId); // Menghapus resep jika di swipe
      },
      child: Container(
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
              borderRadius: BorderRadius.circular(12), // Menambahkan border radius
            ),
            elevation: 2, // Menambahkan efek bayangan
            side: BorderSide(color: Colors.grey[300]!), // Warna border
            minimumSize: const Size.fromHeight(80),
            padding: const EdgeInsets.all(12),
          ),
          child: Row(
            children: [
              // Menampilkan gambar resep
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

              // Menampilkan judul resep
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

              // Tombol menu untuk melihat detail resep
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
      ),
    );
  }

  // Fungsi untuk menghapus resep berdasarkan ID
  Future<void> _deleteRecipe(String recipeId) async {
    final url = Uri.parse('http://10.0.2.2:8000/ask_recipe/delete_recipe/$recipeId/');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Memeriksa apakah respons valid
        final jsonResponse = json.decode(response.body);

        // Merefresh daftar resep setelah penghapusan
        _refreshRecipes();

        // Menampilkan snackbar untuk konfirmasi penghapusan
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(jsonResponse['message'])),
          );
        }
      } else {
        // Menangani error jika penghapusan gagal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete recipe')),
          );
        }
      }
    } catch (e) {
      // Menangani exception lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete recipe: $e')),
        );
      }
    }
  }
}
