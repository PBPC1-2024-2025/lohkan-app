import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  final Function()? onRecipeAdded;

  const CreateRecipeScreen({super.key, this.onRecipeAdded});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  String? _errorMessage;

  Future<void> _createRecipe(CookieRequest request) async {
    final url = 'http://127.0.0.1:8000/ask_recipe/create_recipe_flutter/';

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
      print('Response from Django: $response');

      if (response != null && response['status'] == 'success') {
        widget.onRecipeAdded?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = response['error'] ?? 'Failed to create recipe';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating recipe: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF550000),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Add Your Recipe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildTextField('Recipe Title', _titleController),
              SizedBox(height: 10),
              _buildMultilineTextField('Ingredients', _ingredientsController),
              SizedBox(height: 10),
              _buildMultilineTextField('Instructions', _instructionsController),
              SizedBox(height: 10),
              _buildTextField('Cooking Time', _cookingTimeController),
              SizedBox(height: 10),
              _buildTextField('Servings', _servingsController),
              SizedBox(height: 20),
              if (_errorMessage != null) 
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      style: TextStyle(fontSize: 18),
    );
  }

  // New method for multiline text fields
  Widget _buildMultilineTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null, // Allows unlimited lines
      minLines: 3, // Minimum height of 3 lines
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        alignLabelWithHint: true, // Aligns the label with the input text
      ),
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF550000), // Dark red background for cancel
            foregroundColor: Colors.white, // White text
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('Cancel'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            final request = Provider.of<CookieRequest>(context, listen: false);
            if (_titleController.text.isNotEmpty &&
                _ingredientsController.text.isNotEmpty &&
                _instructionsController.text.isNotEmpty &&
                _cookingTimeController.text.isNotEmpty &&
                _servingsController.text.isNotEmpty) {
              _createRecipe(request);
            } else {
              setState(() {
                _errorMessage = 'All fields are required!';
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Black background for save
            foregroundColor: Colors.white, // White text
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text("Save"),
        ),
      ],
    );
  }
}