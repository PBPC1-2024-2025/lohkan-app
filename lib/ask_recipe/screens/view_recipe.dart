import 'package:flutter/material.dart';
import 'package:lohkan_app/ask_recipe/screens/edit_recipe.dart';

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
  bool _isEditMode = false;
  late String _title;
  late String _ingredients;
  late String _instructions;
  late int _cookingTime;
  late int _servings;

  @override
  void initState() {
    super.initState();
    // Set initial values from widget properties
    _title = widget.title;
    _ingredients = widget.ingredients;
    _instructions = widget.instructions;
    _cookingTime = widget.cookingTime;
    _servings = widget.servings;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  // This function will be called after the recipe is updated
  void _refreshRecipe(String newTitle, String newIngredients, String newInstructions, int newCookingTime, int newServings) {
    setState(() {
      _title = newTitle;
      _ingredients = newIngredients;
      _instructions = newInstructions;
      _cookingTime = newCookingTime;
      _servings = newServings;
    });

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
            Navigator.of(context).pop();
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
                onPressed: _toggleEditMode,
              ),
            ),
        ],
        backgroundColor: const Color(0xFF800000),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RecipeDetailsWidget(
                    title: _title,  // Use the local state here
                    cookingTime: _cookingTime,
                    servings: _servings,
                    ingredients: _ingredients,
                    instructions: _instructions,
                  ),
                ],
              ),
            ),
          ),
          if (_isEditMode && widget.isAdmin) // Menampilkan EditRecipeScreen hanya jika pengguna adalah admin
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
                  onRecipeUpdated: _refreshRecipe,  // Callback to update UI
                ),
              ),
            ),
        ],
      ),
    );
  }
}

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(ingredients),
          const SizedBox(height: 16),
          const Text(
            'Instructions :',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(instructions),
        ],
      ),
    );
  }
}