import 'dart:io' as io;

import 'package:slugid/slugid.dart';
import 'package:webdriver/sync_io.dart' as web_driver;

import 'element.dart';

const _kChromeUrlBase = 'wd/hub';

const _kFluttereniumReadyEventName = 'ext.flutterenium.ready';
const _kFluttereniumRequestEventName = 'ext.flutterenium.request';
const _kFluttereniumResponseEventName = 'ext.flutterenium.response';

const _kFluttereniumDriverReadyName = 'ext_flutterenium_driver_ready';
const _kFluttereniumDriverEventLogsName = 'ext_flutterenium_driver_logs';

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
  Future<void> open(Uri uri) async {
    _driver
      ..get(uri)
      ..execute(
        '''
        const readyEventName = arguments[0];
        const driverReadyName = arguments[1];
        window.addEventListener(readyEventName, (event) => {
          window[driverReadyName] = true;
        }, {once: true});
      ''',
        [
          _kFluttereniumReadyEventName,
          _kFluttereniumDriverReadyName,
        ],
      );
    bool? isReady;
    do {
      // No idea without dealy it is not working, may be an issue
      // with `WebDriver`, need to raise an issue in their repo.
      await Future.delayed(const Duration(milliseconds: 500));
      isReady = _driver.execute(
        '''
          const driverReadyName = arguments[0];
          console.log(driverReadyName);
          return window[driverReadyName];
        ''',
        [_kFluttereniumDriverReadyName],
      );
    } while (isReady != true);
    _driver.execute(
      '''
          const eventLogsName = arguments[0];
          const responseEventName = arguments[1];

          // All the event log responses happens via the driver
          // will be flushed into the below object
          window[eventLogsName] = {};
          window.addEventListener(responseEventName, (event) => {
            const {id, ...rest} = event.detail;
            window[eventLogsName][id] = rest;
          });
      ''',
      [
        _kFluttereniumDriverEventLogsName,
        _kFluttereniumResponseEventName,
      ],
    );
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

  String _generateUUID() {
    return Slugid.nice().uuid();
  }

  /// This is the heart of entire driver.
  ///
  /// <br>
  /// Performs the specified [action] by establishing
  /// the connection with the `Flutter` app using `Flutterenium`.
  /// Returns `true` along with some data if returned by `Flutterenium`
  /// if the action is successfull, else returns `false` followed by `null`
  Future<(bool, Map?)> _executeAction(
    Element element, [
    Map<String, dynamic>? action,
  ]) async {
    final uuid = _generateUUID();
    _driver.execute(
      '''
          const uuid = arguments[0];
          const requestEventName = arguments[1];
          const actionsToExecute = arguments[2];
          window.dispatchEvent(
            new CustomEvent(
              requestEventName,
              {
                detail: {
                  "id": uuid,
                  "actions": actionsToExecute
                }
              }
            )
          );
      ''',
      [
        uuid,
        _kFluttereniumRequestEventName,
        [element.toFindAction(), if (action != null) action],
      ],
    );
    Map? response;
    do {
      response = _driver.execute(
        '''
          const uuid = arguments[0];
          const eventLogsName = arguments[1];
          return window[eventLogsName][uuid];
        ''',
        [
          uuid,
          _kFluttereniumDriverEventLogsName,
        ],
      );
    } while (response == null);
    final bool didSucceeded = response['didSucceeded'];
    Map? data;
    if (didSucceeded) {
      data = response['data'];
    }
    return (didSucceeded, data);
  }

  /// Finds the specified [element] & return `true`
  /// if found, else `false`
  Future<bool> find(Element element) async {
    final (didSucceeded, _) = await _executeAction(element);
    return didSucceeded;
  }

  /// Get's the text of specified [element] & return it
  /// if found, else `null`
  Future<String?> getText(Element element) async {
    final (didSucceeded, data) = await _executeAction(
      element,
      element.toGetTextAction(),
    );
    String? text;
    if (didSucceeded) {
      text = data!['text'];
    }
    return text;
  }
}
