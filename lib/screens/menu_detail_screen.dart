import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'restaurant_detail_screen.dart';

class MenuDetailScreen extends StatefulWidget {
  final Menu menu;
  final bool fromRestaurantDetail;

  const MenuDetailScreen({
    super.key,
    required this.menu,
    this.fromRestaurantDetail = false,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Restaurant?> _originRestaurantFuture;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _originRestaurantFuture = _resolveOriginRestaurant();
  }

  Future<Restaurant?> _resolveOriginRestaurant() async {
    final directName = widget.menu.restaurantName.trim();
    final hasDirectName =
        directName.isNotEmpty && directName.toLowerCase() != 'restoran';

    if (widget.menu.restaurantId.isEmpty && !hasDirectName) {
      return null;
    }

    final restaurants = await _apiService.getRestaurants();
    if (widget.menu.restaurantId.isNotEmpty) {
      for (final r in restaurants) {
        if (r.id == widget.menu.restaurantId) {
          return r;
        }
      }
    }

    if (hasDirectName) {
      for (final r in restaurants) {
        if (r.name.toLowerCase() == directName.toLowerCase()) {
          return r;
        }
      }
    }

    return null;
  }

  Future<void> _openOriginRestaurant(Restaurant? preloadedRestaurant) async {
    if (widget.fromRestaurantDetail) {
      Navigator.pop(context);
      return;
    }

    if (preloadedRestaurant != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RestaurantDetailScreen(restaurant: preloadedRestaurant),
        ),
      );
      return;
    }

    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    try {
      final matched = await _resolveOriginRestaurant();
      if (!mounted) return;

      if (matched != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(restaurant: matched),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data restoran asal tidak ditemukan.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat restoran asal: $e')));
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;
    final directName = menu.restaurantName.trim();
    final hasDirectName =
        directName.isNotEmpty && directName.toLowerCase() != 'restoran';

    return ListenableBuilder(
      listenable: favoritesProvider,
      builder: (context, _) {
        final isFav = favoritesProvider.isMenuFavorite(menu.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(menu.name),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  favoritesProvider.toggleMenuFavorite(menu);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${menu.name} dihapus dari Favorit'
                            : '${menu.name} ditambahkan ke Favorit',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  menu.imageUrl,
                  height: 240,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 240,
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.fastfood, size: 64)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rp ${menu.price}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        menu.description.isNotEmpty
                            ? menu.description
                            : 'Tidak ada deskripsi menu.',
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Restoran Asal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<Restaurant?>(
                        future: _originRestaurantFuture,
                        builder: (context, snapshot) {
                          final resolvedRestaurant = snapshot.data;
                          final displayName = hasDirectName
                              ? directName
                              : (resolvedRestaurant?.name ??
                                    (snapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? 'Memuat restoran...'
                                        : 'Lihat Detail Restoran'));

                          return Card(
                            elevation: 2,
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.deepOrange,
                                child: Icon(
                                  Icons.storefront,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: const Text(
                                'Ketuk untuk melihat detail restoran',
                              ),
                              trailing: _isNavigating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                    ),
                              onTap: () =>
                                  _openOriginRestaurant(resolvedRestaurant),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
