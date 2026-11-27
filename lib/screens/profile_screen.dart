import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import '../widgets/confirm_dialog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Keluar dari akun?',
      message: 'Kamu perlu login lagi untuk menggunakan Kulinerify.',
      confirmLabel: 'Keluar',
    );
    if (!confirmed) return;
    await authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = authProvider.currentUser;
    final initial = (user != null && user.name.isNotEmpty)
        ? user.name[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile / About')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: scheme.primary,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user?.name ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge_outlined, color: scheme.primary),
                  title: const Text('Pengembang'),
                  subtitle: const Text('Hafizh Muhammad Akbar'),
                ),
                ListTile(
                  leading: Icon(Icons.numbers, color: scheme.primary),
                  title: const Text('NIM'),
                  subtitle: const Text('21120124130098'),
                ),
                ListTile(
                  leading: Icon(Icons.school, color: scheme.primary),
                  title: const Text('Program Studi'),
                  subtitle: const Text('Teknik Komputer'),
                ),
                ListTile(
                  leading: Icon(Icons.code, color: scheme.primary),
                  title: const Text('Mata Kuliah'),
                  subtitle: const Text('Praktikum PPB 2026 - Tugas Akhir'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: scheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Tentang Aplikasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kulinerify adalah katalog kuliner di kawasan Tembalang, '
                    'Semarang. Pengguna bisa mencari tempat makan dan menu, '
                    'menyimpan favorit, serta membuka lokasi di Google Maps.',
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Fitur',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Login dan buat akun\n'
                    '• Daftar restoran dan menu dengan pencarian & filter\n'
                    '• Tambah, edit, dan hapus data restoran/menu\n'
                    '• Favorit yang tersimpan di perangkat\n'
                    '• Buka lokasi restoran di Google Maps',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Teknologi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Flutter • REST API (http) • SharedPreferences • url_launcher',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Versi 1.0.0',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
