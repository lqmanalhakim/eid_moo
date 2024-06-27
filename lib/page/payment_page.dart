import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

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
  final TextEditingController _emailController = TextEditingController();

  File? _receiptFile;
  String? _receiptUrl;
  bool _loading = false;

  final CollectionReference cowsCollection = FirebaseFirestore.instance.collection('cows');
  final CollectionReference userPaymentsCollection = FirebaseFirestore.instance.collection('user_payments');
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  List<String> _qurbanNames = [];

  Future<void> _submitPayment(BuildContext context) async {
    int partsRequested = int.tryParse(_partsController.text) ?? 0;

    QuerySnapshot cowsSnapshot = await cowsCollection.get();
    List<QueryDocumentSnapshot> cows = cowsSnapshot.docs;

    int availablePartsCount = 0;
    for (var cow in cows) {
      QuerySnapshot partsSnapshot = await cow.reference.collection('parts').where('status', isEqualTo: 'available').get();
      availablePartsCount += partsSnapshot.docs.length;
    }

    if (availablePartsCount < partsRequested) {
      _showNoPartsLeftDialog(context);
      return;
    }

    setState(() {
      _loading = true;
    });

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
      'email': _emailController.text,
      'parts_requested': int.tryParse(_partsController.text) ?? 0,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
      'qurban_names': _qurbanNames,
      'receipt_url': downloadUrl,
    });

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment submitted successfully!')));
    Navigator.pushReplacementNamed(context, '/profile');
  }

  Future<String?> _uploadFile(File file) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child('receipts/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null;
    }
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

  void _showNoPartsLeftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No more parts left'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('All parts are either not available or pending.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

   void _showLafazAkadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lafaz Akad'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('I hereby perform the Sunnah sacrifice for the sake of Allah the Exalted.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '1. Division of Qurban Meat:\n'
                  '- The meat from the Qurban will be divided into three equal parts:\n'
                  '  - 1/3 will be given to the user (the person who offered the Qurban).\n'
                  '  - 1/3 will be allocated to the mosque committee.\n'
                  '  - 1/3 will be distributed to the needy (fakir miskin).\n\n'
                  '2. Cancellation Policy:\n'
                  '- If the user decides to cancel the Qurban after making the payment, they will be responsible for covering the costs related to the transport and the well-being of the cow. These costs are non-refundable.\n',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
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
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _partsController,
              decoration: InputDecoration(labelText: 'Number of Parts'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _qurbanNameController,
              decoration: InputDecoration(labelText: 'Qurban Name :'),
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
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              onPressed: () => _showLafazAkadDialog(context),
              child: Text('Lafaz Akad'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green,
              ),
              onPressed: () => _showTermsAndConditionsDialog(context),
              child: Text('Terms and Conditions'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text('Upload Receipt'),
            ),
            SizedBox(height: 16.0),
            Image.asset('assets/hargalembu.png'),
            _receiptUrl != null
                ? Column(
                    children: [
                      SizedBox(height: 16.0),
                      Text('Receipt:'),
                      ElevatedButton(
                        onPressed: () {
                          // Use URL launcher or navigate to a web view to display the PDF
                        },
                        child: Text('View Receipt'),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            RoundedLoadingButton(
              controller: _btnController,
              onPressed: () => _submitPayment(context),
              child: Text('Submit Payment', style: TextStyle(color: Colors.white)),
              color: Colors.red,
              successColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
