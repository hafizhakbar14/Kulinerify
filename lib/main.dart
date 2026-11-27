import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';

void main() {
  runApp(const KulinerifyApp());
}

/// Mengizinkan drag dengan mouse/trackpad (default desktop tidak mengizinkan).
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class KulinerifyApp extends StatelessWidget {
  const KulinerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kulinerify',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(), // <-- baris baru
      theme: ThemeData(
        // ... tema Material 3 yang sudah ada, tidak berubah
      ),
      home: const MainNavigation(),
    );
  }
}
