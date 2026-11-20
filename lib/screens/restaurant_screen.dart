import 'package:flutter/material.dart';

import '../models/restaurant_model.dart';
import '../services/api_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Restaurant>> _restaurantsFuture;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _restaurantsFuture = _apiService.getRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshRestaurants() async {
    setState(() {
      _restaurantsFuture = _apiService.getRestaurants();
    });
    await _restaurantsFuture;
  }

  List<String> _extractCategories(List<Restaurant> restaurants) {
    final Set<String> categories = {'Semua'};
    for (final r in restaurants) {
      final cat = r.category.trim();
      if (cat.isNotEmpty) {
        categories.add(cat);
      }
    }
    return categories.toList();
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> restaurants) {
    final query = _searchQuery.trim().toLowerCase();

    return restaurants.where((r) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          r.category.trim().toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          r.name.toLowerCase().contains(query) ||
          r.address.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kuliner Tembalang')),
      body: RefreshIndicator(
        onRefresh: _refreshRestaurants,
        child: FutureBuilder<List<Restaurant>>(
          future: _restaurantsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Gagal memuat restoran: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _refreshRestaurants,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final allRestaurants = snapshot.data ?? [];
            final categories = _extractCategories(allRestaurants);

            // Jika kategori terpilih sudah tidak ada setelah refresh, reset ke 'Semua'
            if (!categories.contains(_selectedCategory)) {
              _selectedCategory = 'Semua';
            }

            final filteredRestaurants = _filterRestaurants(allRestaurants);

            return Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari nama tempat, lokasi, atau kategori...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Filter Kategori (ChoiceChip)
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Daftar Restoran
                Expanded(
                  child: allRestaurants.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Belum ada data restoran.')),
                          ],
                        )
                      : filteredRestaurants.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Restoran tidak ditemukan.\nCoba ubah kata kunci atau kategori.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = filteredRestaurants[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    restaurant.imageUrl,
                                    width: 58,
                                    height: 58,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 58,
                                              height: 58,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.restaurant,
                                                size: 26,
                                              ),
                                            ),
                                  ),
                                ),
                                title: Text(
                                  restaurant.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${restaurant.category} • ⭐ ${restaurant.rating}\n${restaurant.address}',
                                ),
                                isThreeLine: true,
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RestaurantDetailScreen(
                                            restaurant: restaurant,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
