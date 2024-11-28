import 'package:flutter/material.dart';
import 'package:depo_takip/model/item_model.dart';
import 'package:depo_takip/data_base/database_helper.dart';

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  _ItemManagementPageState createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> _items = [];

  final _itemFormKey = GlobalKey<FormState>();
  // itemIdController'ı kaldırıyoruz
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _stockQuantityController = TextEditingController();
  final TextEditingController _shelfNumberController = TextEditingController();
  final TextEditingController _itemModelnoController = TextEditingController(); // Yeni controller

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _dbHelper.getAllItems();
    setState(() {
      _items = items;
    });
  }

  Future<void> _addItem() async {
    if (_itemFormKey.currentState!.validate()) {
      final newItem = Item(
        itemId: 0, // itemId'yi null bırakıyoruz, veritabanı otomatik atayacak
        itemName: _itemNameController.text,
        stockQuantity: int.parse(_stockQuantityController.text),
        shelfNumber: int.parse(_shelfNumberController.text),
        itemModelno: int.parse(_itemModelnoController.text), // Yeni alan
      );
      await _dbHelper.insertItem(newItem);
      _clearItemFields();
      _loadItems();
    }
  }

  void _showUpdateDialog(Item item) {
    _itemNameController.text = item.itemName;
    _stockQuantityController.text = item.stockQuantity.toString();
    _shelfNumberController.text = item.shelfNumber.toString();
    _itemModelnoController.text = item.itemModelno.toString(); // Yeni alan

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Item'),
          content: Form(
            key: _itemFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // itemId alanını kaldırıyoruz
                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) => value!.isEmpty ? 'Enter item name' : null,
                ),
                TextFormField(
                  controller: _stockQuantityController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter stock quantity' : null,
                ),
                TextFormField(
                  controller: _shelfNumberController,
                  decoration: const InputDecoration(labelText: 'Shelf Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter shelf number' : null,
                ),
                TextFormField(
                  controller: _itemModelnoController, // Yeni alan
                  decoration: const InputDecoration(labelText: 'Item Model Number'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter item model number' : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_itemFormKey.currentState!.validate()) {
                  final updatedItem = Item(
                    itemId: item.itemId, // Mevcut itemId'yi kullanıyoruz
                    itemName: _itemNameController.text,
                    stockQuantity: int.parse(_stockQuantityController.text),
                    shelfNumber: int.parse(_shelfNumberController.text),
                    itemModelno: int.parse(_itemModelnoController.text), // Yeni alan
                  );
                  await _dbHelper.updateItem(updatedItem.itemId, updatedItem);
                  _clearItemFields();
                  _loadItems();
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

  Future<void> _deleteItem(int itemId) async {
    await _dbHelper.deleteItem(itemId);
    _loadItems();
  }

  void _clearItemFields() {
    // itemIdController'ı kaldırıyoruz
    _itemNameController.clear();
    _stockQuantityController.clear();
    _shelfNumberController.clear();
    _itemModelnoController.clear(); // Yeni alanı temizle
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _itemFormKey,
                child: Column(
                  children: [
                    // itemId alanını kaldırıyoruz
                    TextFormField(
                      controller: _itemNameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (value) => value!.isEmpty ? 'Enter item name' : null,
                    ),
                    TextFormField(
                      controller: _stockQuantityController,
                      decoration: const InputDecoration(labelText: 'Stock Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter stock quantity' : null,
                    ),
                    TextFormField(
                      controller: _shelfNumberController,
                      decoration: const InputDecoration(labelText: 'Shelf Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter shelf number' : null,
                    ),
                    TextFormField(
                      controller: _itemModelnoController, // Yeni alan
                      decoration: const InputDecoration(labelText: 'Item Model Number'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter item model number' : null,
                    ),
                    ElevatedButton(
                      onPressed: _addItem,
                      child: const Text('Add Item'),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text('Items'),
              children: _items.map((item) {
                return ListTile(
                  title: Text(item.itemName),
                  subtitle: Text(
                    'Item ID: ${item.itemId}\n'
                    'Stock: ${item.stockQuantity}, Shelf: ${item.shelfNumber}\n'
                    'Model Number: ${item.itemModelno}', // Yeni alan
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(item.itemId),
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
