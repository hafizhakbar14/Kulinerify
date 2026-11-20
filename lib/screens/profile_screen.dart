import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile / About')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hafizh Muhammad Akbar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'NIM: 21120124130098',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.school, color: Colors.deepOrange),
              title: Text('Program Studi'),
              subtitle: Text('Teknik Komputer'),
            ),
            const ListTile(
              leading: Icon(Icons.code, color: Colors.deepOrange),
              title: Text('Mata Kuliah'),
              subtitle: Text('Praktikum PPB 2026 - Tugas Akhir'),
            ),
          ],
        ),
      ),
    );
  }
}
