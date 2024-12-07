import 'package:flutter/material.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http; 
import 'package:lohkan_app/article/models/article_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ArticleDetailPage extends StatefulWidget {
  final String articleId; // ID artikel untuk mengambil data dari database
  final String title;
  final String image;
  final String description;

  const ArticleDetailPage({
    Key? key,
    required this.articleId,
    required this.title,
    required this.image,
    required this.description,
  }) : super(key: key);

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPage();
}

class _ArticleDetailPage extends State<ArticleDetailPage> {
  final TextEditingController commentController = TextEditingController();
  List<dynamic> comments = []; // Menyimpan komentar dari database

  @override
  void initState() {
    super.initState();
    _fetchComments(); // Mengambil komentar saat halaman dimuat
  }

  // Fungsi untuk mengambil komentar dari database JSON
Future<void> _fetchComments() async {
  final request = Provider.of<CookieRequest>(context, listen: false);

  try {
    final response = await request.get('http://127.0.0.1:8000/article/json/');

    if (response != null) {
      List<dynamic> jsonResponse = response;
      
      // Find the specific article that matches the ID
      var articleData = jsonResponse.firstWhere(
        (article) => article['pk'] == widget.articleId,
        orElse: () => null,
      );

      if (articleData != null) {
        setState(() {
          // Extract comments from the article's fields
          comments = (articleData['fields']['comments'] as List).map((commentData) => {
            'id': commentData['id'],
            'user': commentData['user'] ?? 'Anonymous',
            'content': commentData['content'],
            'created_at': commentData['created_at']
          }).toList();
        });
      }
    } else {
      print('Failed to load article');
    }
  } catch (e) {
    print('Error fetching article: $e');
  }
}

// Fungsi untuk menambah komentar baru ke database
Future<void> _addComment(String content) async {
  final request = Provider.of<CookieRequest>(context, listen: false);

  try {
    final response = await request.post(
  'http://127.0.0.1:8000/article/json/', 
  {
    'article_id': widget.articleId,  // ID artikel yang ingin Anda tambahkan komentar
    'content': content,        // Konten komentar yang akan ditambahkan
  },
);


    if (response['status'] == 'success') {
      // Komentar berhasil ditambahkan
      _fetchComments(); // Refresh daftar komentar
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Komentar berhasil ditambahkan')),
      );
    } else {
      // Gagal menambahkan komentar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Gagal menambahkan komentar')),
      );
    }
  } catch (e) {
    print('Error adding comment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terjadi kesalahan: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Artikel'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar artikel
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
              const SizedBox(height: 16),
              // Judul artikel
              Text(
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              // Deskripsi artikel
              Text(
                widget.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Form komentar
              const Text(
                'Leave a comment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'Type your comment here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () async {
                    final newComment = commentController.text.trim();
                    if (newComment.isNotEmpty) {
                      await _addComment(newComment); // Tambahkan komentar ke database
                      commentController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF800000),
                  ),
                  child: const Text('Add Comment'),
                ),
              ),
              const SizedBox(height: 24),
              // Daftar komentar
              const Text(
                'Comments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              if (comments.isEmpty)
                const Text(
                  'No comments yet.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey.shade300,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment['user'] ?? 'Anonymous', // Nama pengguna
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  comment['content'], // Isi komentar
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Posted on ${comment['created_at']}', // Waktu komentar
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
