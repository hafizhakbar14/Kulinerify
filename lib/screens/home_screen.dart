import 'package:flutter/material.dart';

import 'dart:async';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../widgets/category_rating.dart';
import '../widgets/error_state.dart';
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
  Timer? _autoSlideTimer;
  int _carouselCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
    dataSync.addListener(_onDataChanged);
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_carouselController.hasClients || _carouselCount < 2) return;
      final next = (_currentCarouselIndex + 1) % _carouselCount;
      _carouselController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    dataSync.removeListener(_onDataChanged);
    _carouselController.dispose();
    super.dispose();
  }

  void _loadHomeData() {
    _restaurantsFuture = _apiService.getRestaurants();
    _menusFuture = _apiService.getMenus();
  }

  // Dipanggil saat ada tambah/edit/hapus di layar lain.
  void _onDataChanged() {
    if (!mounted) return;
    setState(_loadHomeData);
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
    final scheme = Theme.of(context).colorScheme;
    final topRestaurants = _getTopRatedRestaurants(restaurants);
    if (topRestaurants.isEmpty) {
      return const SizedBox.shrink();
    }
    _carouselCount = topRestaurants.length;

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
              final heroTag = 'home-top-${restaurant.id}';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(
                        restaurant: restaurant,
                        heroTag: heroTag,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: heroTag,
                        child: Image.network(
                          restaurant.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: scheme.primaryContainer,
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 48,
                                    color: scheme.primary,
                                  ),
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
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: scheme.onPrimary,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${restaurant.rating.toStringAsFixed(1)} • ${restaurant.category}',
                                    style: TextStyle(
                                      color: scheme.onPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                color: isActive ? scheme.primary : Colors.grey.shade300,
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
                  return ErrorState(
                    error: snapshot.error!,
                    onRetry: () => setState(_loadHomeData),
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
                      final heroTag = 'home-rec-${restaurant.id}';
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Hero(
                            tag: heroTag,
                            child: ClipRRect(
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
                          ),
                          title: Text(
                            restaurant.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: CategoryRating(
                            category: restaurant.category,
                            rating: restaurant.rating,
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RestaurantDetailScreen(
                                  restaurant: restaurant,
                                  heroTag: heroTag,
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
                  return ErrorState(
                    error: snapshot.error!,
                    onRetry: () => setState(_loadHomeData),
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
                    final heroTag = 'home-menu-${menu.id}';
                    final cleanRestaurant = menu.restaurantName.trim();
                    final hasValidRestaurant =
                        cleanRestaurant.isNotEmpty &&
                        cleanRestaurant.toLowerCase() != 'restoran';
                    final subtitleText = hasValidRestaurant
                        ? '$cleanRestaurant • ${formatRupiah(menu.price)}'
                        : formatRupiah(menu.price);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Hero(
                          tag: heroTag,
                          child: ClipRRect(
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
                              builder: (_) => MenuDetailScreen(
                                menu: menu,
                                heroTag: heroTag,
                              ),
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
