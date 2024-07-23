import 'flutterenium_platform_interface.dart';
export 'src/index.dart';

class Flutterenium {
  Future<String?> getPlatformVersion() {
    return FluttereniumPlatform.instance.getPlatformVersion();
  }

  void ensureInitialized() {
    FluttereniumPlatform.instance.ensureInitialized();
  }
}
