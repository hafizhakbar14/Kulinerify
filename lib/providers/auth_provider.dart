import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  final String name;
  final String email;

  const AppUser({required this.name, required this.email});
}

/// Akun disimpan lokal di perangkat (SharedPreferences).
/// Password di-hash SHA-256 dengan salt acak per akun.
class AuthProvider extends ChangeNotifier {
  static const String _usersKey = 'auth_users_v1';
  static const String _sessionKey = 'auth_session_v1';

  final List<Map<String, String>> _users = [];
  AppUser? _currentUser;
  bool _isLoaded = false;

  AuthProvider() {
    _load();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoaded => _isLoaded;
  bool get isLoggedIn => _currentUser != null;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawUsers = prefs.getString(_usersKey);
      if (rawUsers != null && rawUsers.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawUsers);
        _users
          ..clear()
          ..addAll(decoded.map((e) => Map<String, String>.from(e as Map)));
      }

      final sessionEmail = prefs.getString(_sessionKey);
      if (sessionEmail != null) {
        final user = _findUser(sessionEmail);
        if (user != null) _currentUser = _toAppUser(user);
      }
    } catch (e) {
      debugPrint('Gagal memuat data akun: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Map<String, String>? _findUser(String email) {
    for (final u in _users) {
      if (u['email'] == email) return u;
    }
    return null;
  }

  AppUser _toAppUser(Map<String, String> u) =>
      AppUser(name: u['name'] ?? '', email: u['email'] ?? '');

  String _newSalt() {
    final random = Random.secure();
    return base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// Mengembalikan pesan error, atau null kalau berhasil (otomatis login).
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (_findUser(key) != null) {
      return 'Email sudah terdaftar. Silakan login.';
    }

    final salt = _newSalt();
    final user = <String, String>{
      'name': name.trim(),
      'email': key,
      'salt': salt,
      'hash': _hash(password, salt),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      _users.add(user);
      await prefs.setString(_usersKey, jsonEncode(_users));
      await prefs.setString(_sessionKey, key);
    } catch (e) {
      _users.remove(user);
      debugPrint('Gagal menyimpan akun: $e');
      return 'Gagal menyimpan akun. Coba lagi.';
    }

    _currentUser = _toAppUser(user);
    notifyListeners();
    return null;
  }

  /// Mengembalikan pesan error, atau null kalau berhasil.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    final user = _findUser(key);

    if (user == null || _hash(password, user['salt'] ?? '') != user['hash']) {
      return 'Email atau password salah.';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, key);
    } catch (e) {
      // Sesi gagal tersimpan: tetap masuk, hanya tidak diingat saat app dibuka lagi.
      debugPrint('Gagal menyimpan sesi: $e');
    }

    _currentUser = _toAppUser(user);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      debugPrint('Gagal menghapus sesi: $e');
    }
  }
}

final AuthProvider authProvider = AuthProvider();
