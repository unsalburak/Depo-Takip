import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/database_manager');
              },
              child: const Text('Go to Database Manager'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin_request_screen');
              },
              child: const Text('Go to Admin Request Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/admin_supply_screen');
              },
              child: const Text('Go to Admin Supply Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
