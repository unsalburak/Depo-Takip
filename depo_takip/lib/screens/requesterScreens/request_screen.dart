import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:depo_takip/data_base/database_helper.dart';
import 'package:depo_takip/model/tracing_model.dart';
import 'package:depo_takip/screens/requesterScreens/request_show_screen.dart';
import 'package:depo_takip/screens/requesterScreens/approved_screen.dart'; // ApprovedScreen için import

class RequestScreen extends StatefulWidget {
  final String loggedInUsername; // Login ekranından gelen username

  const RequestScreen({super.key, required this.loggedInUsername});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final _formKey = GlobalKey<FormState>();

  // Kontrolcüler
  final TextEditingController _tracingIdController = TextEditingController();
 // final TextEditingController _rowNumberController = TextEditingController();
  final TextEditingController _materialIdController = TextEditingController();
  final TextEditingController _materialNumberController = TextEditingController();
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _orderAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _requesterController = TextEditingController();
  final TextEditingController _workerIdController = TextEditingController();
  final TextEditingController _workerNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();

  int _rowNumber = 1; // Row number kontrolü
  final bool _isApproved = false; // Approval kontrolü

  @override
  void initState() {
    super.initState();
    _initializeDate();
    _initializeTracingId();
    _loadUserDetails();
  }

  void _initializeDate() {
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> _initializeTracingId() async {
    final lastTracingId = await _getLastTracingId();
    _tracingIdController.text = (lastTracingId + 1).toString();
  }

  Future<int> _getLastTracingId() async {
    // Veritabanından son tracingId değerini getirin
    final lastTracingId = await DatabaseHelper().getLastTracingId();
    return lastTracingId ?? 0; // Veritabanından gelen değer yoksa 0 döner
  }

  void _loadUserDetails() async {
    final username = widget.loggedInUsername;
    final user = await DatabaseHelper().getUserByUsername(username);

    if (user != null) {
      _userIdController.text = user.userId.toString();
      _requesterController.text = username;

      // Store modelinde giriş yapan kullanıcının username'ine göre worker bilgilerini al
      final store = await DatabaseHelper().getStoreByUsername(username);

      if (store != null) {
        _workerIdController.text = store.workerId.toString();
        _workerNameController.text = store.workerName;
      } else {
        _workerIdController.text = 'Worker not found';
        _workerNameController.text = '';
      }
    } else {
      _userIdController.text = 'User not found';
      _requesterController.text = '';
      _workerIdController.text = 'Worker not found';
      _workerNameController.text = '';
    }
  }

  // Material ID değiştiğinde Item modelindeki itemName otomatik olarak getirilecek
  void _fetchMaterialName(int materialId) async {
    try {
      final item = await DatabaseHelper().getItemByModelNo(materialId);

      if (item != null) {
        setState(() {
          _materialNameController.text = item.itemName;
        });
      } else {
        setState(() {
          _materialNameController.text = 'Item not found';
        });
      }
    } catch (e) {
      setState(() {
        _materialNameController.text = 'Error fetching item';
      });
      // Hata durumunda kullanıcıyı bilgilendirin
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _navigateToRequestShowScreen() async {
    // Fetch saved tracing from the database
    final tracing = await DatabaseHelper().getAlltracing(); // or a method to get saved tracing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestShowScreen(tracing: tracing), // Pass saved tracing
      ),
    );
  }

  // Onaylı Taleplerim sayfasına yönlendirme
  void _navigateToApprovedScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ApprovedScreen(), // ApprovedScreen sayfasına yönlendirme
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_tracingIdController, 'Tracing ID', 'Enter tracing ID', readOnly: true),
              _buildTextField(_tracingIdController, 'Job Number', 'Enter tracing ID', readOnly: true),
              TextField(
                controller: TextEditingController(text: _rowNumber.toString()),
                readOnly: true, // Kullanıcı düzenleyemez
                decoration: const InputDecoration(labelText: 'Row Number'),
              ),
              _buildTextField(
                _materialIdController,
                'Material ID',
                'Enter material ID',
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _fetchMaterialName(int.parse(value));
                  }
                },
              ),
              _buildTextField(_materialNumberController, 'Material Number', 'Enter material number'),
              _buildTextField(_materialNameController, 'Material Name', 'Material name', readOnly: true),
              _buildTextField(_orderAmountController, 'Order Amount', 'Enter order amount'),
              _buildTextField(_noteController, 'Note', 'Enter note'),
              _buildTextField(_requesterController, 'Requester', 'Requester', readOnly: true),
              _buildTextField(_workerIdController, 'Worker ID', 'Worker ID', readOnly: true),
              _buildTextField(_workerNameController, 'Worker Name', 'Worker Name', readOnly: true),
              _buildDateField(_dateController, 'Date', 'Select date'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSubmit,
                child: const Text('Ekle'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToRequestShowScreen,
                child: const Text('Taleplerim'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _navigateToApprovedScreen, // Onaylı Taleplerim sayfasına yönlendirme
                child: const Text('Onaylı Taleplerim'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {bool readOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        readOnly: readOnly,
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.datetime,
        readOnly: true,
        onTap: () async {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (selectedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a date';
          }
          return null;
        },
      ),
    );
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final tracing = Tracing(
          tracingId: int.parse(_tracingIdController.text),
          jobNumber: int.parse(_tracingIdController.text), // Job Number, Tracing ID ile aynı
          rowNumber: _rowNumber, // Row Number, kullanıcı tarafından değil, otomatik artırılacak
          materialId: int.parse(_materialIdController.text),
          materialNumber: int.parse(_materialNumberController.text),
          materialName: _materialNameController.text,
          orderAmount: int.parse(_orderAmountController.text),
          note: _noteController.text,
          requester: _requesterController.text,
          workerId: int.parse(_workerIdController.text),
          date: _dateController.text,
          approval: _isApproved,
          accepted: false, // accepted değeri false olarak ayarlanıyor
          userId: int.parse(_userIdController.text),
        );

        await _saveTracing(tracing);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Saved')),
        );

        // Row number'ı artır
        setState(() {
          _rowNumber += 1;
        });

        // Formu sıfırla
        _formKey.currentState?.reset();

        // Tracing ID'yi yeniden başlat
        _initializeTracingId();

      } catch (e) {
        // Hata durumunda kullanıcıyı bilgilendirin
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveTracing(Tracing tracing) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertTracing(tracing);
  }
}
