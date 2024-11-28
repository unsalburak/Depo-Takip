import 'package:flutter/material.dart';
import 'package:depo_takip/screens/adminScreens/database_manager.dart'; // Güncel yol ve dosya adı
import 'package:depo_takip/screens/login_screen.dart'; // Güncel yol ve dosya adı
import 'package:depo_takip/screens/requesterScreens/request_screen.dart'; // Güncel yol ve dosya adı
import 'package:depo_takip/screens/supplierScreens/supply_screen.dart'; // SupplyScreen için güncel yol

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depo Takip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Uygulama başladığında ilk gösterilecek sayfa
      routes: {
        '/login': (context) => const LoginPage(),
        '/DatabaseManagerPage': (context) => const DatabaseManagerPage(),
        // RequestScreen'e parametre geçmek için bir fonksiyon kullanıyoruz
        '/RequestScreen': (context) => RequestScreen(
          loggedInUsername: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/SupplyScreen': (context) => const SupplyScreen(), // SupplyScreen eklenmeli
      },
    );
  }
}
