import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/menu_model.dart';
import '../models/restaurant_model.dart';

/// Error dengan pesan yang aman ditampilkan langsung ke pengguna.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Mengubah error apa pun menjadi teks ramah untuk pengguna.
String friendlyError(Object error) =>
    error is ApiException ? error.message : 'Terjadi kesalahan. Coba lagi.';

class ApiService {
  // CATATAN ALAMAT URL:
  // - 'http://localhost:3000/api'  -> Windows Desktop / Web (Chrome)
  // - 'http://10.0.2.2:3000/api'   -> Android Emulator
  static const String baseUrl = 'http://localhost:3000/api';

  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // ---------------------------------------------------------------------------
  // Helper
  // ---------------------------------------------------------------------------

  Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Server tidak merespons. Coba lagi.');
    } on http.ClientException {
      throw ApiException(
        'Tidak bisa terhubung ke server. Pastikan backend sudah berjalan.',
      );
    }
  }

  bool _isSuccess(int code) => code >= 200 && code < 300;

  dynamic _decode(String body) {
    try {
      return json.decode(body);
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    }
  }

  String _errorMessage(http.Response res, String fallback) {
    try {
      final body = json.decode(res.body);
      if (body is Map<String, dynamic> && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  Map<String, dynamic>? _tryDecodeObject(http.Response res) {
    if (res.body.isEmpty) return null;
    try {
      final decoded = json.decode(res.body);
      if (decoded is Map<String, dynamic> &&
          decoded['id'] != null &&
          decoded['name'] != null) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  // ---------------------------------------------------------------------------
  // Restoran
  // ---------------------------------------------------------------------------

  Future<List<Restaurant>> getRestaurants() async {
    final res = await _send(http.get(Uri.parse('$baseUrl/restaurants')));
    if (res.statusCode != 200) {
      throw ApiException(
        'Gagal memuat data restoran (kode ${res.statusCode}).',
      );
    }
    final data = _decode(res.body);
    if (data is! List) {
      throw ApiException('Format data restoran tidak valid.');
    }
    return data
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> _restaurantBody({
    required String name,
    required String category,
    required String address,
    double? rating,
    String? imageUrl,
    String? mapsUrl,
    required bool forUpdate,
  }) {
    final image = imageUrl?.trim() ?? '';
    final maps = mapsUrl?.trim() ?? '';
    return {
      'name': name.trim(),
      'category': category.trim(),
      'address': address.trim(),
      if (rating != null) 'rating': rating,
      // Saat update, field kosong tetap dikirim supaya bisa dikosongkan.
      if (forUpdate || image.isNotEmpty) 'image_url': image,
      if (forUpdate || maps.isNotEmpty) 'maps_url': maps,
    };
  }

  Future<Restaurant> createRestaurant({
    required String name,
    required String category,
    required String address,
    double? rating,
    String? imageUrl,
    String? mapsUrl,
  }) async {
    final res = await _send(
      http.post(
        Uri.parse('$baseUrl/restaurants'),
        headers: _jsonHeaders,
        body: json.encode(
          _restaurantBody(
            name: name,
            category: category,
            address: address,
            rating: rating,
            imageUrl: imageUrl,
            mapsUrl: mapsUrl,
            forUpdate: false,
          ),
        ),
      ),
    );

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(_errorMessage(res, 'Gagal menambahkan restoran.'));
    }

    final decoded = _tryDecodeObject(res);
    if (decoded != null) return Restaurant.fromJson(decoded);

    return Restaurant(
      id: '',
      name: name.trim(),
      category: category.trim(),
      address: address.trim(),
      rating: rating ?? 0.0,
      imageUrl: imageUrl?.trim() ?? '',
      mapsUrl: mapsUrl?.trim() ?? '',
    );
  }

  Future<Restaurant> updateRestaurant({
    required String id,
    required String name,
    required String category,
    required String address,
    double? rating,
    String? imageUrl,
    String? mapsUrl,
  }) async {
    final res = await _send(
      http.put(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: _jsonHeaders,
        body: json.encode(
          _restaurantBody(
            name: name,
            category: category,
            address: address,
            rating: rating,
            imageUrl: imageUrl,
            mapsUrl: mapsUrl,
            forUpdate: true,
          ),
        ),
      ),
    );

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(_errorMessage(res, 'Gagal memperbarui restoran.'));
    }

    final decoded = _tryDecodeObject(res);
    if (decoded != null) return Restaurant.fromJson(decoded);

    return Restaurant(
      id: id,
      name: name.trim(),
      category: category.trim(),
      address: address.trim(),
      rating: rating ?? 0.0,
      imageUrl: imageUrl?.trim() ?? '',
      mapsUrl: mapsUrl?.trim() ?? '',
    );
  }

  Future<void> deleteRestaurant(String id) async {
    final res = await _send(http.delete(Uri.parse('$baseUrl/restaurants/$id')));
    if (!_isSuccess(res.statusCode)) {
      throw ApiException(
        _errorMessage(
          res,
          'Gagal menghapus restoran (kode ${res.statusCode}).',
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Menu
  // ---------------------------------------------------------------------------

  Future<List<Menu>> getMenus() async {
    final res = await _send(http.get(Uri.parse('$baseUrl/menus')));
    if (res.statusCode != 200) {
      throw ApiException('Gagal memuat data menu (kode ${res.statusCode}).');
    }
    final data = _decode(res.body);
    if (data is! List) {
      throw ApiException('Format data menu tidak valid.');
    }
    return data.map((e) => Menu.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Menu>> getMenusByRestaurant(String restaurantId) async {
    final allMenus = await getMenus();
    if (restaurantId.isEmpty) return [];
    return allMenus.where((menu) => menu.restaurantId == restaurantId).toList();
  }

  Map<String, dynamic> _menuBody({
    required String restaurantId,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    required bool forUpdate,
  }) {
    final desc = description?.trim() ?? '';
    final image = imageUrl?.trim() ?? '';
    return {
      'restaurant_id': int.tryParse(restaurantId) ?? restaurantId,
      'name': name.trim(),
      'price': price,
      if (forUpdate || desc.isNotEmpty) 'description': desc,
      if (forUpdate || image.isNotEmpty) 'image_url': image,
    };
  }

  /// Membaca menu dari respons server; kalau respons tidak lengkap,
  /// pakai [fallback]. Nama dan id restoran dilengkapi dari [fallback].
  Menu _menuFromResponse(http.Response res, Menu fallback) {
    final decoded = _tryDecodeObject(res);
    if (decoded == null) return fallback;

    final hasRestaurantName = (decoded['restaurant_name'] ?? '')
        .toString()
        .isNotEmpty;
    final hasRestaurantId = (decoded['restaurant_id'] ?? '')
        .toString()
        .isNotEmpty;

    return Menu.fromJson({
      ...decoded,
      if (!hasRestaurantName && fallback.restaurantName.isNotEmpty)
        'restaurant_name': fallback.restaurantName,
      if (!hasRestaurantId) 'restaurant_id': fallback.restaurantId,
    });
  }

  Future<Menu> createMenu({
    required String restaurantId,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    String restaurantName = '',
  }) async {
    final res = await _send(
      http.post(
        Uri.parse('$baseUrl/menus'),
        headers: _jsonHeaders,
        body: json.encode(
          _menuBody(
            restaurantId: restaurantId,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            forUpdate: false,
          ),
        ),
      ),
    );

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(_errorMessage(res, 'Gagal menambahkan menu.'));
    }

    return _menuFromResponse(
      res,
      Menu(
        id: '',
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        name: name.trim(),
        description: description?.trim() ?? '',
        price: price,
        imageUrl: imageUrl?.trim() ?? '',
      ),
    );
  }

  Future<Menu> updateMenu({
    required String id,
    required String restaurantId,
    required String name,
    required int price,
    String? description,
    String? imageUrl,
    String restaurantName = '',
  }) async {
    final res = await _send(
      http.put(
        Uri.parse('$baseUrl/menus/$id'),
        headers: _jsonHeaders,
        body: json.encode(
          _menuBody(
            restaurantId: restaurantId,
            name: name,
            price: price,
            description: description,
            imageUrl: imageUrl,
            forUpdate: true,
          ),
        ),
      ),
    );

    if (!_isSuccess(res.statusCode)) {
      throw ApiException(_errorMessage(res, 'Gagal memperbarui menu.'));
    }

    return _menuFromResponse(
      res,
      Menu(
        id: id,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        name: name.trim(),
        description: description?.trim() ?? '',
        price: price,
        imageUrl: imageUrl?.trim() ?? '',
      ),
    );
  }

  Future<void> deleteMenu(String id) async {
    final res = await _send(http.delete(Uri.parse('$baseUrl/menus/$id')));
    if (!_isSuccess(res.statusCode)) {
      throw ApiException(
        _errorMessage(res, 'Gagal menghapus menu (kode ${res.statusCode}).'),
      );
    }
  }
}
