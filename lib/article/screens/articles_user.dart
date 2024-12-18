
import 'package:flutter/material.dart';
import 'package:lohkan_app/article/models/article_entry.dart';
import 'package:http/http.dart' as http; 
import 'package:lohkan_app/article/screens/article_detail.dart';


class ArticleScreenUser extends StatefulWidget {
  const ArticleScreenUser({super.key});

  @override
  State<ArticleScreenUser> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreenUser> {
  int? hoveredIndex;

  // Fungsi untuk mengambil data dari API
  Future<List<ArticleEntry>> fetchArticles() async {
    // final response = await http.get(Uri.parse('http://127.0.0.1:8000/article/json/'));
    final response = await http.get(Uri.parse('http://marla-marlena-lohkan.pbp.cs.ui.ac.id/article/json/'));
    if (response.statusCode == 200) {
      return articleEntryFromJson(response.body);
    } else {
      throw Exception('Failed to load articles');
    }
  }


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
                    bool isHovered = false;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              isHovered = !isHovered;
                            });
                          },
                          child: MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                isHovered = true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                isHovered = false;
                              });
                            },
                            child: Stack(
                              children: [
                                // Gambar hero
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
                                // Overlay Hot News di kanan atas
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Hot News',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Overlay teks utama di bawah (ditampilkan hanya ketika di-hover atau di-tap)
                                if (isHovered)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        slide['description']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),


              ),
              const SizedBox(height: 16),
              FutureBuilder<List<ArticleEntry>>(
                future: fetchArticles(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading articles: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No articles available.'));
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final article = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman detail artikel atau fungsi lainnya
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleDetailPage(
                                    articleId: article.pk,
                                    title: article.fields.title,
                                    image: article.fields.image,
                                    description: article.fields.description,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth: 120, // Tentukan lebar maksimal di sini
                                      ),
                                      child: Image.network(
                                        article.fields.image,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.fields.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            article.fields.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
