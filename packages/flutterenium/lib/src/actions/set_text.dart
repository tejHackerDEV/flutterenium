import 'package:flutter/widgets.dart' hide Action;

import 'action.dart';
import 'find.dart';

class SetTextAction extends Action {
  const SetTextAction(this.text) : _finder = const FindByWidget();

  factory SetTextAction.fromJson(Map<String, dynamic> json) {
    return SetTextAction(json['text']);
  }

  final String text;
  final FindByWidget<EditableText> _finder;

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
