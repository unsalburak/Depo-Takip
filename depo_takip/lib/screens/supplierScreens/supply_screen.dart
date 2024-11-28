import 'package:flutter/material.dart';
import 'package:depo_takip/data_base/database_helper.dart';
import 'package:depo_takip/model/tracing_model.dart';

class SupplyScreen extends StatefulWidget {
  const SupplyScreen({super.key});

  @override
  _SupplyScreenState createState() => _SupplyScreenState();
}

class _SupplyScreenState extends State<SupplyScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Tracing> _approvedTracings = []; // Onaylı ve kabul edilmemiş talepler

  @override
  void initState() {
    super.initState();
    _loadApprovedTracings(); // Onaylı ve kabul edilmemiş talepleri yükle
  }

  Future<void> _loadApprovedTracings() async {
    try {
      final tracingList = await _dbHelper.getAlltracing(); // Tüm talepleri al
      setState(() {
        _approvedTracings = tracingList
            .where((tracing) => tracing.approval && !tracing.accepted)
            .toList(); // Onaylı ve kabul edilmemiş talepleri filtrele
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load tracings: $e')),
      );
    }
  }

  Future<void> _acceptTracing(Tracing tracing) async {
    try {
      final updatedTracing = tracing.copyWith(accepted: true); // accepted'ı true yap
      await _dbHelper.updateTracing(
          updatedTracing.tracingId, updatedTracing.approval, updatedTracing.accepted); // Veritabanında güncelle
      _loadApprovedTracings(); // Listeyi güncelle
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept tracing: $e')),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filtreleme işlevi eklenebilir, şu an için sadece buton
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Filtreyi temizleme işlevi eklenebilir, şu an için sadece buton.
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _approvedTracings.isEmpty
                ? const Center(child: Text('No approved requests found.'))
                : ListView.builder(
                    itemCount: _approvedTracings.length,
                    itemBuilder: (context, index) {
                      final tracing = _approvedTracings[index];
                      return ListTile(
                        title: Text('Tracing ID: ${tracing.tracingId}'),
                        subtitle: Text(
                            'Material ID: ${tracing.materialId}, Material Name: ${tracing.materialName}, Order Amount: ${tracing.orderAmount}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () => _showDetails(tracing),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check),
                              color: tracing.accepted ? Colors.green : Colors.grey,
                              onPressed: () {
                                if (!tracing.accepted) {
                                  _acceptTracing(tracing);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Onaylananlar Butonu
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/AcceptedShowScreen'); // AcceptedShowScreen'e yönlendirme
              },
              child: const Text('Onaylananlar'),
            ),
          ),
        ],
      ),
    );
  }
}
