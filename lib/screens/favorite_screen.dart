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
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepOrange,
                        child: Icon(Icons.restaurant, color: Colors.white),
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
                ...favMenus.map(
                  (menu) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.orangeAccent,
                        child: Icon(Icons.fastfood, color: Colors.white),
                      ),
                      title: Text(
                        menu.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${menu.restaurantName} • Rp ${menu.price}',
                      ),
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
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
