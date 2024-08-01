import 'package:clock/clock.dart';

import 'press.dart';
import 'find.dart';
import 'get_text.dart';
import 'scroll.dart';
import 'set_text.dart';
import 'is_visible.dart';

abstract class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'find' => FindAction.fromJson(data),
      'get_text' => const GetTextAction(),
      'set_text' => SetTextAction.fromJson(data),
      'scroll' => ScrollAction.fromJson(data),
      'is_visible' => const IsVisibleAction(),
      'press' => PressAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }

  DateTime get currentDateTime => clock.now();
}
