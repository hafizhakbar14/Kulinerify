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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Restoran',
          ),
          NavigationDestination(
            icon: Icon(Icons.fastfood_outlined),
            selectedIcon: Icon(Icons.fastfood),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
