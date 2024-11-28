import 'package:flutter/material.dart';
import 'package:depo_takip/model/user_model.dart';
import 'package:depo_takip/model/station_model.dart';
import 'package:depo_takip/data_base/database_helper.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];
  List<Station> _stations = [];
  Station? _selectedStation;

  final _userFormKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _userAuthorityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadStations();
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  Future<void> _loadStations() async {
    final stations = await _dbHelper.getAllStations();
    setState(() {
      _stations = stations;
    });
  }

  Future<void> _addUser() async {
    if (_userFormKey.currentState!.validate() && _selectedStation != null) {
      final newUser = User(
        userId: null,
        username: _usernameController.text,
        password: _passwordController.text,
        userAuthority: _userAuthorityController.text,
        stationId: _selectedStation!.stationId,
      );
      await _dbHelper.insertUser(newUser);
      _clearUserFields();
      _loadUsers();
    }
  }

  Future<void> _updateUser(int userId) async {
    if (_userFormKey.currentState!.validate() && _selectedStation != null) {
      final updatedUser = User(
        userId: userId,
        username: _usernameController.text,
        password: _passwordController.text,
        userAuthority: _userAuthorityController.text,
        stationId: _selectedStation!.stationId,
      );
      await _dbHelper.updateUser(userId, updatedUser);
      _clearUserFields();
      _loadUsers();
    }
  }

  Future<void> _deleteUser(int userId) async {
    await _dbHelper.deleteUser(userId);
    _loadUsers();
  }

  void _clearUserFields() {
    _usernameController.clear();
    _passwordController.clear();
    _userAuthorityController.clear();
    _selectedStation = null;
  }

  void _showUpdateDialog(User user) {
    _usernameController.text = user.username;
    _passwordController.text = user.password;
    _userAuthorityController.text = user.userAuthority;
    _selectedStation = _stations.firstWhere((station) => station.stationId == user.stationId,);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: SingleChildScrollView(
            child: Form(
              key: _userFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value!.isEmpty ? 'Enter username' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Enter password' : null,
                  ),
                  TextFormField(
                    controller: _userAuthorityController,
                    decoration: const InputDecoration(labelText: 'User Authority'),
                    validator: (value) => value!.isEmpty ? 'Enter user authority' : null,
                  ),
                  DropdownButtonFormField<Station>(
                    value: _selectedStation,
                    decoration: const InputDecoration(labelText: 'Station'),
                    items: _stations.map((station) {
                      return DropdownMenuItem<Station>(
                        value: station,
                        child: Text(station.stationName),
                      );
                    }).toList(),
                    onChanged: (Station? newStation) {
                      setState(() {
                        _selectedStation = newStation;
                      });
                    },
                    validator: (value) => value == null ? 'Select a station' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
                _clearUserFields();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                if (_userFormKey.currentState!.validate()) {
                  await _updateUser(user.userId!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _userFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) => value!.isEmpty ? 'Enter username' : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Enter password' : null,
                    ),
                    TextFormField(
                      controller: _userAuthorityController,
                      decoration: const InputDecoration(labelText: 'User Authority'),
                      validator: (value) => value!.isEmpty ? 'Enter user authority' : null,
                    ),
                    DropdownButtonFormField<Station>(
                      value: _selectedStation,
                      decoration: const InputDecoration(labelText: 'Station'),
                      items: _stations.map((station) {
                        return DropdownMenuItem<Station>(
                          value: station,
                          child: Text(station.stationName),
                        );
                      }).toList(),
                      onChanged: (Station? newStation) {
                        setState(() {
                          _selectedStation = newStation;
                        });
                      },
                      validator: (value) => value == null ? 'Select a station' : null,
                    ),
                    ElevatedButton(
                      onPressed: _addUser,
                      child: const Text('Add User'),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text('Users'),
              children: _users.map((user) {
                return ListTile(
                  title: Text(user.username),
                  subtitle: Text('Authority: ${user.userAuthority}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _showUpdateDialog(user);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(user.userId!),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
