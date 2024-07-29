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
        body: Column(
          children: [
            Builder(builder: (context) {
              return InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("I am pressed"),
                    ),
                  );
                },
                child: const Text('Test the flutterenium plugin'),
              );
            }),
            const TextField()..label = 'text-field',
            Expanded(
              child: ListView(
                children: List.generate(25, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      index.toString(),
                    ),
                  );
                }),
              )..label = 'list-view',
            ),
          ],
        ),
      ),
    );
  }
}
