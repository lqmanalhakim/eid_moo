import 'package:eid_moo/admin_page/payment_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatelessWidget {
  final CollectionReference userPaymentsCollection = FirebaseFirestore.instance.collection('user_payments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userPaymentsCollection.where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final payments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              var payment = payments[index];
              return ListTile(
                title: Text(payment['name']),
                subtitle: Text('Parts Requested: ${payment['parts_requested']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailsPage(payment: payment),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
