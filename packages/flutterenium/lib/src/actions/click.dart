import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' hide Action;

import '../extensions.dart';
import 'action.dart';

class ClickAction extends Action {
  const ClickAction();

  Future<bool> execute(WidgetsBinding binding, Element element) async {
    bool didSucceeded = false;
    final renderObject = element.renderObject;
    if (renderObject != null) {
      final center = renderObject.globalPaintBounds.center;
      binding.handlePointerEvent(PointerDownEvent(position: center));
      await pump(binding, kPressTimeout);
      binding.handlePointerEvent(PointerUpEvent(position: center));
      didSucceeded = true;
    }
    return didSucceeded;
  }
}
