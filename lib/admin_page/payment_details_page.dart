import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentDetailsPage extends StatelessWidget {
  final DocumentSnapshot payment;
  final CollectionReference cowsCollection = FirebaseFirestore.instance.collection('cows');
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  
  PaymentDetailsPage({required this.payment});

  Future<void> _updateCowPartsStatus(bool approve, BuildContext context) async {
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

    // Close the payment details page and return to the admin page
    Navigator.pop(context);
  }

  Future<void> _approvePayment(BuildContext context) async {
    await _updateCowPartsStatus(true, context);
  }

  Future<void> _rejectPayment(BuildContext context) async {
    await _updateCowPartsStatus(false, context);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
            Text('Email: ${payment['email']}'),
            Text('Parts Requested: ${payment['parts_requested']}'),
            Text('Qurban Names: ${payment['qurban_names'].join(', ')}'),
            payment['receipt_url'] != null
                ? Column(
                    children: [
                      Text('Receipt:'),
                      ElevatedButton(
                        onPressed: () => _launchURL(payment['receipt_url']),
                        child: Text('View Receipt'),
                      ),
                    ],
                  )
                : Container(),
            RoundedLoadingButton(
              controller: _btnController,
              onPressed: () => _approvePayment(context),
              child: Text('Approve', style: TextStyle(color: Colors.white)),
              color: Colors.green,
              successColor: Colors.green,
            ),
            RoundedLoadingButton(
              controller: _btnController,
              onPressed: () => _rejectPayment(context),
              child: Text('Reject', style: TextStyle(color: Colors.white)),
              color: Colors.red,
              successColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
