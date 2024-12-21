import 'package:flutter/material.dart';
import 'package:lohkan_app/ask_recipe/screens/chat_screen.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lohkan_app/ask_recipe/models/recipe_entry.dart';
import 'package:lohkan_app/ask_recipe/screens/view_recipe.dart';

// Widget untuk layar utama user
class AskRecipeScreenUser extends StatefulWidget {
  final String username;
  final bool isAdmin; // Status apakah pengguna adalah admin atau bukan

  // Konstruktor untuk menerima username dan status user
  const AskRecipeScreenUser({super.key, required this.username, this.isAdmin = false});

  @override
  State<AskRecipeScreenUser> createState() => _AskRecipeScreenUserState();
}

class _AskRecipeScreenUserState extends State<AskRecipeScreenUser> {
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
        throw Exception('Invalid response format: Expected a List'); // Jika format response tidak sesuai
      }
    } catch (e) {
      throw Exception('Error fetching recipes: $e'); // Menangani error saat fetch data
    }
  }

  // Fungsi untuk memperbarui kata kunci pencarian dan memfilter resep
  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query; // Mengubah nilai searchQuery
    });
  }

  // Fungsi untuk merefresh daftar resep
  void _refreshRecipes() {
    setState(() {
      _recipesFuture = _fetchRecipes(
          Provider.of<CookieRequest>(context, listen: false)); // Mengambil ulang daftar resep
    });
  }

  // Fungsi untuk inisialisasi state dan mengambil resep saat pertama kali halaman dibuka
  @override
  void initState() {
    super.initState();
    final request = Provider.of<CookieRequest>(context, listen: false);
    _recipesFuture = _fetchRecipes(request); // Memanggil fungsi untuk mendapatkan resep
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
                // Bagian header dengan judul
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
                
                // Search bar untuk mencari resep
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: _updateSearchQuery, // Memperbarui query pencarian
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
                
                // Daftar resep
                Expanded(
                  child: FutureBuilder<List<AskRecipeEntry>>(
                    future: _recipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator()); // Menampilkan indikator loading
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}')); // Menampilkan pesan error
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
                        return const Center(child: Text('No recipes match your search.')); // Menampilkan pesan jika tidak ada resep yang cocok
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

  // Widget untuk membangun tampilan resep
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
                groupId: groupId, // Mengirim ID grup
                groupName: title, // Mengirim nama resep
                currentUserName: widget.username, // Mengirim nama pengguna
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Sudut tombol yang melengkung
          ),
          elevation: 2, // Efek bayangan pada tombol
          side: BorderSide(color: Colors.grey[300]!), // Warna border tombol
          minimumSize: const Size.fromHeight(80), // Ukuran minimum tombol
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
                fit: BoxFit.cover, // Memastikan gambar tidak terdistorsi
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

            // Ikon menu untuk melihat detail resep
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
                      isAdmin: widget.isAdmin, // Status admin
                      onRecipeUpdated: _refreshRecipes, // Fungsi untuk memperbarui daftar resep
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
