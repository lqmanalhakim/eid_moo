import 'package:eid_moo/login_page/admin_login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'payment_details_page.dart';


class AdminPage extends StatelessWidget {
  final CollectionReference userPaymentsCollection = FirebaseFirestore.instance.collection('user_payments');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> _sendNotification(String token, String title, String body) async {
    try {
      await _firebaseMessaging.sendMessage(
        to: token,
        data: {
          'title': title,
          'body': body,
        },
      );
    } catch (e) {
      print("Error sending notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminLoginPage()),
            );
          });
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Admin Page'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminLoginPage()),
                  );
                },
              ),
            ],
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
      },
    );
  }
}
