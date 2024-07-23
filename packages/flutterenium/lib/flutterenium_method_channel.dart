import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutterenium_platform_interface.dart';

/// An implementation of [FluttereniumPlatform] that uses method channels.
class MethodChannelFlutterenium extends FluttereniumPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutterenium');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
