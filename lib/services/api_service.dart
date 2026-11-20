import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/restaurant_model.dart';
import '../models/menu_model.dart';

class ApiService {
  // CATATAN ALAMAT URL:
  // - Gunakan 'http://localhost:3000/api' jika kamu testing di Windows Desktop / Web (Chrome)
  // - Gunakan 'http://10.0.2.2:3000/api' jika kamu testing di Android Emulator
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
}
