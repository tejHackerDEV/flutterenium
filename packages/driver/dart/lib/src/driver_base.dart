import 'dart:async';

import 'package:slugid/slugid.dart';
import 'package:puppeteer/puppeteer.dart' as web_driver;

import 'element.dart';
import 'finder.dart';

const _kFluttereniumReadyEventName = 'ext.flutterenium.ready';
const _kFluttereniumRequestEventName = 'ext.flutterenium.request';
const _kFluttereniumResponseEventName = 'ext.flutterenium.response';

const _kFluttereniumDriverReadyName = 'ext_flutterenium_driver_ready';
const _kFluttereniumDriverEventLogsName = 'ext_flutterenium_driver_logs';

class FluttereniumDriver {
  final web_driver.Browser _driver;

  const FluttereniumDriver._(this._driver);

  static Future<FluttereniumDriver> init(String path) async {
    final driver = await web_driver.puppeteer.launch(
      executablePath: path,
      headless: false,
      // https://stackoverflow.com/a/60282642
      defaultViewport: null,
      args: [
        '--start-maximized',
      ],
    );
    return FluttereniumDriver._(driver);
  }

  Future<web_driver.Page?> get _currentPage async {
    final pages = await _driver.pages;
    if (pages.isEmpty) {
      return null;
    }
    return pages.last;
  }

  /// Executes the [script] with the [args] on the specified [page]
  ///
  /// <br>
  /// Even though this fucntion takes [page] as nullable object,
  /// in the declaration it expects it should be non-nullable.
  /// So one should be careful while passing arguments to this.
  Future<T> _executeScript<T>(
    FutureOr<web_driver.Page?> page,
    String script, [
    List<dynamic>? args,
  ]) async {
    // Without `trimming` the script, driver is unable to execute it
    // in some cases, so for safe side `trimming` every script.
    // We need to open an issue in `Puppeteer` repo
    return (await page)!.evaluate<T>(script.trim(), args: args);
  }

  /// Opens the specified [uri] in the browser,
  /// if the browser is not running. Else open
  /// it in the current window that is showing.
  ///
  /// If this function returns `false`, it means
  /// it is not guarenteed even the page opened
  /// the actions that were going to perform will
  /// succeed. So one needs to check the result
  /// of this function before performing any actions.
  Future<bool> open(Uri uri) async {
    final page = (await _currentPage) ?? await _driver.newPage();
    final response = await page.goto(uri.toString());
    if (!response.ok) {
      return false;
    }
    final isReady = await _executeScript<bool>(
      page,
      '''
        (readyEventName, driverReadyName) => {
          return new Promise((resolve, reject) => {
            window.addEventListener(readyEventName, (event) => {
              window[driverReadyName] = true;
              resolve(true);
            }, {once: true});
          });
        }
      ''',
      [
        _kFluttereniumReadyEventName,
        _kFluttereniumDriverReadyName,
      ],
    );
    if (!isReady) {
      return false;
    }
    await _executeScript(
      page,
      '''
        (eventLogsName, responseEventName) => {
          // All the event log responses happens via the driver
          // will be flushed into the below object
          window[eventLogsName] = {};
          window.addEventListener(responseEventName, (event) => {
            const {id, ...rest} = event.detail;
            window[eventLogsName][id] = rest;
          });
        }
      ''',
      [
        _kFluttereniumDriverEventLogsName,
        _kFluttereniumResponseEventName,
      ],
    );
    return true;
  }

  /// Closes the current page by default.
  ///
  /// <br>
  /// If [withBrowser] is set to `true` then complete browser will close
  /// along with the process in which the driver is running
  Future<void> close({bool withBrowser = false}) async {
    if (!withBrowser) {
      (await _currentPage)!.close();
      return;
    }
    await _driver.close();
  }

  String _generateUUID() {
    return Slugid.nice().uuid();
  }

  /// This is the heart of entire driver.
  ///
  /// <br>
  /// Performs the specified [actions] by establishing
  /// the connection with the `Flutter` app using `Flutterenium`.
  /// Returns `true` along with some data if returned by `Flutterenium`
  /// if the action is successful, else returns `false` followed by `null`
  ElementActionResponse _executeActions(
    List<Map<String, dynamic>> actions,
  ) async {
    final uuid = _generateUUID();
    await _executeScript(
      _currentPage,
      '''
        (uuid, requestEventName, actionsToExecute) => {
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
        }
      ''',
      [
        uuid,
        _kFluttereniumRequestEventName,
        actions,
      ],
    );
    Map? response;
    do {
      response = await _executeScript(
        _currentPage,
        '''
          (uuid, eventLogsName) => {
            return window[eventLogsName][uuid];
          }
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

  /// Gets an reference to an [Element]
  /// based on the [by] finder.
  ///
  /// <br>
  /// Also keep in mind that this is just an handle
  /// to perform actions, so an element will be returned
  /// no matter whether an element is actually present
  /// or not. One should use the `actions` to test whether
  /// element is actually present or not.
  Element get(By by) {
    final name = by.type.name;
    final findAction = {
      "type": "find",
      "data": {
        "type": name,
        "data": {
          name: by.value,
        },
      }
    };
    return Element(onActionExecuted: (action) {
      return _executeActions([findAction, if (action != null) action]);
    });
  }
}
