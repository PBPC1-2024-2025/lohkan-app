import 'package:flutter/material.dart';
import 'package:lohkan_app/authentication/screens/login.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lohkan_app/article/screens/articles.dart';


class HomePage extends StatefulWidget {
  final String username;
  // const HomePage({super.key});
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Daftar halaman untuk navigasi BottomNavigationBar
  final List<Widget> _pages = [
    const Center(child: Text('Home Page')), // Halaman Home
    const Center(child: Text('Explore Page')), // Halaman Explore
    const Center(child: Text('Food Review Page')), // Halaman Food Review
    const Center(child: Text('Ask Recipe Page')), // Halaman Ask Recipe
    const ArticleScreen(), // Halaman Article
    // const BucketList(), -> ini tolong diganti sesuai dengan nama class bagian ABHI 
  ];
  

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Transform.translate(
              offset: const Offset(-5, 0),
              child: Image.asset(
                'assets/logo.png',
                height: 20,
              ),
            ),
            const Spacer(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: Colors.grey,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Color(0xFF800000),
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 0; // ini tolong diganti ke page nya ABHI ya (buat abhi)
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.grey,
            ),
            onPressed: () async {
              final request = context.read<CookieRequest>(); // Ambil instance CookieRequest
              final response = await request.logout("http://127.0.0.1:8000/auth/logout/"); // Endpoint logout

              if (context.mounted) { // Pastikan context masih tersedia
                if (response['status']) { // Logout berhasil
                  String uname = response['username'];
                  String message = response['message'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$message Sampai jumpa, $uname."),
                    ),
                  );
                  // Navigasi ke halaman login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()), // Sesuaikan dengan halaman login Anda
                  );
                  
                } else { // Logout gagal
                String message = response['message'];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                    ),
                  );
                }
              }
            },

          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomePage() : _pages[_currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: const Color(0xFF550000),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star),
                label: 'Food Review',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.question_answer),
                label: 'Ask Recipe',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article),
                label: 'Article',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    final List<Map<String, String>> sliderImages = [
      {'image': 'assets/restaurant.jpg', 'label': 'Best Food'},
      {'image': 'assets/restaurant2.jpeg', 'label': 'High Quality'},
      {'image': 'assets/restaurant3.jpeg', 'label': 'Top Taste'},
    ];
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Welcome Back, ${widget.username}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: sliderImages.length,
                itemBuilder: (context, index) {
                  final image = sliderImages[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(image['image']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            image['label']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Why Choose Us',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _IconText(icon: Icons.verified, label: 'Authentic Experience'),
                _IconText(icon: Icons.store, label: 'Support Local'),
                _IconText(icon: Icons.map, label: 'Easy Navigation'),
                _IconText(icon: Icons.update, label: 'Regular Updates'),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Best Restaurant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const _RestaurantCard(
              name: 'Urang Kampong Due',
              imagePath: 'assets/resto1.jpeg',
              location: 'Belitung',
              latitude: -2.737298839690619,
              longitude: 107.62366889321741,
            ),
            const SizedBox(height: 10),
            const _RestaurantCard(
              name: 'Martabak Bangka Liem',
              imagePath: 'assets/resto2.jpg',
              location: 'Pangkalpinang',
              latitude: -2.1334,
              longitude: 106.1126,
            ),
            const SizedBox(height: 10),
            const _RestaurantCard(
              name: 'Seafood Tepi Laut',
              imagePath: 'assets/resto3.jpg',
              location: 'Pangkalpinang',
              latitude: -2.1090,
              longitude: 106.1185,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IconText({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    List<String> words = label.split(' ');

    return Column(
      children: [
        Icon(icon, size: 40, color: Color(0xFF800000),),
        const SizedBox(height: 5),
        Column(
          children: words.map((word) {
            return Text(
              word,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final String name;
  final String location;
  final String imagePath;
  final double latitude;
  final double longitude;

  const _RestaurantCard({
    required this.name,
    required this.imagePath, 
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    void _launchGoogleMaps() async {
      final String googleMapsUrl = 'https://www.google.com/maps?q=$latitude,$longitude';
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFF800000),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Color(0xFF800000),),
                    ),
                    child: Text(
                      location,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: _launchGoogleMaps,
                      child: const Text('See Details →'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

