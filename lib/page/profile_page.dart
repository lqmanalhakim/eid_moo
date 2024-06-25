import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final CollectionReference userPaymentsCollection = FirebaseFirestore.instance.collection('user_payments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userPaymentsCollection.snapshots(),
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
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Payment ${index + 1}'),
                  subtitle: Text('Status: ${payment['status']}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
