import 'dart:io' as io;

import 'package:webdriver/sync_io.dart' as web_driver;

const _kChromeUrlBase = 'wd/hub';

enum DriverType {
  chrome(4444),
  firefox(4445);

  final int portNumber;

  const DriverType(this.portNumber);
}

class FluttereniumDriver {
  /// Holds the process in which [_driver] created
  final io.Process _process;

  final web_driver.WebDriver _driver;

  const FluttereniumDriver._(this._process, this._driver);

  static Future<FluttereniumDriver> init(String path, DriverType type) async {
    final Uri driverUri;
    final web_driver.WebDriverSpec driverSpec;
    final arguments = <String>[];
    switch (type) {
      case DriverType.chrome:
        driverUri = Uri.parse(
          'http://127.0.0.1:${type.portNumber}/$_kChromeUrlBase/',
        );
        driverSpec = web_driver.WebDriverSpec.JsonWire;
        arguments
          ..add('--port=${type.portNumber}')
          ..add('--url-base=$_kChromeUrlBase')
          ..add('--verbose');
        break;
      case DriverType.firefox:
        driverUri = Uri.parse('http://127.0.0.1:${type.portNumber}/');
        driverSpec = web_driver.WebDriverSpec.W3c;
        arguments.add('--port=${type.portNumber}');
        break;
    }
    final process = await io.Process.start(path, arguments);
    final driver = web_driver.createDriver(
      uri: driverUri,
      spec: driverSpec,
    );
    return FluttereniumDriver._(process, driver);
  }

  /// Opens the specified [uri] in the browser,
  /// if the browser is not running. Else open
  /// it in the current window that is showing
  void open(Uri uri) {
    _driver.get(uri);
  }

  /// Closes the current window by default.
  ///
  /// <br>
  /// If [withBrowser] is set to `true` then complete browser will close
  /// along with the process in which the driver is running
  void close({bool withBrowser = false}) {
    if (!withBrowser) {
      _driver.window.close();
      return;
    }
    _driver.quit(closeSession: true);
    _process.kill();
  }
}
