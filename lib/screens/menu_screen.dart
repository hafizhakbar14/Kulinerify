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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: FutureBuilder<List<Menu>>(
        future: _menusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final menus = snapshot.data ?? [];
          if (menus.isEmpty) {
            return const Center(child: Text('Belum ada data menu.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      menu.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.fastfood),
                      ),
                    ),
                  ),
                  title: Text(
                    menu.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${menu.restaurantName} • Rp ${menu.price}'),
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
    );
  }
}
