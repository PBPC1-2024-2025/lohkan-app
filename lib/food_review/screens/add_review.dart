import 'package:flutter/material.dart';
import 'package:lohkan_app/food_review/models/foodreview_entry.dart';
import 'package:http/http.dart' as http;

void showAddReviewModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return Container(
        padding: EdgeInsets.all(20),
        child: Wrap(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Food Name',
              ),
            ),
            DropdownButton<String>(
              items: <String>['Main Course', 'Dessert', 'Drinks', 'Snacks'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
            ),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              label: 'Rating',
              value: 3,
              onChanged: (double value) {},
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Comments...',
              ),
            ),
            ElevatedButton(
              child: Text('Publish!'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    },
  );
}
