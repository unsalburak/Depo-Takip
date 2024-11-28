import 'package:flutter/material.dart';
import 'package:depo_takip/model/station_model.dart';
import 'package:depo_takip/data_base/database_helper.dart';

class StationManagementPage extends StatefulWidget {
  const StationManagementPage({super.key});

  @override
  _StationManagementPageState createState() => _StationManagementPageState();
}

class _StationManagementPageState extends State<StationManagementPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Station> _stations = [];

  final _stationFormKey = GlobalKey<FormState>();
  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _stationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    final stations = await _dbHelper.getAllStations();
    setState(() {
      _stations = stations;
    });
  }

  Future<void> _addStation() async {
    if (_stationFormKey.currentState!.validate()) {
      final newStation = Station(
        stationId: int.parse(_stationIdController.text),
        stationName: _stationNameController.text,
      );
      await _dbHelper.insertStation(newStation);
      _clearStationFields();
      _loadStations();
    }
  }

  void _showUpdateDialog(Station station) {
    _stationIdController.text = station.stationId.toString();
    _stationNameController.text = station.stationName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Station'),
          content: Form(
            key: _stationFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _stationIdController,
                  decoration: const InputDecoration(labelText: 'Station ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Enter station ID' : null,
                ),
                TextFormField(
                  controller: _stationNameController,
                  decoration: const InputDecoration(labelText: 'Station Name'),
                  validator: (value) => value!.isEmpty ? 'Enter station name' : null,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_stationFormKey.currentState!.validate()) {
                  final updatedStation = Station(
                    stationId: int.parse(_stationIdController.text),
                    stationName: _stationNameController.text,
                  );
                  await _dbHelper.updateStation(updatedStation.stationId, updatedStation);
                  _clearStationFields();
                  _loadStations();
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

  Future<void> _deleteStation(int stationId) async {
    await _dbHelper.deleteStation(stationId);
    _loadStations();
  }

  void _clearStationFields() {
    _stationIdController.clear();
    _stationNameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Station Management'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _stationFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _stationIdController,
                      decoration: const InputDecoration(labelText: 'Station ID'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter station ID' : null,
                    ),
                    TextFormField(
                      controller: _stationNameController,
                      decoration: const InputDecoration(labelText: 'Station Name'),
                      validator: (value) => value!.isEmpty ? 'Enter station name' : null,
                    ),
                    ElevatedButton(
                      onPressed: _addStation,
                      child: const Text('Add Station'),
                    ),
                  ],
                ),
              ),
            ),
            ExpansionTile(
              title: const Text('Stations'),
              children: _stations.map((station) {
                return ListTile(
                  title: Text(station.stationName),
                  subtitle: Text('Station ID: ${station.stationId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUpdateDialog(station),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStation(station.stationId),
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
