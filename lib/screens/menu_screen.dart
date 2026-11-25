import 'package:flutter/material.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';
import '../services/api_service.dart';
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
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshMenus() async {
    setState(() {
      _menusFuture = _apiService.getMenus();
    });
    await _menusFuture;
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
    List<Restaurant> restaurants = [];
    String? loadError;

    try {
      restaurants = await _apiService.getRestaurants();
    } catch (e) {
      loadError = e.toString();
    }

    if (!mounted) return;

    if (loadError != null || restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loadError != null
                ? 'Gagal memuat daftar restoran: $loadError'
                : 'Tambahkan restoran terlebih dahulu sebelum menambah menu.',
          ),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageUrlController = TextEditingController();
    Restaurant selectedRestaurant = restaurants.first;
    bool isSubmitting = false;

    final bool? created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> submit() async {
              if (!formKey.currentState!.validate()) return;

              final parsedPrice = int.tryParse(priceController.text.trim());
              if (parsedPrice == null || parsedPrice < 0) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Harga harus berupa angka bulat valid'),
                  ),
                );
                return;
              }

              setDialogState(() {
                isSubmitting = true;
              });

              try {
                await _apiService.createMenu(
                  restaurantId: selectedRestaurant.id,
                  restaurantName: selectedRestaurant.name,
                  name: nameController.text,
                  price: parsedPrice,
                  description: descriptionController.text,
                  imageUrl: imageUrlController.text,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                setDialogState(() {
                  isSubmitting = false;
                });
                if (this.context.mounted) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Gagal menambah menu: $e')),
                  );
                }
              }
            }

            return AlertDialog(
              title: const Text('Tambah Menu'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Restaurant>(
                        initialValue: selectedRestaurant,
                        decoration: const InputDecoration(
                          labelText: 'Restoran *',
                        ),
                        items: restaurants
                            .map(
                              (r) => DropdownMenuItem<Restaurant>(
                                value: r,
                                child: Text(
                                  r.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedRestaurant = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Menu *',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama menu wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga (Rp) *',
                          hintText: 'Contoh: 15000',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Harga wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (opsional)',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL (opsional)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();

    if (created == true && mounted) {
      await _refreshMenus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil ditambahkan!')),
        );
      }
    }
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
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                                      builder: (context) =>
                                          MenuDetailScreen(menu: menu),
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
