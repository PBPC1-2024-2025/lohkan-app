import 'package:flutter/material.dart';
import 'package:lohkan_app/bucket_list/components/food_item_card.dart';

class BucketListScreen extends StatefulWidget {
  const BucketListScreen({super.key});

  @override
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  // Function to show popup
  void _showCreateCollectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
            children: [
              // top line
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCC7BA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // title
                  const Text(
                    'Create new collection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Popup
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 13
                  ), // Hint text color
                  filled: true, // Enables the background color
                  fillColor: Color(0xFFF9F9F9), // Grayish background color
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000), width: 2), // Thicker red border when focused
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the create action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection created!')),
                  );
                  Navigator.of(context).pop(); // Close the sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF550000), // Red background
                  foregroundColor: Colors.white, // White text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Create collection',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCollectionSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
            children: [
              // Top line
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCC7BA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              // Edit collection (clickable)
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // print('Edit collection clicked');
                  Navigator.of(context).pop(); // Close the bottom sheet
                  _showEditCollectionSheet(context);
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 16),
                      Text(
                        'Edit collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Remove collection (clickable)
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                  showRemoveCollectionDialog(context);
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Icon(Icons.delete_outlined),
                      SizedBox(width: 16),
                      Text(
                        'Remove collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditCollectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Adjust height based on content
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch widgets horizontally
            children: [
              // top line
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCC7BA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // title
                  const Text(
                    'Edit collection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Popup
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 13
                  ), // Hint text color
                  filled: true, // Enables the background color
                  fillColor: Color(0xFFF9F9F9), // Grayish background color
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000)),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF550000), width: 2), // Thicker red border when focused
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle the create action here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Collection edited!')),
                  );
                  Navigator.of(context).pop(); // Close the sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF550000), // Red background
                  foregroundColor: Colors.white, // White text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
                child: const Text(
                  'Save changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showRemoveCollectionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allow tapping outside to close the modal
      builder: (BuildContext context) {
        return Dialog(
          // insetPadding: const EdgeInsets.symmetric(horizontal: 16), // Full width with padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Remove collection hehe?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Notice
                const Text(
                  'Your changes cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    // Remove Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF550000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0), // Adjust the value for less circular
                        ),
                      ),
                      child: const Text(
                        'Remove',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  // main components
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bucket List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Want to save food for another time?\nHere is the place!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Show the bottom sheet when this button is pressed
                _showCreateCollectionSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF550000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(240, 40),
              ),
              child: const Text(
                'Create collection',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 11, color: Colors.black),
                      children: [
                        TextSpan(
                          text: '2',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' items',
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 16,
                    ),
                    onPressed: () {
                      _showCollectionSettingsSheet(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // add new list button
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add new list clicked!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: Color(0xFFCCC7BA), // Border color
                          width: 2, // Border thickness
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: const Text(
                      '+ Add new list',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFCCC7BA),
                      ),
                    ),
                  ),
                  // list button
                  const SizedBox(width: 8), // Gap between items
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bucket list 1 clicked!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF550000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                    child: const Text(
                      'Bucket list 1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const FoodItemCard(title: 'Lempah Kuning', description: 'Ikan kuning-kuning', price: '40000 - 60000', imagePath: 'assets/resto1.jpeg'),
            const FoodItemCard(title: 'Lempah Kuning', description: 'Ikan kuning-kuning', price: '40000 - 60000', imagePath: 'assets/resto1.jpeg'),
          ],
        ),
      ),
    );
  }
}
