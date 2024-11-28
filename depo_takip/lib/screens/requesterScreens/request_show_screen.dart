import 'package:flutter/material.dart';
import 'package:depo_takip/data_base/database_helper.dart';
import 'package:depo_takip/model/tracing_model.dart';

class RequestShowScreen extends StatefulWidget {
  final List<Tracing> tracing; // Önceki ekrandan gelen talepler

  const RequestShowScreen({super.key, required this.tracing});

  @override
  _RequestShowScreenState createState() => _RequestShowScreenState();
}

class _RequestShowScreenState extends State<RequestShowScreen> {
  List<Tracing> _filteredTracings = [];

  @override
  void initState() {
    super.initState();
    _filterTracings();
  }

  void _filterTracings() {
    setState(() {
      // Onaylanmamış talepleri filtrele
      _filteredTracings = widget.tracing.where((tracing) => !tracing.approval).toList();
    });
  }

  Future<void> _markAllAsApproved() async {
    if (_filteredTracings.isNotEmpty) {
      try {
        // Tüm talepleri approved olarak işaretleyin
        for (var tracing in _filteredTracings) {
          await DatabaseHelper().updateTracing(
            tracing.tracingId, // Tracing ID
            true, // approved olarak true
            tracing.accepted, // accepted değeri değişmeyecek
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All requests marked as approved.')),
        );

        // Listeyi güncelle
        _filterTracings(); // Filtreyi tekrar uygula ve onaylananları gizle
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update tracing: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No requests to mark as approved.')),
      );
    }
  }

  Future<void> _deleteTracing(Tracing tracing) async {
    try {
      await DatabaseHelper().deleteTracing(tracing.tracingId);
      setState(() {
        widget.tracing.remove(tracing);
        _filterTracings(); // Filtreyi tekrar uygula
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete request: $e')),
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
        title: const Text('Saved Requests'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTracings.length, // Sadece onaylanmamış talepler
              itemBuilder: (context, index) {
                final tracing = _filteredTracings[index];
                return ListTile(
                  title: Text('Tracing ID: ${tracing.tracingId}'),
                  subtitle: Text(
                      'Material ID: ${tracing.materialId}, Material Name: ${tracing.materialName}, Order Amount: ${tracing.orderAmount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Edit functionality can be implemented here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Edit functionality not implemented')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTracing(tracing),
                      ),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showDetails(tracing),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _markAllAsApproved,
              child: const Text('Talep et'),
            ),
          ),
        ],
      ),
    );
  }
}
