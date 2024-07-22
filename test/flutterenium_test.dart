import 'package:flutter/src/widgets/binding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterenium/flutterenium.dart';
import 'package:flutterenium/flutterenium_platform_interface.dart';
import 'package:flutterenium/flutterenium_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluttereniumPlatform
    with MockPlatformInterfaceMixin
    implements FluttereniumPlatform {
  @override
  late WidgetsBinding binding;

  @override
  String get eventName => 'flutterenium';

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  void ensureInitialized() {
    // TODO: implement ensureInitialized
  }
}

void main() {
  final FluttereniumPlatform initialPlatform = FluttereniumPlatform.instance;

  test('$MethodChannelFlutterenium is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterenium>());
  });

  test('getPlatformVersion', () async {
    Flutterenium fluttereniumPlugin = Flutterenium();
    MockFluttereniumPlatform fakePlatform = MockFluttereniumPlatform();
    FluttereniumPlatform.instance = fakePlatform;

    expect(await fluttereniumPlugin.getPlatformVersion(), '42');
  });
}
