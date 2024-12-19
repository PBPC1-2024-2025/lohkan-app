import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class EditRecipeScreen extends StatefulWidget {
  final String title;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int servings;
  final String recipeId;
  final String? imageUrl; // URL gambar yang sudah ada
  final Function(String, String, String, int, int)? onRecipeUpdated;

  const EditRecipeScreen({
    super.key,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.recipeId,
    this.imageUrl,
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

  File? _image; // File gambar baru
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      if (await File(imagePath).exists()) {
        setState(() {
          _image = File(imagePath);
        });
      } else {
        print('File not found: $imagePath');
      }
    } else {
      print('No image selected.');
    }
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context); // Tutup modal
                  _pickImage(ImageSource.camera); // Ambil gambar dari kamera
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Tutup modal
                  _pickImage(ImageSource.gallery); // Ambil gambar dari galeri
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateRecipe(CookieRequest request) async {
    final recipeId = widget.recipeId.toString(); // Pastikan recipeId adalah string
    final url = 'http://10.0.2.2:8000/ask_recipe/update_recipe_flutter/$recipeId/';

    final cookingTime = int.tryParse(_cookingTimeController.text);
    final servings = int.tryParse(_servingsController.text);

    if (cookingTime == null || servings == null) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be valid numbers!';
      });
      return;
    }

    if (cookingTime <= 0 || servings <= 0) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be greater than 0!';
      });
      return;
    }
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Tambahkan field teks
      request.fields['title'] = _titleController.text;
      request.fields['ingredients'] = _ingredientsController.text;
      request.fields['instructions'] = _instructionsController.text;
      request.fields['cooking_time'] = cookingTime.toString();
      request.fields['servings'] = servings.toString();

      // Tambahkan gambar jika ada
      if (_image != null) {
        var stream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();
        var multipartFile = http.MultipartFile(
          'image', // Nama field yang sama dengan di Django
          stream,
          length,
          filename: _image!.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Kirim request
      var response = await request.send();

      // Periksa status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        widget.onRecipeUpdated?.call(
          _titleController.text,
          _ingredientsController.text,
          _instructionsController.text,
          cookingTime,
          servings,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully')),
        );
        Navigator.of(context).pop();
      } else {
        // Baca respons dari server
        var responseBody = await response.stream.bytesToString();
        print('Response status: ${response.statusCode}');
        print('Response body: $responseBody');

        // Tangani respons yang tidak valid
        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server returned an empty response')),
          );
          return;
        }

        // Coba parse respons sebagai JSON
        try {
          var jsonResponse = json.decode(responseBody);
          String errorMessage = jsonResponse['message'] ?? 'Terjadi kesalahan';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui resep: $errorMessage')),
          );
        } catch (e) {
          // Jika parsing JSON gagal, tampilkan pesan kesalahan
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response from server: $responseBody')),
          );
        }
      }
    } catch (e) {
      print('Error updating recipe: $e');
      setState(() {
        _errorMessage = 'Error updating recipe: $e';
      });
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

              // Isi form
              _buildTextField('Recipe Title', _titleController),
              const SizedBox(height: 16),
              _buildMultilineTextField('Ingredients', _ingredientsController),
              const SizedBox(height: 16),
              _buildMultilineTextField('Instructions', _instructionsController),
              const SizedBox(height: 16),
              _buildTextField('Cooking Time (minutes)', _cookingTimeController),
              const SizedBox(height: 16),
              _buildTextField('Servings', _servingsController),

              const SizedBox(height: 16),

              // Gambar resep
              GestureDetector(
                onTap: () => _showImagePickerModal(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[600]!, // Warna border yang lebih gelap
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      _image!, // Pastikan _image tidak null
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 55,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo),
                      SizedBox(width: 10),
                      Text('Add a photo'),
                    ],
                  ),
                ),
              ),

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
                      _servingsController.text.isNotEmpty && _image != null) {
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