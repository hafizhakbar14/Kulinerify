import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/error_state.dart';
import '../widgets/restaurant_form_dialog.dart';
import 'menu_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  /// Tag Hero dari layar asal (null = tanpa animasi Hero).
  final String? heroTag;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    this.heroTag,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ApiService _apiService = ApiService();
  late Restaurant _restaurant;
  late Future<List<Menu>> _restaurantMenusFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _restaurant = widget.restaurant;
    _restaurantMenusFuture = _apiService.getMenusByRestaurant(_restaurant.id);
    dataSync.addListener(_reloadMenus);
  }

  @override
  void dispose() {
    dataSync.removeListener(_reloadMenus);
    super.dispose();
  }

  void _reloadMenus() {
    if (!mounted) return;
    setState(() {
      _restaurantMenusFuture = _apiService.getMenusByRestaurant(_restaurant.id);
    });
  }

  Future<void> _openGoogleMaps() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = Uri.parse(_restaurant.mapsUrl);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Link lokasi tidak valid.')),
      );
    }
  }

  Future<void> _editRestaurant() async {
    final updated = await showDialog<Restaurant>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RestaurantFormDialog(initial: _restaurant),
    );

    if (updated == null || !mounted) return;

    setState(() => _restaurant = updated);
    favoritesProvider.syncRestaurant(updated);
    dataSync.bump();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restoran berhasil diperbarui!')),
    );
  }

  Future<void> _deleteRestaurant() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus restoran?',
      message:
          'Restoran "${_restaurant.name}" akan dihapus permanen. '
          'Menu milik restoran ini mungkin ikut terhapus.',
      confirmLabel: 'Hapus',
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isDeleting = true);

    try {
      await _apiService.deleteRestaurant(_restaurant.id);
      favoritesProvider.removeRestaurantById(_restaurant.id);
      dataSync.bump();
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Restoran berhasil dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = _restaurant;
    final scheme = Theme.of(context).colorScheme;

    Widget heroImage = Image.network(
      restaurant.imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 220,
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.restaurant, size: 64)),
      ),
    );
    if (widget.heroTag != null) {
      heroImage = Hero(tag: widget.heroTag!, child: heroImage);
    }

    return ListenableBuilder(
      listenable: favoritesProvider,
      builder: (context, _) {
        final isFav = favoritesProvider.isRestaurantFavorite(restaurant.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(restaurant.name),
            bottom: _isDeleting
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(),
                  )
                : null,
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
              PopupMenuButton<String>(
                enabled: !_isDeleting,
                onSelected: (value) {
                  if (value == 'edit') {
                    _editRestaurant();
                  } else if (value == 'delete') {
                    _deleteRestaurant();
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline),
                        SizedBox(width: 12),
                        Text('Hapus'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heroImage,
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
                            restaurant.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: scheme.primary),
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
                          icon: Icon(Icons.map, color: scheme.primary),
                          label: const Text(
                            'Buka Lokasi di Google Maps',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: scheme.primary),
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
                            return ErrorState(
                              error: snapshot.error!,
                              onRetry: _reloadMenus,
                            );
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
                              final heroTag = 'rdetail-menu-${menu.id}';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: Hero(
                                    tag: heroTag,
                                    child: ClipRRect(
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
                                  ),
                                  title: Text(
                                    menu.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(formatRupiah(menu.price)),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => MenuDetailScreen(
                                          menu: menu,
                                          fromRestaurantDetail: true,
                                          heroTag: heroTag,
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
