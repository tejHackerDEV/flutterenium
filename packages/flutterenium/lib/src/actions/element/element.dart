import 'dart:async';

import 'package:flutter/widgets.dart' hide Action, ScrollAction;

import '../action.dart';
import 'press.dart';
import 'get_text.dart';
import 'scroll.dart';
import 'set_text.dart';
import 'is_visible.dart';

abstract class ElementAction extends Action {
  const ElementAction();

  factory ElementAction.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'get_text' => const GetTextAction(),
      'set_text' => SetTextAction.fromJson(data),
      'scroll' => ScrollAction.fromJson(data),
      'is_visible' => const IsVisibleAction(),
      'press' => PressAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }

  FutureOr<dynamic> execute(WidgetsBinding binding, Element element);
}
