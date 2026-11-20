import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';

void main() {
  runApp(const KulinerifyApp());
}

class KulinerifyApp extends StatelessWidget {
  const KulinerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kulinerify',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
