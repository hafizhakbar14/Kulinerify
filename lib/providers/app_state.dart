import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';

/// Pemberitahuan sederhana: dipanggil setelah data restoran/menu berubah
/// (tambah, edit, hapus) agar layar lain memuat ulang datanya.
class DataSync extends ChangeNotifier {
  void bump() => notifyListeners();
}

final DataSync dataSync = DataSync();

class FavoritesProvider extends ChangeNotifier {
  static const String _restaurantsKey = 'favorite_restaurants_v1';
  static const String _menusKey = 'favorite_menus_v1';

  final List<Restaurant> _favoriteRestaurants = [];
  final List<Menu> _favoriteMenus = [];
  bool _isLoaded = false;

  FavoritesProvider() {
    loadFavorites();
  }

  List<Restaurant> get favoriteRestaurants =>
      List.unmodifiable(_favoriteRestaurants);
  List<Menu> get favoriteMenus => List.unmodifiable(_favoriteMenus);
  bool get isLoaded => _isLoaded;

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawRestaurants = prefs.getString(_restaurantsKey);
      if (rawRestaurants != null && rawRestaurants.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawRestaurants);
        _favoriteRestaurants
          ..clear()
          ..addAll(
            decoded.map(
              (item) => Restaurant.fromJson(item as Map<String, dynamic>),
            ),
          );
      }

      final rawMenus = prefs.getString(_menusKey);
      if (rawMenus != null && rawMenus.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawMenus);
        _favoriteMenus
          ..clear()
          ..addAll(
            decoded.map((item) => Menu.fromJson(item as Map<String, dynamic>)),
          );
      }
    } catch (e) {
      debugPrint('Gagal memuat favorit dari SharedPreferences: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> _saveRestaurants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _favoriteRestaurants.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_restaurantsKey, encoded);
    } catch (e) {
      debugPrint('Gagal menyimpan restoran favorit: $e');
    }
  }

  Future<void> _saveMenus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _favoriteMenus.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(_menusKey, encoded);
    } catch (e) {
      debugPrint('Gagal menyimpan menu favorit: $e');
    }
  }

  bool isRestaurantFavorite(String id) {
    return _favoriteRestaurants.any((r) => r.id == id);
  }

  bool isMenuFavorite(String id) {
    return _favoriteMenus.any((m) => m.id == id);
  }

  void toggleRestaurantFavorite(Restaurant restaurant) {
    final index = _favoriteRestaurants.indexWhere((r) => r.id == restaurant.id);
    if (index >= 0) {
      _favoriteRestaurants.removeAt(index);
    } else {
      _favoriteRestaurants.add(restaurant);
    }
    notifyListeners();
    _saveRestaurants();
  }

  void toggleMenuFavorite(Menu menu) {
    final index = _favoriteMenus.indexWhere((m) => m.id == menu.id);
    if (index >= 0) {
      _favoriteMenus.removeAt(index);
    } else {
      _favoriteMenus.add(menu);
    }
    notifyListeners();
    _saveMenus();
  }

  // --- Sinkronisasi setelah edit / hapus data ---

  /// Perbarui salinan restoran favorit (dan nama restoran di menu favorit).
  void syncRestaurant(Restaurant updated) {
    var restaurantChanged = false;
    var menusChanged = false;

    final index = _favoriteRestaurants.indexWhere((r) => r.id == updated.id);
    if (index >= 0) {
      _favoriteRestaurants[index] = updated;
      restaurantChanged = true;
    }

    for (var i = 0; i < _favoriteMenus.length; i++) {
      final m = _favoriteMenus[i];
      if (m.restaurantId == updated.id && m.restaurantName != updated.name) {
        _favoriteMenus[i] = Menu(
          id: m.id,
          restaurantId: m.restaurantId,
          restaurantName: updated.name,
          name: m.name,
          description: m.description,
          price: m.price,
          imageUrl: m.imageUrl,
        );
        menusChanged = true;
      }
    }

    if (restaurantChanged || menusChanged) notifyListeners();
    if (restaurantChanged) _saveRestaurants();
    if (menusChanged) _saveMenus();
  }

  void removeRestaurantById(String id) {
    final before = _favoriteRestaurants.length;
    _favoriteRestaurants.removeWhere((r) => r.id == id);
    if (_favoriteRestaurants.length != before) {
      notifyListeners();
      _saveRestaurants();
    }
  }

  void syncMenu(Menu updated) {
    final index = _favoriteMenus.indexWhere((m) => m.id == updated.id);
    if (index < 0) return;
    _favoriteMenus[index] = updated;
    notifyListeners();
    _saveMenus();
  }

  void removeMenuById(String id) {
    final before = _favoriteMenus.length;
    _favoriteMenus.removeWhere((m) => m.id == id);
    if (_favoriteMenus.length != before) {
      notifyListeners();
      _saveMenus();
    }
  }
}

final FavoritesProvider favoritesProvider = FavoritesProvider();
