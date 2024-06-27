
import 'package:eid_moo/admin_page/admin_page.dart';
import 'package:eid_moo/login_page/admin_login.dart';
import 'package:eid_moo/page/details_page.dart';
import 'package:eid_moo/page/payment_page.dart';
import 'package:eid_moo/page/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eidmoo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: DetailsPage(),
      routes: {
        '/payment': (context) => PaymentPage(),
        '/profile': (context) => ProfilePage(),
        '/admin': (context) => AdminPage(),
        '/adminLogin': (context) => AdminLoginPage(),
      }
    );
  }
}
