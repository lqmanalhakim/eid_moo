import 'package:flutter/material.dart';

class MakeBookingScreen extends StatefulWidget {
  const MakeBookingScreen({super.key});

  @override
  State<MakeBookingScreen> createState() => _MakeBookingScreenState();
}

class _MakeBookingScreenState extends State<MakeBookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Booking',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        width: double.maxFinite,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [],
        ),
      ),
    );
  }
}
