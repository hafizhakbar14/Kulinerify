import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../widgets/error_state.dart';
import '../widgets/menu_form_dialog.dart';
import 'menu_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Menu>> _menusFuture;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  static const List<String> _categories = [
    'Semua',
    'Makanan Berat',
    'Mie & Kuah',
    'Kopi & Minuman',
    'Snack & Manis',
  ];

  @override
  void initState() {
    super.initState();
    _menusFuture = _apiService.getMenus();
    dataSync.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    dataSync.removeListener(_onDataChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Dipanggil saat ada tambah/edit/hapus (dari layar ini maupun layar lain).
  void _onDataChanged() {
    if (!mounted) return;
    setState(() {
      _menusFuture = _apiService.getMenus();
    });
  }

  Future<void> _refreshMenus() async {
    setState(() {
      _menusFuture = _apiService.getMenus();
    });
    try {
      await _menusFuture;
    } catch (_) {
      // Error ditampilkan oleh FutureBuilder.
    }
  }

  String _inferMenuCategory(Menu menu) {
    final text = '${menu.name} ${menu.description} ${menu.restaurantName}'
        .toLowerCase();

    if (text.contains('kopi') ||
        text.contains('coffee') ||
        text.contains('teh') ||
        text.contains('es ') ||
        text.contains('jus') ||
        text.contains('susu') ||
        text.contains('matcha') ||
        text.contains('minuman')) {
      return 'Kopi & Minuman';
    }

    if (text.contains('mie') ||
        text.contains('soto') ||
        text.contains('bakso') ||
        text.contains('kuah') ||
        text.contains('spageti') ||
        text.contains('ramen') ||
        text.contains('seblak')) {
      return 'Mie & Kuah';
    }

    if (text.contains('snack') ||
        text.contains('roti') ||
        text.contains('kue') ||
        text.contains('kentang') ||
        text.contains('pisang') ||
        text.contains('manis') ||
        text.contains('toast') ||
        text.contains('burjo')) {
      return 'Snack & Manis';
    }

    return 'Makanan Berat';
  }

  List<Menu> _filterMenus(List<Menu> menus) {
    final query = _searchQuery.trim().toLowerCase();

    return menus.where((menu) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          _inferMenuCategory(menu) == _selectedCategory;

      final cleanRestaurant = menu.restaurantName.trim();
      final hasValidRestaurant =
          cleanRestaurant.isNotEmpty &&
          cleanRestaurant.toLowerCase() != 'restoran';

      final matchesQuery =
          query.isEmpty ||
          menu.name.toLowerCase().contains(query) ||
          menu.description.toLowerCase().contains(query) ||
          (hasValidRestaurant && cleanRestaurant.toLowerCase().contains(query));

      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _showAddMenuDialog() async {
    final created = await showDialog<Menu>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const MenuFormDialog(),
    );

    if (created == null || !mounted) return;

    dataSync.bump(); // memicu refresh daftar (termasuk layar ini)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Menu berhasil ditambahkan!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenuDialog,
        tooltip: 'Tambah Menu',
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMenus,
        child: FutureBuilder<List<Menu>>(
          future: _menusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  ErrorState(error: snapshot.error!, onRetry: _refreshMenus),
                ],
              );
            }

            final allMenus = snapshot.data ?? [];
            final filteredMenus = _filterMenus(allMenus);

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
                      hintText: 'Cari nama menu atau tempat makan...',
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

                // Filter Kategori Menu
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
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

                // Daftar Menu
                Expanded(
                  child: allMenus.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Belum ada menu tersedia.')),
                          ],
                        )
                      : filteredMenus.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text(
                                'Menu tidak ditemukan.\nCoba ubah kata kunci atau kategori.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: filteredMenus.length,
                          itemBuilder: (context, index) {
                            final menu = filteredMenus[index];
                            final heroTag = 'menu-list-${menu.id}';
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
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 52,
                                                height: 52,
                                                color: Colors.grey.shade300,
                                                child: const Icon(
                                                  Icons.fastfood,
                                                  size: 24,
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
                                subtitle: Text(subtitleText),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
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
