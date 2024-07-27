import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Action;
import '../extensions.dart';

import 'action.dart';
import 'find.dart';

class GetTextAction extends Action {
  const GetTextAction() : _editableTextFinder = const FindByWidget();

  final FindByWidget<EditableText> _editableTextFinder;

  String? execute(WidgetsBinding binding, Element element) {
    String? result;
    final renderObject = element.renderObject;
    if (renderObject is RenderParagraph) {
      result = renderObject.toPlainText();
    } else {
      // try checking whether the text belongs to any `EditableText`
      result = _editableTextFinder
          .find(
            binding,
            root: element,
          )
          ?.controller
          .text;
    }

    return result;
  }
}
