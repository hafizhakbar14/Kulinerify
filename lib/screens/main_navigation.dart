import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'restaurant_screen.dart';
import 'menu_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Daftar 5 Halaman Utama (Memenuhi syarat minimal 5 halaman & Bottom Nav Bar)
  final List<Widget> _pages = [
    const HomeScreen(), // Tab 1: Beranda
    const RestaurantScreen(), // Tab 2: List Utama Restoran
    const MenuScreen(), // Tab 3: List Utama Menu Makanan
    const FavoriteScreen(), // Tab 4: Halaman Pendukung (Favorit)
    const ProfileScreen(), // Tab 5: Profile / About Pengembang
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restoran',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
