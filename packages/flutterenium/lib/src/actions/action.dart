import 'find.dart';
import 'get_text.dart';

abstract class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'find' => FindAction.fromJson(json['data']),
      'get_text' => const GetTextAction(),
      _ => throw UnimplementedError(),
    };
  }
}
