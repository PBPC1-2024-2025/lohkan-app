import 'package:flutter/material.dart';
import 'package:lohkan_app/ask_recipe/screens/create_recipe.dart';

class AskRecipeScreen extends StatelessWidget {
  const AskRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Group',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding di seluruh layar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kotak input untuk mencari resep
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white, // Background putih
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2), // Posisi bayangan
                    ),
                  ], // Menambahkan bayangan
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Recipe',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), // Padding lebih rapat
                  ),
                ),
              ),
              const SizedBox(height: 16), // Jarak antara Find Recipe dan daftar resep

              // Kotak dengan ujung bulat di bawah untuk daftar resep dengan efek bayangan
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // Warna bayangan
                        blurRadius: 8, // Jarak bayangan
                        offset: Offset(0, -4), // Bayangan di atas
                      ),
                    ],
                  ),
                  child: ListView(
                    children: [
                      _buildRecipeCard(
                        title: 'Es Ai Lo Bi',
                        description: 'A traditional ice dessert from the region.',
                        imageUrl: 'https://via.placeholder.com/120x120',
                      ),
                      _buildRecipeCard(
                        title: 'Kue Pelite',
                        description: 'A sweet Bangka delicacy made from rice flour and coconut.',
                        imageUrl: 'https://via.placeholder.com/120x120',
                      ),
                      _buildRecipeCard(
                        title: 'Mie Koba',
                        description: 'A noodle dish famous in Pangkalpinang.',
                        imageUrl: 'https://via.placeholder.com/120x120',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Tombol Add di kanan bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           // Tampilkan modal CreateRecipeScreen
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const CreateRecipeScreen();  // Menampilkan modal
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 96, 7, 7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Membuat Card Resep
  Widget _buildRecipeCard({
    required String title,
    required String description,
    required String imageUrl,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12.0),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        onTap: () {},
      ),
    );
  }
}