import 'package:flutter/material.dart';
import 'package:lohkan_app/article/models/article_entry.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  int? hoveredIndex;

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
                  itemCount: slides.length,
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggle visibility on tap
                          hoveredIndex = hoveredIndex == index ? null : index;
                        });
                      },
                      child: MouseRegion(
                        onEnter: (_) {
                          setState(() {
                            hoveredIndex = index;
                          });
                        },
                        onExit: (_) {
                          setState(() {
                            hoveredIndex = null;
                          });
                        },
                        child: Stack(
                          children: [
                            // Background Image
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
                            // Title in the top right corner
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  slide['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Description at the bottom
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity: hoveredIndex == index ? 1 : 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    slide['description']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Keep other components unchanged
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: Image.network(
                              'https://source.unsplash.com/featured/?island',
                              width: 120,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    index == 0
                                        ? 'Wisata Kuliner Khas Bangka Belitung'
                                        : 'Pulau Lengkuas Pulau Yang Indah',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Nikmati cita rasa autentik kuliner Bangka Belitung, seperti mie Belitung, otak-otak, dan ...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
    );
  }
}
