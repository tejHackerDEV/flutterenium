import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Action;

import 'element.dart';

class IsVisibleAction extends ElementAction {
  const IsVisibleAction();

  @override
  bool execute(WidgetsBinding binding, Element element) {
    bool isVisible = false;
    // Kanged the code from `flutter_test` package after checking
    // the below post. All credits goes to them
    //
    // https://stackoverflow.com/a/72735071
    final viewId = element.findAncestorWidgetOfExactType<View>()?.view.viewId;
    if (viewId != null) {
      final renderObject = element.renderObject;
      if (renderObject is RenderBox) {
        final absoluteOffset = renderObject.localToGlobal(
          Alignment.center.alongSize(renderObject.size),
        );
        final hitResult = HitTestResult();
        binding.hitTestInView(hitResult, absoluteOffset, viewId);
        for (final entry in hitResult.path) {
          if (entry.target == renderObject) {
            isVisible = true;
            break;
          }
        }
      }
    }
    return isVisible;
  }
}
