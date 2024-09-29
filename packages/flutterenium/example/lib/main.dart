import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          title: const Text('Flutterenium Plugin example app'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16.0,
          ),
          child: Column(
            children: [
              SvgPicture.network(
                'https://raw.githubusercontent.com/dnfield/flutter_svg/master/packages/flutter_svg/example/assets/flutter_logo.svg',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 12.0),
              const _TextFieldWithToastButton(),
              const SizedBox(height: 12.0),
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
      ),
    );
  }
}

class _TextFieldWithToastButton extends StatefulWidget {
  const _TextFieldWithToastButton({super.key});

  @override
  State<_TextFieldWithToastButton> createState() =>
      __TextFieldWithToastButtonState();
}

class __TextFieldWithToastButtonState extends State<_TextFieldWithToastButton> {
  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _textEditingController,
          decoration: const InputDecoration(hintText: 'Enter here'),
        ),
        const SizedBox(height: 12.0),
        Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_textEditingController.text),
                ),
              );
            },
            child: const Text('Show as toast'),
          );
        })
      ],
    );
  }
}
