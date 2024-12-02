import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatelessWidget {
  const CreateRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        width: MediaQuery.of(context).size.width * 0.85, // Mengatur lebar dialog agar responsif
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, // Menyesuaikan lebar
                height: 100, // Mengatur tinggi bagian judul
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
            ),
            Positioned(
              left: 0,
              top: 120,
              right: 0, // Membuat elemen di bawah judul lebih fleksibel
              child: Column(
                children: [
                  _buildTextField('Recipe Title'),
                  SizedBox(height: 10),
                  _buildTextField('Ingredients'),
                  SizedBox(height: 10),
                  _buildTextField('Instructions'),
                  SizedBox(height: 10),
                  _buildTextField('Cooking Time'),
                  SizedBox(height: 10),
                  _buildTextField('Servings'),
                  SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
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

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () {
            // Tambahkan logika untuk menyimpan data resep
            Navigator.of(context).pop();
          },
          child: Text('Save'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          ),
        ),
      ],
    );
  }
}
