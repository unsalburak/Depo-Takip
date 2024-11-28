import 'package:flutter/material.dart';
import 'package:depo_takip/data_base/database_helper.dart';
import 'package:depo_takip/model/tracing_model.dart';

class AcceptedShowScreen extends StatefulWidget {
  const AcceptedShowScreen({super.key});

  @override
  _AcceptedShowScreenState createState() => _AcceptedShowScreenState();
}

class _AcceptedShowScreenState extends State<AcceptedShowScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Tracing> _acceptedtracing = [];

  @override
  void initState() {
    super.initState();
    _loadAcceptedtracing();
  }

  Future<void> _loadAcceptedtracing() async {
    final tracing = await _dbHelper.getAlltracing();
    setState(() {
      _acceptedtracing = tracing.where((tracing) => tracing.accepted).toList(); // Accepted olan talepler
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accepted Requests'),
      ),
      body: _acceptedtracing.isEmpty
          ? const Center(child: Text('No accepted requests found.'))
          : ListView.builder(
              itemCount: _acceptedtracing.length,
              itemBuilder: (context, index) {
                final tracing = _acceptedtracing[index];
                return ListTile(
                  title: Text('Tracing ID: ${tracing.tracingId}'),
                  subtitle: Text(
                      'Material ID: ${tracing.materialId}, Material Name: ${tracing.materialName}, Order Amount: ${tracing.orderAmount}'),
                );
              },
            ),
    );
  }
}
