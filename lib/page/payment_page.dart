import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _partsController = TextEditingController();
  final TextEditingController _qurbanNameController = TextEditingController();

  File? _receiptFile;
  String? _terms = 'Terms and conditions: ';

  final CollectionReference cowsCollection = FirebaseFirestore.instance.collection('cows');
  final CollectionReference userPaymentsCollection = FirebaseFirestore.instance.collection('user_payments');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<String> _qurbanNames = [];

  Future<void> _submitPayment(BuildContext context) async {
    int partsRequested = int.tryParse(_partsController.text) ?? 0;

    QuerySnapshot cowsSnapshot = await cowsCollection.get();
    List<QueryDocumentSnapshot> cows = cowsSnapshot.docs;

    for (var cow in cows) {
      QuerySnapshot partsSnapshot = await cow.reference.collection('parts').where('status', isEqualTo: 'available').limit(partsRequested).get();
      List<QueryDocumentSnapshot> availableParts = partsSnapshot.docs;

      for (var part in availableParts) {
        if (partsRequested > 0) {
          await part.reference.update({
            'status': 'pending',
          });
          partsRequested--;
        }
      }

      if (partsRequested <= 0) break;
    }

    // Upload receipt file to Firebase Storage
    String? downloadUrl;
    if (_receiptFile != null) {
      Reference ref = _storage.ref().child('receipts/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(_receiptFile!);
      TaskSnapshot taskSnapshot = await uploadTask;
      downloadUrl = await taskSnapshot.ref.getDownloadURL();
    }

    // Add payment details to user_payments collection
    await userPaymentsCollection.add({
      'name': _nameController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'parts_requested': int.tryParse(_partsController.text) ?? 0,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'qurban_names': _qurbanNames,
      'receipt_url': downloadUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment submitted successfully!')));
    Navigator.pushReplacementNamed(context, '/profile');
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _receiptFile = File(result.files.single.path!);
      });
    }
  }

  void _addQurbanName() {
    if (_qurbanNameController.text.isNotEmpty) {
      setState(() {
        _qurbanNames.add(_qurbanNameController.text);
        _qurbanNameController.clear();
      });
    }
  }

  void _deleteQurbanName(int index) {
    setState(() {
      _qurbanNames.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextFormField(
              controller: _partsController,
              decoration: InputDecoration(labelText: 'Number of Parts'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _qurbanNameController,
              decoration: InputDecoration(labelText: 'Qurban Name 1'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _addQurbanName,
              child: Text('Add'),
            ),
            SizedBox(height: 16.0),
            _qurbanNames.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qurban Names:'),
                      SizedBox(height: 8.0),
                      Column(
                        children: _qurbanNames
                            .asMap()
                            .entries
                            .map((entry) => ListTile(
                                  title: Text(entry.value),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteQurbanName(entry.key),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Upload Receipt'),
            ),
            SizedBox(height: 16.0),
            Text(_terms ?? 'Loading terms...'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _submitPayment(context),
              child: Text('Submit Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
