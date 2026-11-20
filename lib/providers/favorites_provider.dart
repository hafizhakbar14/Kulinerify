import 'package:flutter/foundation.dart';

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Restaurant> _favoriteRestaurants = [];
  final List<Menu> _favoriteMenus = [];

  List<Restaurant> get favoriteRestaurants =>
      List.unmodifiable(_favoriteRestaurants);
  List<Menu> get favoriteMenus => List.unmodifiable(_favoriteMenus);

  bool isRestaurantFavorite(String restaurantId) {
    return _favoriteRestaurants.any((r) => r.id == restaurantId);
  }

  bool isMenuFavorite(String menuId) {
    return _favoriteMenus.any((m) => m.id == menuId);
  }

  void toggleRestaurantFavorite(Restaurant restaurant) {
    final index = _favoriteRestaurants.indexWhere((r) => r.id == restaurant.id);
    if (index >= 0) {
      _favoriteRestaurants.removeAt(index);
    } else {
      _favoriteRestaurants.add(restaurant);
    }
    notifyListeners();
  }

  void toggleMenuFavorite(Menu menu) {
    final index = _favoriteMenus.indexWhere((m) => m.id == menu.id);
    if (index >= 0) {
      _favoriteMenus.removeAt(index);
    } else {
      _favoriteMenus.add(menu);
    }
    notifyListeners();
  }
}
