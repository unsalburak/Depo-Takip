import 'package:depo_takip/screens/adminScreens/managemetScreens/item_management_screen.dart';
import 'package:depo_takip/screens/adminScreens/managemetScreens/station_managemen_screen.dart';
import 'package:depo_takip/screens/adminScreens/managemetScreens/store_management_screen.dart';
import 'package:depo_takip/screens/adminScreens/managemetScreens/user_management_screen.dart';
import 'package:flutter/material.dart';

class DatabaseManagerPage extends StatefulWidget {
  const DatabaseManagerPage({super.key});

  @override
  _DatabaseManagerPageState createState() => _DatabaseManagerPageState();
}

class _DatabaseManagerPageState extends State<DatabaseManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Manager'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // User Management Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60), // Buton boyutlarını ayarlayın
                    textStyle: const TextStyle(fontSize: 18), // Yazı boyutunu ayarlayın
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  },
                  child: const Text('User Management'),
                ),
              ),
              // Item Management Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60), // Buton boyutlarını ayarlayın
                    textStyle: const TextStyle(fontSize: 18), // Yazı boyutunu ayarlayın
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ItemManagementPage(),
                      ),
                    );
                  },
                  child: const Text('Item Management'),
                ),
              ),
              // Store Management Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60), // Buton boyutlarını ayarlayın
                    textStyle: const TextStyle(fontSize: 18), // Yazı boyutunu ayarlayın
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoreManagementPage(),
                      ),
                    );
                  },
                  child: const Text('Store Management'),
                ),
              ),
              // Station Management Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 60), // Buton boyutlarını ayarlayın
                    textStyle: const TextStyle(fontSize: 18), // Yazı boyutunu ayarlayın
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StationManagementPage(),
                      ),
                    );
                  },
                  child: const Text('Station Management'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
