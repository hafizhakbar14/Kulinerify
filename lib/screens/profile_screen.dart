import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile / About')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: scheme.primary,
              child: Icon(Icons.person, size: 60, color: scheme.onPrimary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hafizh Muhammad Akbar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            'NIM: 21120124130098',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          const Divider(),
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
