import 'package:flutter/widgets.dart' hide Action;

import '../framework/index.dart';
import 'element.dart';

class SetTextAction extends ElementAction {
  const SetTextAction(this.text) : _finder = const FindByWidget();

  factory SetTextAction.fromJson(Map<String, dynamic> json) {
    return SetTextAction(json['text']);
  }

  final String text;
  final FindByWidget<EditableText> _finder;

  @override
  bool execute(WidgetsBinding binding, Element element) {
    bool didSucceeded = false;
    final widget = _finder.find(binding, root: element);
    if (widget != null) {
      widget.controller.text = text;
      didSucceeded = true;
    }
    return didSucceeded;
  }
}
