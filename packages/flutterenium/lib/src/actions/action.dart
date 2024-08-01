import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart' hide ScrollAction;

import 'press.dart';
import 'find.dart';
import 'get_text.dart';
import 'scroll.dart';
import 'set_text.dart';
import 'is_visible.dart';

abstract class Action {
  const Action();

  factory Action.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return switch (json['type']) {
      'find' => FindAction.fromJson(data),
      'get_text' => const GetTextAction(),
      'set_text' => SetTextAction.fromJson(data),
      'scroll' => ScrollAction.fromJson(data),
      'is_visible' => const IsVisibleAction(),
      'press' => PressAction.fromJson(data),
      _ => throw UnimplementedError(),
    };
  }

  DateTime get currentDateTime => clock.now();

  /// Waits till the end of the current frame completion
  Future<void> pump(
    WidgetsBinding binding, [
    Duration duration = Duration.zero,
  ]) async {
    if (duration <= Duration.zero) {
      await binding.endOfFrame;
      return;
    }
    final waitTill = currentDateTime.add(duration);
    while (currentDateTime.isBefore(waitTill)) {
      await binding.endOfFrame;
    }
  }

  /// Waits till all the scheduled frames get completed.
  /// If the scheduled frames won't get completed
  /// by the specified [duration], this will throw an exception
  Future<void> pumpAndSettle(
    WidgetsBinding binding, [
    Duration duration = const Duration(seconds: 10),
  ]) async {
    final waitTill = currentDateTime.add(duration);
    do {
      if (currentDateTime.isAfter(waitTill)) {
        throw TimeoutException('pumpAndSettle timed out', duration);
      }
      await pump(binding);
    } while (binding.hasScheduledFrame);
  }
}
