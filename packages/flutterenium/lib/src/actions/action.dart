import 'find.dart';
import 'get_text.dart';
import 'scroll.dart';
import 'set_text.dart';

abstract class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'find' => FindAction.fromJson(data),
      'get_text' => const GetTextAction(),
      'set_text' => SetTextAction.fromJson(data),
      'scroll' => ScrollAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }
}
