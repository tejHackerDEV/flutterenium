import 'flutterenium_platform_interface.dart';

class Flutterenium {
  Future<String?> getPlatformVersion() {
    return FluttereniumPlatform.instance.getPlatformVersion();
  }

  void ensureInitialized() {
    FluttereniumPlatform.instance.ensureInitialized();
  }
}
