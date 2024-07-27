import 'package:flutter/widgets.dart' hide Action;
import 'package:flutterenium/src/actions/index.dart';

import 'action.dart';

class SetTextAction extends Action {
  const SetTextAction(this.text);

  factory SetTextAction.fromJson(Map<String, dynamic> json) {
    return SetTextAction(json['text']);
  }

  final String text;

  bool execute(Element element) {
    bool didSucceeded = false;
    final widget = element.widget;
    if (widget is EditableText) {
      widget.controller.text = text;
      didSucceeded = true;
    }
    return didSucceeded;
  }
}
