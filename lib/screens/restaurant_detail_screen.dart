import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'menu_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Menu>> _restaurantMenusFuture;

  @override
  void initState() {
    super.initState();
    _restaurantMenusFuture = _apiService.getMenusByRestaurant(
      widget.restaurant.id,
    );
  }

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(widget.restaurant.mapsUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = widget.restaurant;

    return ListenableBuilder(
      listenable: favoritesProvider,
      builder: (context, _) {
        final isFav = favoritesProvider.isRestaurantFavorite(restaurant.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(restaurant.name),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                onPressed: () {
                  favoritesProvider.toggleRestaurantFavorite(restaurant);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? '${restaurant.name} dihapus dari Favorit'
                            : '${restaurant.name} ditambahkan ke Favorit',
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
                  restaurant.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.restaurant, size: 64),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Chip(label: Text(restaurant.category)),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              restaurant.address,
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openGoogleMaps,
                          icon: const Icon(Icons.map, color: Colors.deepOrange),
                          label: const Text(
                            'Buka Lokasi di Google Maps',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.deepOrange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Menu yang Disajikan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Menu>>(
                        future: _restaurantMenusFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Text('Gagal memuat menu: ${snapshot.error}');
                          }
                          final menus = snapshot.data ?? [];
                          if (menus.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Belum ada menu terdaftar untuk restoran ini.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: menus.length,
                            itemBuilder: (context, index) {
                              final menu = menus[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      menu.imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 22,
                                                ),
                                              ),
                                    ),
                                  ),
                                  title: Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text('Rp ${menu.price}'),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuDetailScreen(
                                          menu: menu,
                                          fromRestaurantDetail: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
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
