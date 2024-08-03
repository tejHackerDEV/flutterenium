import 'dart:async';

import 'package:flutter/widgets.dart' hide Action;

import '../action.dart';
import 'find.dart';
import 'pump.dart';

/// Any action that can be performed on `FlutterFramework`
/// should extend this class
abstract class FrameworkAction extends Action {
  const FrameworkAction();

  factory FrameworkAction.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'pump' => PumpAction.fromJson(data),
      'find' => FindAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }

  FutureOr<dynamic> execute(WidgetsBinding binding);
}
