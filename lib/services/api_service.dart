import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';

class ApiService {
  // CATATAN ALAMAT URL:
  // - Gunakan 'http://localhost:3000/api' kalo testing di Windows Desktop / Web (Chrome)
  // - Gunakan 'http://10.0.2.2:3000/api' kalo testing di Android Emulator
  static const String baseUrl = 'http://localhost:3000/api';

  // Fungsi untuk mengambil data restoran dari API
  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$baseUrl/restaurants'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data restoran');
    }
  }

  Future<List<Menu>> getMenusByRestaurant(String restaurantId) async {
    final allMenus = await getMenus();
    if (restaurantId.isEmpty) return [];
    return allMenus.where((menu) => menu.restaurantId == restaurantId).toList();
  }

  // Fungsi untuk mengambil data menu dari API
  Future<List<Menu>> getMenus() async {
    final response = await http.get(Uri.parse('$baseUrl/menus'));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((json) => Menu.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data menu');
    }
  }

  // Fungsi untuk menambah data restoran baru ke database (POST)
  Future<Restaurant> createRestaurant({
    required String name,
    required String category,
    required String address,
    double? rating,
    String? imageUrl,
    String? mapsUrl,
  }) async {
    final Map<String, dynamic> body = {
      'name': name.trim(),
      'category': category.trim(),
      'address': address.trim(),
      if (rating != null) 'rating': rating,
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'image_url': imageUrl.trim(),
      if (mapsUrl != null && mapsUrl.trim().isNotEmpty)
        'maps_url': mapsUrl.trim(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/restaurants'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic> && decoded['id'] != null) {
        return Restaurant.fromJson(decoded);
      }
      return Restaurant(
        id: '',
        name: name.trim(),
        category: category.trim(),
        address: address.trim(),
        rating: rating ?? 0.0,
        imageUrl: imageUrl?.trim() ?? '',
        mapsUrl: mapsUrl?.trim() ?? '',
      );
    } else {
      String message = 'Gagal menambahkan restoran';
      try {
        final errBody = json.decode(response.body);
        if (errBody is Map<String, dynamic> && errBody['message'] != null) {
          message = errBody['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  // Fungsi untuk menambah data menu baru ke database (POST)
  Future<Menu> createMenu({
    required String restaurantId,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    String restaurantName = '',
  }) async {
    final parsedRestaurantId = int.tryParse(restaurantId);
    final Map<String, dynamic> body = {
      'restaurant_id': parsedRestaurantId ?? restaurantId,
      'name': name.trim(),
      'price': price,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
      if (imageUrl != null && imageUrl.trim().isNotEmpty)
        'image_url': imageUrl.trim(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/menus'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic> && decoded['id'] != null) {
        return Menu.fromJson({
          ...decoded,
          if ((decoded['restaurant_name'] == null ||
                  decoded['restaurant_name'].toString().isEmpty) &&
              restaurantName.isNotEmpty)
            'restaurant_name': restaurantName,
        });
      }
      return Menu(
        id: '',
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        name: name.trim(),
        description: description?.trim() ?? '',
        price: price,
        imageUrl: imageUrl?.trim() ?? '',
      );
    } else {
      String message = 'Gagal menambahkan menu';
      try {
        final errBody = json.decode(response.body);
        if (errBody is Map<String, dynamic> && errBody['message'] != null) {
          message = errBody['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
