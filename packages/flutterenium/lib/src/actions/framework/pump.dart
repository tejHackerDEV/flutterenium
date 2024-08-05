import 'dart:async';

import 'package:flutter/widgets.dart' hide Action;

import 'framework.dart';

/// Waits till the end of the current frame completion
class PumpAction extends FrameworkAction {
  const PumpAction(this.duration);

  final Duration duration;

  factory PumpAction.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final milliseconds = data?['milliseconds'];
    return switch (json['type']) {
      'normal' => PumpAction(
          Duration(milliseconds: milliseconds ?? 0),
        ),
      'settle' => PumpAndSettleAction(
          Duration(
            milliseconds: milliseconds ?? (10 * Duration.millisecondsPerSecond),
          ),
        ),
      _ => throw UnimplementedError(),
    };
  }

  @override
  Future<void> execute(WidgetsBinding binding) async {
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
  const PumpAndSettleAction(super.duration);

  @override
  Future<void> execute(WidgetsBinding binding) async {
    final waitTill = currentDateTime.add(duration);
    do {
      if (currentDateTime.isAfter(waitTill)) {
        throw TimeoutException('pumpAndSettle timed out', duration);
      }
      await super.execute(binding);
    } while (binding.hasScheduledFrame);
  }
}
