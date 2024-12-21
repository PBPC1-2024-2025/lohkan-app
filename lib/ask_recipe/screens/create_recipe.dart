import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Widget untuk layar pembuatan resep
class CreateRecipeScreen extends StatefulWidget {
  final Function()? onRecipeAdded;

  const CreateRecipeScreen({super.key, this.onRecipeAdded});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  // Controller untuk setiap field input
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  File? _image;  // Menyimpan file gambar resep
  final ImagePicker _picker = ImagePicker();  // Untuk mengambil gambar

  String? _errorMessage;  // Menyimpan pesan error

  // Fungsi untuk memilih gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      if (await File(imagePath).exists()) {
        setState(() {
          _image = File(imagePath);  // Set gambar yang dipilih
        });
      } 
      } else {
        setState(() {
          _errorMessage = 'No image selected';  // Pesan error jika tidak ada gambar yang dipilih
      });
    }
  }

  // Fungsi untuk menampilkan modal untuk memilih sumber gambar (kamera atau galeri)
  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol untuk mengambil foto dengan kamera
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context); // Tutup modal
                  _pickImage(ImageSource.camera); // Ambil gambar dari kamera
                },
              ),
              // Tombol untuk memilih foto dari galeri
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

  // Fungsi untuk membuat resep baru dengan validasi input
  Future<void> _createRecipe() async {
      final url = 'http://10.0.2.2:8000/ask_recipe/create_recipe_flutter/';

    // Validasi jika ada field yang kosong
    if (_titleController.text.isEmpty ||
        _ingredientsController.text.isEmpty ||
        _instructionsController.text.isEmpty ||
        _cookingTimeController.text.isEmpty ||
        _servingsController.text.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';  // Pesan error jika ada field kosong
      });
      return;
    }

    // Validasi untuk angka (waktu memasak dan jumlah porsi)
    final cookingTime = int.tryParse(_cookingTimeController.text);
    final servings = int.tryParse(_servingsController.text);

    if (cookingTime == null || servings == null) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be valid numbers!';  // Pesan error jika input bukan angka
      });
      return;
    }

    if (cookingTime <= 0 || servings <= 0) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be greater than 0!';  // Pesan error jika nilai tidak valid
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
            _errorMessage = "Recipe with the name '${_titleController.text}' already exists.";  // Pesan error jika resep sudah ada
          });
          return;
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to check existing recipes. Please try again.';  // Pesan error jika gagal memeriksa resep yang sudah ada
      });
      return;
    }

    // Validasi gambar yang harus diupload
    if (_image == null) {
      setState(() {
        _errorMessage = 'Image is required!';  // Pesan error jika gambar belum dipilih
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Tambahkan data resep ke request
      request.fields['title'] = _titleController.text;
      request.fields['ingredients'] = _ingredientsController.text;
      request.fields['instructions'] = _instructionsController.text;
      request.fields['cooking_time'] = cookingTime.toString();  // Gunakan nilai waktu yang valid
      request.fields['servings'] = servings.toString();  // Gunakan nilai porsi yang valid

      // Menambahkan gambar jika ada
      if (_image != null) {
        var stream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();
        var multipartFile = http.MultipartFile(
          'image',  // Nama field yang sesuai dengan Django
          stream,
          length,
          filename: _image!.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Kirim request untuk membuat resep
      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        widget.onRecipeAdded?.call();  // Panggil callback jika resep berhasil ditambahkan

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe created successfully')),  // Tampilkan pesan sukses
        );
        Navigator.of(context).pop();  // Kembali ke layar sebelumnya
      } else {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseBody);
        String errorMessage = jsonResponse['message'] ?? 'There is an error';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating recipe: $errorMessage')),  // Tampilkan pesan error jika gagal
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error creating recipe: $e';  // Pesan error jika gagal mengirim request
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
              // Header untuk dialog
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
                    'Add Your Recipe',  // Judul dialog
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
              // Tampilkan pesan error jika ada
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

  // Widget untuk input field biasa
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

  // Widget untuk input field multiline (untuk bahan dan instruksi)
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

  // Widget untuk memilih gambar
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
                Text('Add a photo'),  // Tombol untuk menambah gambar
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Widget untuk tombol aksi (Cancel dan Save)
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
          child: Text('Cancel'),  // Tombol cancel
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _ingredientsController.text.isNotEmpty &&
                _instructionsController.text.isNotEmpty &&
                _cookingTimeController.text.isNotEmpty &&
                _servingsController.text.isNotEmpty) {
              _createRecipe();  // Panggil fungsi untuk membuat resep
            } else {
              setState(() {
                _errorMessage = 'All fields are required!';  // Pesan error jika ada field yang kosong
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text("Save"),  // Tombol save untuk menyimpan resep
        ),
      ],
    );
  }
}
