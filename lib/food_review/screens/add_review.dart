import 'package:flutter/material.dart';

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
