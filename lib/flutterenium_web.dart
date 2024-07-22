// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe' as js_interop_unsafe;

import 'package:flutter/widgets.dart' hide Action;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:web/web.dart' as web;

import 'flutterenium_platform_interface.dart';
import 'src/actions/index.dart';
import 'src/index.dart';

/// A web implementation of the FluttereniumPlatform of the Flutterenium plugin.
class FluttereniumWeb extends FluttereniumPlatform {
  /// Constructs a FluttereniumWeb
  FluttereniumWeb();

  static void registerWith(Registrar registrar) {
    FluttereniumPlatform.instance = FluttereniumWeb();
  }

  late Finder _finder;

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  void _eventHandler(web.Event event) {
    if (event is! web.CustomEvent) {
      return;
    }
    final jsonArray = jsonDecode(jsonEncode(event.detail.dartify()));
    if (jsonArray is! List) {
      return;
    }
    Element? element;
    for (int i = 0; i < jsonArray.length; ++i) {
      final action = Action.fromJson(jsonArray[i]);
      if (i == 0) {
        // first index should always be a `find`
        if (action is! FindAction) {
          throw UnsupportedError(
            'First action should start awalys be an `Find`',
          );
        }
        element = switch (action) {
          FindByLabelAction() => _finder.findByLabel(action.label),
          FindByTextAction() => _finder.findByText(action.text),
        };
        continue;
      }
      if (element == null) {
        throw UnsupportedError(
          'Something went wrong while executing `FindAction`, because element cannot be null at this point',
        );
      }
    }
  }

  @override
  void ensureInitialized() {
    binding = WidgetsFlutterBinding.ensureInitialized();
    _finder = Finder(binding);
    final eventHandler = _eventHandler.toJS;
    assert(() {
      // This code will only run in debugMode, so that upon Hot-Restart
      // previous handler will be removed & only one handler will be
      // valid at a time. This is an hack till the Flutter team
      // provides an api to detect Hot-Restart & clean up the resources
      // for plugins.
      //
      // https://github.com/flutter/flutter/issues/10437
      final previousHandler =
          web.window.getProperty<js_interop.JSFunction?>(eventName.toJS);
      web.window
        ..removeEventListener(eventName, previousHandler)
        ..setProperty(eventName.toJS, eventHandler);
      return true;
    }());
    web.window.addEventListener(eventName, eventHandler);
  }
}
