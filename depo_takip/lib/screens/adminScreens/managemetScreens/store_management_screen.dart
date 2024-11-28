import 'package:flutter/material.dart';
import 'package:depo_takip/model/store_model.dart';
import 'package:depo_takip/model/user_model.dart';
import 'package:depo_takip/data_base/database_helper.dart';

class StoreManagementPage extends StatefulWidget {
  const StoreManagementPage({super.key});

  @override
  _StoreManagementPageState createState() => _StoreManagementPageState();
}

class _StoreManagementPageState extends State<StoreManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Store> _stores = [];
  List<User> _users = [];
  late User _selectedUser; // Kullanıcı seçimi için nullable olmamalı

  final _storeFormKey = GlobalKey<FormState>();
  final TextEditingController _workerNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStores();
    _loadUsers();
  }

  Future<void> _loadStores() async {
    final stores = await _dbHelper.getAllStores();
    setState(() {
      _stores = stores;
    });
  }

  Future<void> _loadUsers() async {
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users.where((user) => user.userAuthority == 'istasyon').toList();
      if (_users.isNotEmpty) {
        _selectedUser = _users.first; // İlk kullanıcıyı varsayılan olarak seç
      } else {
        throw Exception('No users available'); // Kullanıcı yoksa hata fırlat
      }
    });
  }

  Future<int> _getNextWorkerId() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('SELECT MAX(worker_id) as maxId FROM store');
    final int maxId = result.isNotEmpty && result.first['maxId'] != null
        ? (result.first['maxId'] as int?) ?? 0
        : 0;
    return maxId + 1;
  }

  Future<void> _addStore() async {
    if (_storeFormKey.currentState!.validate()) {
      final newWorkerId = await _getNextWorkerId();
      final newStore = Store(
        workerId: newWorkerId,
        itemModelno: 0,
        workerName: _workerNameController.text,
        userId: _selectedUser.userId, // Seçilen userId
      );

      await _dbHelper.insertStore(newStore);
      _clearStoreFields();
      _loadStores();
    }
  }

  void _showUpdateDialog(Store store) {
    _workerNameController.text = store.workerName;
    _selectedUser = _users.firstWhere(
      (user) => user.userId == store.userId,
      orElse: () => _users.isNotEmpty ? _users.first : throw Exception('No users available'),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Store'),
          content: Form(
            key: _storeFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: store.workerId.toString(),
                  decoration: const InputDecoration(labelText: 'Worker ID'),
                  enabled: false,
                ),
                TextFormField(
                  controller: _workerNameController,
                  decoration: const InputDecoration(labelText: 'Worker Name'),
                  validator: (value) => value!.isEmpty ? 'Enter worker name' : null,
                ),
                DropdownButtonFormField<User>(
                  value: _selectedUser,
                  decoration: const InputDecoration(labelText: 'User'),
                  items: _users.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.username),
                    );
                  }).toList(),
                  onChanged: (User? newUser) {
                    setState(() {
                      _selectedUser = newUser!;
                    });
                  },
                  validator: (value) => value == null ? 'Select a user' : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_storeFormKey.currentState!.validate()) {
                  final updatedStore = Store(
                    workerId: store.workerId,
                    itemModelno: 0,
                    workerName: _workerNameController.text,
                    userId: _selectedUser.userId,
                  );
                  await _dbHelper.updateStore(updatedStore.workerId, updatedStore);
                  _clearStoreFields();
                  _loadStores();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteStore(int workerId) async {
    await _dbHelper.deleteStore(workerId);
    _loadStores();
  }

  void _clearStoreFields() {
    _workerNameController.clear();
    if (_users.isNotEmpty) {
      _selectedUser = _users.first; // Seçilen kullanıcıyı sıfırla
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _storeFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _workerNameController,
                      decoration: const InputDecoration(labelText: 'Worker Name'),
                      validator: (value) => value!.isEmpty ? 'Enter worker name' : null,
                    ),
                    DropdownButtonFormField<User>(
                      value: _selectedUser,
                      decoration: const InputDecoration(labelText: 'User'),
                      items: _users.map((user) {
                        return DropdownMenuItem<User>(
                          value: user,
                          child: Text(user.username),
                        );
                      }).toList(),
                      onChanged: (User? newUser) {
                        setState(() {
                          _selectedUser = newUser!;
                        });
                      },
                      validator: (value) => value == null ? 'Select a user' : null,
                    ),
                    ElevatedButton(
                      onPressed: _addStore,
                      child: const Text('Add Store'),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text('Stores'),
              children: _stores.map((store) {
                return ListTile(
                  title: Text(store.workerName),
                  subtitle: Text('User ID: ${store.userId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(store),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStore(store.workerId),
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
