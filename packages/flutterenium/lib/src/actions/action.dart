import 'package:clock/clock.dart';

import 'framework/index.dart';
import 'element/index.dart';

abstract class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'framework' => FrameworkAction.fromJson(data),
      'element' => ElementAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }

  DateTime get currentDateTime => clock.now();
}
