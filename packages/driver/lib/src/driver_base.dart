import 'dart:io';

enum DriverType {
  chrome,
  firefox,
}

class FluttereniumDriver {
  const FluttereniumDriver._();

  static Future<FluttereniumDriver> init(String path, DriverType type) async {
    final arguments = <String>[];
    switch (type) {
      case DriverType.chrome:
        arguments
          ..add('--port=4444')
          ..add('--url-base=wd/hub')
          ..add('--verbose');
        break;
      case DriverType.firefox:
        arguments.add('--port=4445');
        break;
    }
    await Process.run(path, arguments);
    return FluttereniumDriver._();
  }
}
