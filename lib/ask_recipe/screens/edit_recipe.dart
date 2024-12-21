import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Widget untuk layar edit resep
class EditRecipeScreen extends StatefulWidget {
  final String title;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int servings;
  final String recipeId;
  final String? imageUrl;  // Menyimpan URL gambar resep (gambar lama)
  final Function(String, String, String, int, int)? onRecipeUpdated;

  const EditRecipeScreen({
    super.key,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.servings,
    required this.recipeId,
    required this.onRecipeUpdated,
    this.imageUrl,  // Gambar lama yang diterima sebagai parameter
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  // Controller untuk mengatur nilai teks di setiap input field
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  File? _image; // File gambar baru (jika diubah)
  final ImagePicker _picker = ImagePicker();

  String? _errorMessage; // Menyimpan pesan error jika ada

  @override
  void initState() {
    super.initState();
    // Mengisi field dengan data resep yang sudah ada saat pertama kali tampil
    _titleController.text = widget.title;
    _ingredientsController.text = widget.ingredients;
    _instructionsController.text = widget.instructions;
    _cookingTimeController.text = widget.cookingTime.toString();
    _servingsController.text = widget.servings.toString();
  }

  // Fungsi untuk memilih gambar dari kamera atau galeri
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      if (await File(imagePath).exists()) {
        setState(() {
          _image = File(imagePath); // Menyimpan gambar yang dipilih
        });
      } 
    } 
  }

  // Menampilkan modal untuk memilih gambar dari kamera atau galeri
  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pilihan untuk mengambil foto menggunakan kamera
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context); // Menutup modal
                  _pickImage(ImageSource.camera); // Mengambil gambar dari kamera
                },
              ),
              // Pilihan untuk memilih gambar dari galeri
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context); // Menutup modal
                  _pickImage(ImageSource.gallery); // Mengambil gambar dari galeri
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk mengupdate resep di server
  Future<void> _updateRecipe(CookieRequest request) async {
    final recipeId = widget.recipeId.toString(); // Pastikan recipeId adalah string
    final url = 'http://10.0.2.2:8000/ask_recipe/update_recipe_flutter/$recipeId/';

    // Validasi input waktu memasak dan jumlah porsi
    final cookingTime = int.tryParse(_cookingTimeController.text);
    final servings = int.tryParse(_servingsController.text);

    if (cookingTime == null || servings == null) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be valid numbers!'; // Pesan error jika bukan angka
      });
      return;
    }

    if (cookingTime <= 0 || servings <= 0) {
      setState(() {
        _errorMessage = 'Cooking time and servings must be greater than 0!'; // Pesan error jika kurang dari atau sama dengan 0
      });
      return;
    }

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Menambahkan data resep ke request
      request.fields['title'] = _titleController.text;
      request.fields['ingredients'] = _ingredientsController.text;
      request.fields['instructions'] = _instructionsController.text;
      request.fields['cooking_time'] = cookingTime.toString();
      request.fields['servings'] = servings.toString();

      // Menambahkan gambar baru jika ada
      if (_image != null) {
        var stream = http.ByteStream(_image!.openRead());
        var length = await _image!.length();
        var multipartFile = http.MultipartFile(
          'image', // Nama field yang sesuai dengan di Django
          stream,
          length,
          filename: _image!.path.split('/').last,
        );
        request.files.add(multipartFile);
      } else if (widget.imageUrl != null) {
        // Gunakan gambar lama jika tidak ada gambar baru
        request.fields['image_url'] = widget.imageUrl!; // Mengirimkan gambar lama
      }

      // Kirim request ke server
      var response = await request.send();

      // Periksa status code dari server
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;

        // Jika berhasil, panggil callback untuk update resep di halaman sebelumnya
        widget.onRecipeUpdated?.call(
          _titleController.text,
          _ingredientsController.text,
          _instructionsController.text,
          cookingTime,
          servings,
        );

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully')),
        );
        Navigator.of(context).pop(); // Kembali ke layar sebelumnya
      } else {
        // Jika status code bukan 200 atau 201, baca body respons dari server
        var responseBody = await response.stream.bytesToString();

        // Jika body respons kosong
        if (responseBody.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server returned an empty response')),
          );
          return;
        }

        // Jika gagal parse JSON, tampilkan pesan error
        try {
          var jsonResponse = json.decode(responseBody);
          String errorMessage = jsonResponse['message'] ?? 'There is an error';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update recipe: $errorMessage')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response from server: $responseBody')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating recipe: $e'; // Pesan error jika ada kesalahan dalam update
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
              // Handle untuk drag (untuk menarik modal ke atas)
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

              // Judul form
              const Text(
                'Edit Recipe',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Form input untuk data resep
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

              // Bagian untuk memilih gambar resep
              GestureDetector(
                onTap: () => _showImagePickerModal(context),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[600]!, // Warna border lebih gelap
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      _image!, // Menampilkan gambar yang dipilih
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 55,
                    ),
                  )
                      : widget.imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.network(
                              widget.imageUrl!, // Menampilkan gambar lama jika ada
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

              // Menampilkan pesan error jika ada
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 24),

              // Tombol untuk menyimpan perubahan
              ElevatedButton(
                onPressed: () {
                  // Validasi apakah semua field terisi
                  if (_titleController.text.isNotEmpty &&
                      _ingredientsController.text.isNotEmpty &&
                      _instructionsController.text.isNotEmpty &&
                      _cookingTimeController.text.isNotEmpty &&
                      _servingsController.text.isNotEmpty) {
                    final request = Provider.of<CookieRequest>(context, listen: false);
                    _updateRecipe(request); // Memanggil fungsi update resep
                  } else {
                    setState(() {
                      _errorMessage = 'All fields are required!'; // Pesan error jika ada field yang kosong
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

  // Widget untuk field input teks biasa
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

  // Widget untuk field input teks multiline
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
