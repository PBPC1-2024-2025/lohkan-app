import 'package:flutter/material.dart';
import 'package:lohkan_app/ask_recipe/screens/edit_recipe.dart';

// Widget untuk layar detail resep
class RecipeDetailScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int servings;
  final String recipeId; 
  final bool isAdmin; // Menambahkan parameter untuk menentukan apakah pengguna adalah admin
  final Function? onRecipeUpdated;

  const RecipeDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.recipeId, 
    required this.isAdmin, // Menambahkan parameter isAdmin
    this.onRecipeUpdated,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isEditMode = false;  // Menyimpan status mode edit, apakah sedang mengedit resep
  late String _title;
  late String _ingredients;
  late String _instructions;
  late int _cookingTime;
  late int _servings;

  @override
  void initState() {
    super.initState();
    // Menyimpan nilai-nilai awal dari widget properties
    _title = widget.title;
    _ingredients = widget.ingredients;
    _instructions = widget.instructions;
    _cookingTime = widget.cookingTime;
    _servings = widget.servings;
  }

  // Fungsi untuk toggle mode edit (ubah status edit mode)
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;  // Ubah status _isEditMode
    });
  }

  // Fungsi ini akan dipanggil setelah resep diupdate
  void _refreshRecipe(String newTitle, String newIngredients, String newInstructions, int newCookingTime, int newServings) {
    setState(() {
      // Update nilai resep dengan yang baru
      _title = newTitle;
      _ingredients = newIngredients;
      _instructions = newInstructions;
      _cookingTime = newCookingTime;
      _servings = newServings;
    });

    // Panggil callback untuk memberi tahu halaman utama bahwa resep telah diperbarui
    widget.onRecipeUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ),
        titleSpacing: 0,
        title: const Text(
          'Back To Chat',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (widget.isAdmin) // Menampilkan tombol Edit hanya jika pengguna adalah admin
            Padding(
              padding: const EdgeInsets.only(right: 16.0), 
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: _toggleEditMode,  // Jika di klik, toggle mode edit
              ),
            ),
        ],
        backgroundColor: const Color(0xFF800000), // Warna latar belakang app bar
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar resep yang ditampilkan
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,  // Memastikan gambar menyesuaikan dengan ukuran
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Widget untuk menampilkan detail resep
                  RecipeDetailsWidget(
                    title: _title,  // Menggunakan nilai state lokal
                    cookingTime: _cookingTime,
                    servings: _servings,
                    ingredients: _ingredients,
                    instructions: _instructions,
                  ),
                ],
              ),
            ),
          ),
          // Jika dalam mode edit dan pengguna adalah admin, tampilkan EditRecipeScreen
          if (_isEditMode && widget.isAdmin) 
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: EditRecipeScreen(
                  recipeId: widget.recipeId,
                  title: _title,
                  ingredients: _ingredients,
                  instructions: _instructions,
                  cookingTime: _cookingTime,
                  servings: _servings,
                  onRecipeUpdated: _refreshRecipe,  // Callback untuk update UI
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget untuk menampilkan detail resep seperti bahan dan instruksi
class RecipeDetailsWidget extends StatelessWidget {
  final String title;
  final int cookingTime;
  final int servings;
  final String ingredients;
  final String instructions;

  const RecipeDetailsWidget({
    super.key,
    required this.title,
    required this.cookingTime,
    required this.servings,
    required this.ingredients,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    // Pisahkan ingredients berdasarkan titik (.)
    List<String> ingredientList = ingredients
        .split('.')
        .map((ingredient) => ingredient.trim())
        .where((ingredient) => ingredient.isNotEmpty)
        .toList();

    // Pisahkan instructions berdasarkan titik (.)
    List<String> instructionList = instructions
        .split('.')
        .map((instruction) => instruction.trim())
        .where((instruction) => instruction.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul resep dan nama pembuat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('Created by Admin'),
            ],
          ),
          const SizedBox(height: 8),
          // Menampilkan informasi waktu memasak dan jumlah porsi
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 4),
              Text('$cookingTime minutes'),
              const SizedBox(width: 16),
              const Icon(Icons.people, size: 18),
              const SizedBox(width: 4),
              Text('$servings servings'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ingredients :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Menampilkan bahan-bahan dengan tanda '-'
          ...ingredientList.map((ingredient) {
            return Text(
              '- $ingredient',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            );
          }),

          const SizedBox(height: 16),
          const Text(
            'Instructions :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Menampilkan instruksi dengan angka 1., 2., 3.
          ...instructionList.asMap().entries.map((entry) {
            int index = entry.key;
            String instruction = entry.value;
            return Text(
              '${index + 1}. $instruction',  // Menambahkan nomor instruksi
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

