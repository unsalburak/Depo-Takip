import 'package:depo_takip/data_base/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:depo_takip/model/user_model.dart';
import 'package:depo_takip/model/station_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? selectedStation;
  String? selectedUser;
  String password = '';
  List<Station> stations = [];
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  Future<void> loadStations() async {
    final dbHelper = DatabaseHelper();
    final List<Station> stationList = await dbHelper.getAllStations();
    setState(() {
      stations = stationList;
    });
  }

  Future<void> loadUsers(int stationId) async {
    final dbHelper = DatabaseHelper();
    final List<User> userList = await dbHelper.getAllUsers();
    setState(() {
      users = userList.where((user) => user.stationId == stationId).toList();
    });
  }

  void handleLogin() {
    final selectedUserObj = users.firstWhere((user) => user.username == selectedUser);

    if (selectedUserObj.password == password) {
      if (selectedUserObj.userAuthority == 'admin') {
        Navigator.pushNamed(context, '/DatabaseManagerPage');
      } else if (selectedUserObj.userAuthority == 'istasyon') {
        Navigator.pushNamed(
          context,
          '/RequestScreen',
          arguments: selectedUserObj.username, // Kullanıcının adını gönderiyoruz
        );
      } else if (selectedUserObj.userAuthority == 'depo') {
        // "depo" yetkisine sahip kullanıcı SupplyScreen ekranına yönlendirilecek
        Navigator.pushNamed(context, '/SupplyScreen', arguments: selectedUserObj.username);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedStation,
              hint: const Text('Select Station'),
              items: stations.map((station) {
                return DropdownMenuItem(
                  value: station.stationName,
                  child: Text(station.stationName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStation = value;
                  final selectedStationObj = stations.firstWhere((station) => station.stationName == value);
                  loadUsers(selectedStationObj.stationId);
                  selectedUser = null; // İstasyon değiştiğinde kullanıcı sıfırlanıyor
                });
              },
            ),
            if (selectedStation != null)
              DropdownButton<String>(
                value: selectedUser,
                hint: const Text('Select User'),
                items: users.map((user) {
                  return DropdownMenuItem(
                    value: user.username,
                    child: Text(user.username),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUser = value;
                  });
                },
              ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
