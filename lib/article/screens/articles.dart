import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lohkan_app/article/models/article_entry.dart';
import 'package:http/http.dart' as http; 
import 'package:lohkan_app/article/screens/article_detail.dart';

class ArticleScreenAdmin extends StatefulWidget {
  const ArticleScreenAdmin({super.key});

  @override
  State<ArticleScreenAdmin> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreenAdmin> {
  int? hoveredIndex;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Fungsi untuk mengambil data dari API
  Future<List<ArticleEntry>> fetchArticles() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/article/json/'));
    if (response.statusCode == 200) {
      return articleEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load articles');
    }
  }

    File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  // Modifikasi method _showAddArticleDialog
  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Center(
            child: Text(
              'Add Article',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Take a Photo'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose from Gallery'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                      ),
                      child: const Text(
                        'Choose Image',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _imageFile == null ? 'No File Chosen' : _imageFile!.path.split('/').last,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF800000),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _addArticle(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

void _addArticle(BuildContext context) async {
  String title = _titleController.text;
  String description = _descriptionController.text;

  // Validasi input
  if (title.isEmpty || description.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Title and description are required')),
    );
    return;
  }

  try {
    // Pilih gambar
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileBytes = await File(pickedFile.path).readAsBytes();
      final fileName = pickedFile.name;

      // Deteksi tipe file berdasarkan ekstensi
      String mimeType = '';
      if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported image format')),
        );
        return;
      }

      // Buat MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/article/create-article-flutter/'),
      );

      // Tambahkan field form
      request.fields['title'] = title;
      request.fields['description'] = description;

      // Tambahkan file gambar
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: fileName, // Tambahkan nama file
          contentType: MediaType.parse(mimeType), // Deteksi tipe file dinamis
        ),
      );

      // Kirim request
      var response = await request.send();

      // Tangani response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh data atau panggil fetchArticles jika diperlukan
        await fetchArticles(); // Pastikan metode ini ada untuk memuat ulang daftar artikel

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article added successfully')),
        );

        // Navigasi ke halaman Articles Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ArticleScreenAdmin()), // Ganti dengan widget halaman Artikel Anda
        );
      }
      else {
        // Tangani jika ada error dari server
        var responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add article: ${response.reasonPhrase}, $responseBody')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  } catch (e) {
    print('Error adding article: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


void _showEditArticleDialog(ArticleEntry article) {
  _titleController.text = article.fields.title;
  _descriptionController.text = article.fields.description;
  _imageFile = null; // Reset image file saat dialog dibuka

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            'Edit Article',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        content: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text('Update Image'),
              ),
              const SizedBox(height: 8),
                Text(
                  _imageFile == null ? 'No File Chosen' : _imageFile!.path.split('/').last,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF800000),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateArticle(article.pk);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}

  void _updateArticle(String articleId) async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isNotEmpty && description.isNotEmpty) {
      final url = Uri.parse('http://10.0.2.2:8000/article/edit-article/$articleId');
      var request = http.MultipartRequest('POST', url);

      request.fields['title'] = title;
      request.fields['description'] = description;

      // Tambahkan gambar jika dipilih
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', 
            _imageFile!.path,
            filename: _imageFile!.path.split('/').last
          )
        );
      }

      try {
        var response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 302) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article updated successfully')),
          );
          Navigator.of(context).pop(); // Tutup dialog
          setState(() {}); // Refresh tampilan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update article. Status code: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void _deleteArticle(String articleId) async {
  final url = Uri.parse('http://10.0.2.2:8000/article/delete/$articleId');

  try {
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      // 204 No Content berarti penghapusan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article deleted successfully')),
      );

      // Refresh data (panggil fungsi fetch data)
      await fetchArticles(); // Pastikan ada metode ini untuk memuat ulang daftar artikel

      setState(() {}); // Perbarui UI
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article not found')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete article. Status code: ${response.statusCode}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> slides = [
      {
        'image':
            'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/15/3d/78/17/20181028-131410-largejpg.jpg?w=1200&h=-1&s=1',
        'title': 'Hot News',
        'description':
            'Viral di Bangka Sensasi Gurih dan Pedas Lempah Kuning Autentik di Warung Soleh',
      },
      {
        'image':
            'https://4.bp.blogspot.com/-daQIWb98GZw/XCjaR_kCItI/AAAAAAAADVY/Fri3hLyCxm0xZkaf4MdVeouBStwM2UDCgCLcBGAs/s1600/Tanjung-Kelayang.jpg',
        'title': 'Top Destination',
        'description':
            'Jelajahi Keindahan Pantai di Pulau Bangka yang Memukau Hati.',
      },
      {
        'image':
            'https://asset.kompas.com/crops/fxADh7Paf6GHgE12oj3ke5Y-dN8=/0x0:1000x667/1200x800/data/photo/2021/12/21/61c161511efb8.jpg',
        'title': 'Culinary Spotlight',
        'description': 'Mencicipi Hidangan Khas Indonesia yang Kaya Rasa dan Tradisi.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Article'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(), 
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    bool isHovered = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isHovered = !isHovered;
                            });
                          },
                          child: MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                isHovered = true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                isHovered = false;
                              });
                            },
                            child: Stack(
                              children: [
                                // Gambar hero
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: DecorationImage(
                                      image: NetworkImage(slide['image']!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Overlay Hot News di kanan atas
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Hot News',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Overlay teks utama di bawah (ditampilkan hanya ketika di-hover atau di-tap)
                                if (isHovered)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        slide['description']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),


              ),
              const SizedBox(height: 16),
              FutureBuilder<List<ArticleEntry>>(
                future: fetchArticles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading articles: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No articles available.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman detail artikel atau fungsi lainnya
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailPage(
                                    articleId: article.pk,
                                    title: article.fields.title,
                                    image: article.fields.image,
                                    description: article.fields.description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 120, // Tentukan lebar maksimal di sini
                                      ),
                                      child: Image.network(
                                        article.fields.image,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.fields.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            article.fields.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Fungsi edit artikel
                                                  _showEditArticleDialog(article);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.blue,
                                                ),
                                                child: const Text('Edit'),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _deleteArticle(article.pk);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddArticleDialog,
        backgroundColor: Color(0xFF550000),
        child: const Icon(
          Icons.add,
          color: Colors.white, // Atur warna ikon menjadi putih
        ),
      ),
    );
  }
}