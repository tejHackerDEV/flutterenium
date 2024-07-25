import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Action;
import '../extensions.dart';

import 'action.dart';

class GetTextAction extends Action {
  const GetTextAction();

  String? execute(Element element) {
    String? result;
    final renderObject = element.renderObject;
    if (renderObject is RenderParagraph) {
      result = renderObject.toPlainText();
    }
    if (renderObject is RenderEditable) {
      result = renderObject.toPlainText();
    }
    return result;
  }
}
