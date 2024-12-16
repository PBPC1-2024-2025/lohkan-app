import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final String title;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int servings;
  final String recipeId;
  final Function(String, String, String, int, int)? onRecipeUpdated; 

  const EditRecipeScreen({
    super.key,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.recipeId,
    this.onRecipeUpdated,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-populate the fields with existing recipe data
    _titleController.text = widget.title;
    _ingredientsController.text = widget.ingredients;
    _instructionsController.text = widget.instructions;
    _cookingTimeController.text = widget.cookingTime.toString();
    _servingsController.text = widget.servings.toString();
  }


  Future<void> _updateRecipe(CookieRequest request) async {
    final recipeId = widget.recipeId.toString(); // Pastikan recipeId adalah string
    final url = 'http://marla-marlena-lohkan.pbp.cs.ui.ac.id/ask_recipe/update_recipe_flutter/$recipeId/';


    final cookingTime = int.tryParse(_cookingTimeController.text);
    final servings = int.tryParse(_servingsController.text);

    if (cookingTime == null || servings == null) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be valid numbers!';
      });
      return;
    }
    
    try {
      final response = await request.postJson(
        url,
        jsonEncode({
          'title': _titleController.text,
          'ingredients': _ingredientsController.text,
          'instructions': _instructionsController.text,
          'cooking_time': cookingTime,
          'servings': servings,
        }),
      );

      if (!mounted) return;

      if (response != null && response['status'] == 'success') {
        widget.onRecipeUpdated?.call(
          _titleController.text, 
          _ingredientsController.text, 
          _instructionsController.text, 
          cookingTime, 
          servings
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Recipe updated successfully')),
        );
         Navigator.of(context).pop({
          'title': _titleController.text,
          'ingredients': _ingredientsController.text,
          'instructions': _instructionsController.text,
          'cooking_time': cookingTime,
          'servings': servings,
        });
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to update recipe';
        });
      }
    } catch (e) {
      if (e.toString().contains('<!DOCTYPE')) {
        setState(() {
          _errorMessage = 'Invalid response from server. Please check the API endpoint.';
        });
      } else {
        setState(() {
          _errorMessage = 'Error updating recipe: $e';
        });
      }
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle untuk drag
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              
              // Judul
              const Text(
                'Edit Recipe',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

                // Isi form tetap sama seperti sebelumnya
                _buildTextField('Recipe Title', _titleController),
                const SizedBox(height: 16),
                _buildMultilineTextField('Ingredients', _ingredientsController),
                const SizedBox(height: 16),
                _buildMultilineTextField('Instructions', _instructionsController),
                const SizedBox(height: 16),
                _buildTextField('Cooking Time (minutes)', _cookingTimeController),
                const SizedBox(height: 16),
                _buildTextField('Servings', _servingsController),
                
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty &&
                      _ingredientsController.text.isNotEmpty &&
                      _instructionsController.text.isNotEmpty &&
                      _cookingTimeController.text.isNotEmpty &&
                      _servingsController.text.isNotEmpty) {
                    final request = Provider.of<CookieRequest>(context, listen: false);
                    _updateRecipe(request);
                  } else {
                    setState(() {
                      _errorMessage = 'All fields are required!';
                    });
                  }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildMultilineTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
        alignLabelWithHint: true,
      ),
    );
  }
}