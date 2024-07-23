import 'find.dart';

class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'find' => FindAction.fromJson(json['data']),
      _ => throw UnimplementedError(),
    };
  }
}
