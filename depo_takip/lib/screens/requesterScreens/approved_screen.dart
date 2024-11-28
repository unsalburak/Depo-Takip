import 'package:flutter/material.dart';
import 'package:depo_takip/data_base/database_helper.dart';
import 'package:depo_takip/model/tracing_model.dart';

class ApprovedScreen extends StatefulWidget {
  const ApprovedScreen({super.key});

  @override
  _ApprovedScreenState createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Tracing> _tracing = []; // Onaylı talepler listesi

  @override
  void initState() {
    super.initState();
    _loadtracing(); // Onaylı talepleri yükle
  }

  Future<void> _loadtracing() async {
    try {
      final tracing = await _dbHelper.getAlltracing();
      setState(() {
        _tracing = tracing.where((tracing) => tracing.approval).toList(); // Sadece onaylı talepler
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tracing: $e')),
      );
    }
  }

  void _showDetails(Tracing tracing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tracing ID: ${tracing.tracingId}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Job Number: ${tracing.jobNumber}'),
                Text('Row Number: ${tracing.rowNumber}'),
                Text('Material ID: ${tracing.materialId}'),
                Text('Material Number: ${tracing.materialNumber}'),
                Text('Material Name: ${tracing.materialName}'),
                Text('Order Amount: ${tracing.orderAmount}'),
                Text('Note: ${tracing.note}'),
                Text('Requester: ${tracing.requester}'),
                Text('Worker ID: ${tracing.workerId}'),
                Text('Date: ${tracing.date}'),
                Text('Approval: ${tracing.approval ? "Approved" : "Not Approved"}'),
                Text('Accepted: ${tracing.accepted ? "Accepted" : "Not Accepted"}'),
                Text('User ID: ${tracing.userId}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
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
        title: const Text('Approved Requests'),
      ),
      body: _tracing.isEmpty
          ? const Center(child: Text('No approved requests found.'))
          : ListView.builder(
              itemCount: _tracing.length,
              itemBuilder: (context, index) {
                final tracing = _tracing[index];
                return ListTile(
                  title: Text('Tracing ID: ${tracing.tracingId}'),
                  subtitle: Text(
                      'Material ID: ${tracing.materialId}, Material Name: ${tracing.materialName}, Order Amount: ${tracing.orderAmount}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _showDetails(tracing), // Detayları göster
                  ),
                );
              },
            ),
    );
  }
}
