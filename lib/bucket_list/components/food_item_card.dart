import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';


class FoodItemCard extends StatelessWidget {
  final String foodId;
  final String bucketId;
  final String title;
  final String description;
  final String price;
  final String imagePath;
  final String foodType;
  final VoidCallback onRemove;

  const FoodItemCard({
    required this.foodId,
    required this.bucketId,
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.foodType,
    required this.onRemove,
    super.key,
  });

  String specifyFoodType(String foodType) {
    if (foodType == 'Type.MC') {
      return 'Main Course';
    } else if (foodType == 'Type.SN') {
      return 'Snacks';
    } else if (foodType == 'Type.DS') {
      return 'Desserts';
    } else if (foodType == 'Type.DR') {
      return 'Drinks';
    }
    return 'Unspecified';
  }

  void showFoodDetailsSheet(BuildContext context, {
    required String foodId,
    required String bucketId,
    required String title,
    required String description,
    required String price,
    required String imagePath,
    required String foodType,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top line indicator
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCCC7BA),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Food image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.network(
                              imagePath,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 100, color: Colors.grey);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp$price',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Food Type
                        Text(
                          specifyFoodType(foodType),
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Detailed Description
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed bottom button
              Container(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () async {
                      final request = context.read<CookieRequest>();
                      try {
                        final response = await request.post(
                          'http://127.0.0.1:8000/bucket-list/remove-food/$foodId/$bucketId/',
                          {}
                        );
                        
                        if (response['success'] == true) {  // adjust based on your API response
                          Navigator.pop(context); // Close the bottom sheet
                          onRemove();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Food item removed successfully'),
                            ),
                          );
                          
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to remove food item'),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF550000),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Tried',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showFoodDetailsSheet(
          context,
          foodId: foodId,
          bucketId: bucketId,
          title: title,
          description: description,
          price: price,
          imagePath: imagePath,
          foodType: foodType, // Add the food type
        );
      },
      child: Container(
        // Margin everywhere except bottom
        margin: const EdgeInsets.only(
          left: 12.0,
          top: 12.0,
          right: 12.0,
        ),
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFCCC7BA), // Color of the bottom border
              width: 2.0, // Thickness of the bottom border
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Rp$price',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Space between text and image

            // Food image
            ClipRRect(
              borderRadius: BorderRadius.circular(8), // Optional: Rounded corners
              child: SizedBox(
                width: 100, // Specify the width
                height: 100, // Specify the height
                child: AspectRatio(
                  aspectRatio: 1, // Ensures a 1:1 aspect ratio
                  child: Image.network(
                    imagePath, // Path to the image (URL)
                    fit: BoxFit.cover, // Ensure the image fills the container
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
