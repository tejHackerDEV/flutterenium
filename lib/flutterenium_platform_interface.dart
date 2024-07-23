import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutterenium_method_channel.dart';

abstract class FluttereniumPlatform extends PlatformInterface {
  /// Constructs a FluttereniumPlatform.
  FluttereniumPlatform() : super(token: _token);

  static final Object _token = Object();

  static FluttereniumPlatform _instance = MethodChannelFlutterenium();

  /// The default instance of [FluttereniumPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterenium].
  static FluttereniumPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FluttereniumPlatform] when
  /// they register themselves.
  static set instance(FluttereniumPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @protected
  late WidgetsBinding binding;

  final requestEventName = 'ext.flutterenium.request';

  final responseEventName = 'ext.flutterenium.response';

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  void ensureInitialized() {
    throw UnimplementedError('ensureInitialized() has not been implemented.');
  }
}
