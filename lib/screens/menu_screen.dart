import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../services/api_service.dart';
import 'menu_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Menu>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _menusFuture = _apiService.getMenus();
  }

  Future<void> _refreshMenus() async {
    setState(() {
      _menusFuture = _apiService.getMenus();
    });
    await _menusFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: RefreshIndicator(
        onRefresh: _refreshMenus,
        child: FutureBuilder<List<Menu>>(
          future: _menusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Gagal memuat menu: ${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refreshMenus,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final menus = snapshot.data ?? [];
            if (menus.isEmpty) {
              return const Center(child: Text('Belum ada menu tersedia.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
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
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
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
                    subtitle: Text(subtitleText),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              },
            );
          },
        ),
      ),
    );
  }
}
