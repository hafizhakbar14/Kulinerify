import 'package:flutter/material.dart';

import '../providers/app_state.dart';
import 'menu_detail_screen.dart';
import 'restaurant_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit Saya')),
      body: ListenableBuilder(
        listenable: favoritesProvider,
        builder: (context, _) {
          final favRestaurants = favoritesProvider.favoriteRestaurants;
          final favMenus = favoritesProvider.favoriteMenus;

          if (favRestaurants.isEmpty && favMenus.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada restoran atau menu favorit.\nTekan ikon hati di halaman detail untuk menyimpan.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (favRestaurants.isNotEmpty) ...[
                const Text(
                  'Restoran Favorit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...favRestaurants.map(
                  (restaurant) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          restaurant.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 52,
                                height: 52,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.restaurant, size: 24),
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
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => favoritesProvider
                            .toggleRestaurantFavorite(restaurant),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RestaurantDetailScreen(restaurant: restaurant),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (favMenus.isNotEmpty) ...[
                const Text(
                  'Menu Favorit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...favMenus.map((menu) {
                  final cleanRestaurant = menu.restaurantName.trim();
                  final hasValidRestaurant =
                      cleanRestaurant.isNotEmpty &&
                      cleanRestaurant.toLowerCase() != 'restoran';
                  final menuSubtitle = hasValidRestaurant
                      ? '$cleanRestaurant • Rp ${menu.price}'
                      : 'Rp ${menu.price}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          menu.imageUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 52,
                                height: 52,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.fastfood, size: 24),
                              ),
                        ),
                      ),
                      title: Text(
                        menu.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(menuSubtitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () =>
                            favoritesProvider.toggleMenuFavorite(menu),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuDetailScreen(menu: menu),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}
