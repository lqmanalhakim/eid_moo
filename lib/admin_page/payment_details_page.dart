import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PaymentDetailsPage extends StatelessWidget {
  final DocumentSnapshot payment;
  final CollectionReference cowsCollection = FirebaseFirestore.instance.collection('cows');

  PaymentDetailsPage({required this.payment});

  Future<void> _updateCowPartsStatus(bool approve) async {
    int partsRequested = payment['parts_requested'];

    if (approve) {
      QuerySnapshot cowsSnapshot = await cowsCollection.get();
      List<QueryDocumentSnapshot> cows = cowsSnapshot.docs;

      for (var cow in cows) {
        QuerySnapshot partsSnapshot = await cow.reference.collection('parts').where('status', isEqualTo: 'pending').limit(partsRequested).get();
        List<QueryDocumentSnapshot> pendingParts = partsSnapshot.docs;

        for (var part in pendingParts) {
          if (partsRequested > 0) {
            await part.reference.update({
              'status': 'not available',
            });
            partsRequested--;
          }
        }

        if (partsRequested <= 0) break;
      }
    } else {
      QuerySnapshot cowsSnapshot = await cowsCollection.get();
      List<QueryDocumentSnapshot> cows = cowsSnapshot.docs;

      for (var cow in cows) {
        QuerySnapshot partsSnapshot = await cow.reference.collection('parts').where('status', isEqualTo: 'pending').limit(partsRequested).get();
        List<QueryDocumentSnapshot> pendingParts = partsSnapshot.docs;

        for (var part in pendingParts) {
          if (partsRequested > 0) {
            await part.reference.update({
              'status': 'available',
            });
            partsRequested--;
          }
        }

        if (partsRequested <= 0) break;
      }
    }

    await payment.reference.update({
      'status': approve ? 'approved' : 'rejected',
    });

    // Notify the user (you may implement this as an email or an in-app notification)
    // This is just a placeholder for notification logic
    print('Notification sent to user: ${payment['name']}');
  }

  Future<void> _approvePayment() async {
    await _updateCowPartsStatus(true);
  }

  Future<void> _rejectPayment() async {
    await _updateCowPartsStatus(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Name: ${payment['name']}'),
            Text('Address: ${payment['address']}'),
            Text('Phone: ${payment['phone']}'),
            Text('Parts Requested: ${payment['parts_requested']}'),
            Text('Qurban Names: ${payment['qurban_names'].join(', ')}'),
            payment['receipt_url'] != null
                ? Column(
                    children: [
                      Text('Receipt:'),
                      ElevatedButton(
                        onPressed: () {
                          // You can use a package like url_launcher to open the URL in a web browser
                        },
                        child: Text('View Receipt'),
                      ),
                    ],
                  )
                : Container(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _approvePayment,
              child: Text('Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            ElevatedButton(
              onPressed: _rejectPayment,
              child: Text('Reject'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
