import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import 'menu_detail_screen.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final PageController _carouselController = PageController();

  late Future<List<Restaurant>> _restaurantsFuture;
  late Future<List<Menu>> _menusFuture;

  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  void _loadHomeData() {
    _restaurantsFuture = _apiService.getRestaurants();
    _menusFuture = _apiService.getMenus();
  }

  Future<void> _refreshHomeData() async {
    _currentCarouselIndex = 0;
    if (_carouselController.hasClients) {
      _carouselController.jumpToPage(0);
    }
    setState(() {
      _loadHomeData();
    });
    await Future.wait([_restaurantsFuture, _menusFuture]);
  }

  List<Restaurant> _getTopRatedRestaurants(List<Restaurant> restaurants) {
    final sorted = List<Restaurant>.from(restaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(3).toList();
  }

  Widget _buildTopRatedCarousel(List<Restaurant> restaurants) {
    final topRestaurants = _getTopRatedRestaurants(restaurants);
    if (topRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_currentCarouselIndex >= topRestaurants.length) {
      _currentCarouselIndex = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating Tertinggi di Tembalang',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _carouselController,
            physics: const PageScrollPhysics(),
            itemCount: topRestaurants.length,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final restaurant = topRestaurants[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RestaurantDetailScreen(restaurant: restaurant),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        restaurant.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.deepOrange.shade100,
                          child: const Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 48,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⭐ ${restaurant.rating.toStringAsFixed(1)} • ${restaurant.category}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              restaurant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              restaurant.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(topRestaurants.length, (index) {
            final isActive = index == _currentCarouselIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? Colors.deepOrange : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kulinerify')),
      body: RefreshIndicator(
        onRefresh: _refreshHomeData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<List<Restaurant>>(
              future: _restaurantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Belum bisa memuat data restoran: ${snapshot.error}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }

                final restaurants = snapshot.data ?? [];
                if (restaurants.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Belum ada data restoran tersedia.'),
                    ),
                  );
                }

                final featuredRestaurants = restaurants.take(3).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRatedCarousel(restaurants),
                    const SizedBox(height: 22),
                    const Text(
                      'Rekomendasi Tempat Makan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...featuredRestaurants.map((restaurant) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              restaurant.imageUrl,
                              width: 54,
                              height: 54,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 54,
                                    height: 54,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.restaurant),
                                  ),
                            ),
                          ),
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${restaurant.category} • ⭐ ${restaurant.rating}',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailScreen(
                                  restaurant: restaurant,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            const Text(
              'Menu Pilihan',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Menu>>(
              future: _menusFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        'Belum bisa memuat menu pilihan: ${snapshot.error}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  );
                }

                final menus = snapshot.data ?? [];
                if (menus.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text('Belum ada menu tersedia.'),
                    ),
                  );
                }

                final featuredMenus = menus.take(3).toList();

                return Column(
                  children: featuredMenus.map((menu) {
                    final cleanRestaurant = menu.restaurantName.trim();
                    final hasValidRestaurant =
                        cleanRestaurant.isNotEmpty &&
                        cleanRestaurant.toLowerCase() != 'restoran';
                    final subtitleText = hasValidRestaurant
                        ? '$cleanRestaurant • Rp ${menu.price}'
                        : 'Rp ${menu.price}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            menu.imageUrl,
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 54,
                                  height: 54,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.fastfood),
                                ),
                          ),
                        ),
                        title: Text(
                          menu.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(subtitleText),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 15),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MenuDetailScreen(menu: menu),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
