import 'dart:async';

import 'package:flutter/widgets.dart' hide Action;

import 'action.dart';

/// Waits till the end of the current frame completion
class PumpAction extends Action {
  const PumpAction();

  factory PumpAction.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'normal' => const PumpAction(),
      'settle' => const PumpAndSettleAction(),
      _ => throw UnimplementedError(),
    };
  }

  Future<void> execute(
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
}

/// Waits till all the scheduled frames get completed.
/// If the scheduled frames won't get completed
/// by the specified [duration], this will throw an exception
class PumpAndSettleAction extends PumpAction {
  const PumpAndSettleAction();

  @override
  Future<void> execute(
    WidgetsBinding binding, [
    Duration duration = Duration.zero,
  ]) async {
    final waitTill = currentDateTime.add(duration);
    do {
      if (currentDateTime.isAfter(waitTill)) {
        throw TimeoutException('pumpAndSettle timed out', duration);
      }
      await super.execute(binding);
    } while (binding.hasScheduledFrame);
  }
}
