import 'package:flutter/widgets.dart';

extension WidgetExtension on Widget {
  /// Add's an extra property to any class that extends [Widget]
  static final _expando = Expando<String>();

  /// This will be used in finding `this` widget, while crawling
  /// the widget tree, so its suggested to use unique value
  /// for every widget.
  String? get label => _expando[this];

  set label(String? value) => _expando[this] = value;
}
