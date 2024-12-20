import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  File? _image;
  final ImagePicker _picker = ImagePicker();

  String? _errorMessage;

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

  Future<void> _createRecipe() async {
      final url = 'http://10.0.2.2:8000/ask_recipe/create_recipe_flutter/';

    // Validasi input fields
    if (_titleController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _instructionsController.text.isEmpty ||
        _cookingTimeController.text.isEmpty ||
        _servingsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    // Validasi angka (cooking time dan servings)
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

    // Validasi nama resep unik
    final existingRecipesUrl = 'http://10.0.2.2:8000/ask_recipe/json/';
    try {
      final response = await http.get(Uri.parse(existingRecipesUrl));
      if (response.statusCode == 200) {
        final List<dynamic> recipes = json.decode(response.body);
        final existingTitles = recipes.map((recipe) => recipe['fields']['title'].toLowerCase()).toList();

        if (existingTitles.contains(_titleController.text.toLowerCase())) {
          setState(() {
            _errorMessage = "Recipe with the name '${_titleController.text}' already exists.";
          });
          return;
        }
      }
    } catch (e) {
      print('Error checking existing recipes: $e');
      setState(() {
        _errorMessage = 'Failed to check existing recipes. Please try again.';
      });
      return;
    }

    // Validasi gambar tidak boleh kosong
    if (_image == null) {
      setState(() {
        _errorMessage = 'Image is required!';
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Tambahkan field teks
      request.fields['title'] = _titleController.text;
      request.fields['ingredients'] = _ingredientsController.text;
      request.fields['instructions'] = _instructionsController.text;
      request.fields['cooking_time'] = cookingTime.toString(); // Gunakan angka yang sudah divalidasi
      request.fields['servings'] = servings.toString(); // Gunakan angka yang sudah divalidasi

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        widget.onRecipeAdded?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully')),
        );
        Navigator.of(context).pop();
      } else {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        String errorMessage = jsonResponse['message'] ?? 'Terjadi kesalahan';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat resep: $errorMessage')),
        );
      }
    } catch (e) {
      print('Error creating recipe: $e');
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
              SizedBox(height: 10),
              _buildImagePicker(context),
              SizedBox(height: 10),
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

  Widget _buildMultilineTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        alignLabelWithHint: true,
      ),
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      children: [
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
        const SizedBox(height: 10),
      ],
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
            backgroundColor: Color(0xFF550000),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text('Cancel'),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _ingredientsController.text.isNotEmpty &&
                _instructionsController.text.isNotEmpty &&
                _cookingTimeController.text.isNotEmpty &&
                _servingsController.text.isNotEmpty) {
              _createRecipe();
            } else {
              setState(() {
                _errorMessage = 'All fields are required!';
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text("Save"),
        ),
      ],
    );
  }
}