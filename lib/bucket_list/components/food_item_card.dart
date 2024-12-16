import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final String imagePath;
  final String foodType;

  const FoodItemCard({
    required this.title,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.foodType,
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
    required String title,
    required String description,
    required String price,
    required String imagePath,
    required String foodType,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows custom modal height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75, // 75% of the screen height
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

                // Food image with square aspect ratio and zoom (BoxFit.cover)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200, // Adjust height
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.cover, // Ensure the image fills the container
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child; // Display image once loaded
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
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
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
