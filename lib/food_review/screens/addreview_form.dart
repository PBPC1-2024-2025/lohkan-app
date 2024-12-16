import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ReviewEntryFormPage extends StatefulWidget {
  const ReviewEntryFormPage({Key? key}) : super(key: key);

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _foodName = '';
  String _foodType = 'Main Course'; // Default value
  int _rating = 0;
  String _comments = '';

  Future<void> submitReview() async {
    var body = jsonEncode({
      'name': _foodName,
      'food_type': _foodType,
      'rating': _rating.toString(),
      'comments': _comments,
    });

    var response = await http.post(
      Uri.parse('http://127.0.0.1:8000/add_review_ajax/'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Write a Review"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Food Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
                onChanged: (value) => _foodName = value,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _foodType,
                decoration: InputDecoration(
                  labelText: 'Select Food Type',
                  border: OutlineInputBorder(),
                ),
                items: <String>['Main Course', 'Dessert', 'Drinks', 'Snacks']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _foodType = newValue!;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Rating (1-5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 5) {
                    return 'Rating must be between 1 and 5';
                  }
                  return null;
                },
                onChanged: (value) => _rating = int.parse(value),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => _comments = value,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submitReview();
                  }
                },
                child: Text('Publish!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
