import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' hide Action;

import '../../extensions.dart';
import '../framework/index.dart';
import 'element.dart';

sealed class PressAction extends ElementAction {
  const PressAction();

  factory PressAction.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'normal_press' => NormalPressAction(),
      'long_press' => LongPressAction(),
      _ => throw UnimplementedError(),
    };
  }

  Duration get duration;

  @override
  Future<bool> execute(WidgetsBinding binding, Element element) async {
    bool didSucceeded = false;
    final renderObject = element.renderObject;
    if (renderObject != null) {
      final center = renderObject.globalPaintBounds.center;
      binding.handlePointerEvent(PointerDownEvent(position: center));
      await PumpAction(duration).execute(binding);
      binding.handlePointerEvent(PointerUpEvent(position: center));
      didSucceeded = true;
    }
    return didSucceeded;
  }
}

class NormalPressAction extends PressAction {
  @override
  Duration get duration => kPressTimeout;
}

class LongPressAction extends PressAction {
  @override
  Duration get duration => kPressTimeout + kLongPressTimeout;
}
