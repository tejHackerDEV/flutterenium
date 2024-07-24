import 'package:flutter/material.dart';

import 'package:flutterenium/flutterenium.dart';

void main() {
  Flutterenium().ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fluttereium Plugin example app'),
        ),
        body: const Center(
          child: Text('Test the flutterenium plugin'),
        ),
      ),
    );
  }
}
