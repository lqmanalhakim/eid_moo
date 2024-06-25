import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsPage extends StatelessWidget {
  final CollectionReference cowsCollection = FirebaseFirestore.instance.collection('cows');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.details),
              title: Text('Details Page'),
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment Page'),
              onTap: () {
                Navigator.pushNamed(context, '/payment');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile Page'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text('Admin Page'),
              onTap: () {
                Navigator.pushNamed(context, '/admin');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cowsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final cows = snapshot.data!.docs;
          print('Fetched ${cows.length} cows');
          return ListView.builder(
            itemCount: cows.length,
            itemBuilder: (context, index) {
              var cow = cows[index];
              print('Cow ${index + 1}: ${cow.id}');
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text('Cow ${index + 1}'),
                  subtitle: StreamBuilder<QuerySnapshot>(
                    stream: cow.reference.collection('parts').orderBy('name').snapshots(),
                    builder: (context, partSnapshot) {
                      if (partSnapshot.hasError) {
                        print('Error: ${partSnapshot.error}');
                        return Text('Error: ${partSnapshot.error}');
                      }
                      if (partSnapshot.connectionState == ConnectionState.waiting) {
                        return Text('Loading...');
                      }
                      final parts = partSnapshot.data!.docs;
                      print('Fetched ${parts.length} parts for Cow ${index + 1}');
                      if (parts.isEmpty) {
                        return Text('No parts available');
                      }
                      // Sort parts by name (assuming part names are consistent and sortable)
                      parts.sort((a, b) => a['name'].compareTo(b['name']));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: parts.map((part) {
                          print('Part ${part['name']}: ${part['status']}');
                          return Text(
                            '${part['name']}: ${part['status']}',
                            style: TextStyle(
                              color: part['status'] == 'available'
                                  ? Colors.green
                                  : part['status'] == 'not available'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
