// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop' as js_interop;
import 'dart:js_interop_unsafe' as js_interop_unsafe;

import 'package:flutter/widgets.dart' hide Action, ScrollAction;
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:web/web.dart' as web;

import 'flutterenium_platform_interface.dart';
import 'src/actions/index.dart';

/// A web implementation of the FluttereniumPlatform of the Flutterenium plugin.
class FluttereniumWeb extends FluttereniumPlatform {
  /// Constructs a FluttereniumWeb
  FluttereniumWeb();

  static void registerWith(Registrar registrar) {
    FluttereniumPlatform.instance = FluttereniumWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = web.window.navigator.userAgent;
    return version;
  }

  void _eventHandler(web.Event event) async {
    if (event is! web.CustomEvent) {
      return;
    }
    bool didSucceeded = false;
    String? id;
    final response = <String, dynamic>{};
    try {
      final json = jsonDecode(jsonEncode(event.detail.dartify()));
      if (json is! Map) {
        return;
      }
      id = json['id'];
      final actions = json['actions'];
      Element? element;
      for (int i = 0; i < actions.length; ++i) {
        final action = Action.fromJson(actions[i]);
        switch (action) {
          case FrameworkAction():
            switch (action) {
              case FindAction():
                element = action.execute(
                  binding,
                  root: element,
                  skipCurrent: element != null,
                );
                didSucceeded = element != null;
                break;
              case _:
                await action.execute(binding);
                didSucceeded = true;
                break;
            }
            break;
          case ElementAction():
            if (element == null) {
              throw UnsupportedError(
                'Something went wrong while executing `FindAction`, because element cannot be null at this stage',
              );
            }
            switch (action) {
              case GetTextAction():
                response['text'] = action.execute(binding, element);
                break;
              case _:
                didSucceeded = await action.execute(binding, element);
                break;
            }
            break;
          case _:
            throw UnimplementedError("$action is not supported yet");
        }
        if (!didSucceeded) {
          // As the action is not succeeded, there is no need to
          // going further to perform remaining actions
          break;
        }
      }
    } catch (error, stackTrace) {
      debugPrint(error.toString());
      debugPrintStack(stackTrace: stackTrace);
      didSucceeded = false;
    } finally {
      web.window.dispatchEvent(
        web.CustomEvent(
          responseEventName,
          web.CustomEventInit(
            detail: {
              'id': id,
              'didSucceeded': didSucceeded,
              if (didSucceeded) 'data': response,
            }.jsify(),
          ),
        ),
      );
    }
  }

  @override
  void onReady() {
    web.window.dispatchEvent(web.CustomEvent(readyEventName));
  }

  @override
  void ensureInitialized() {
    super.ensureInitialized();
    final eventHandler = _eventHandler.toJS;
    assert(() {
      // This code will only run in debugMode, so that upon Hot-Restart
      // previous handler will be removed & only one handler will be
      // valid at a time. This is an hack till the Flutter team
      // provides an api to detect Hot-Restart & clean up the resources
      // for plugins.
      //
      // https://github.com/flutter/flutter/issues/10437
      final previousHandler = web.window.getProperty<js_interop.JSFunction?>(
        requestEventName.toJS,
      );
      web.window
        ..removeEventListener(requestEventName, previousHandler)
        ..setProperty(requestEventName.toJS, eventHandler);
      return true;
    }());
    web.window.addEventListener(requestEventName, eventHandler);

    // Trigger onReady after initialization
    binding.endOfFrame.then((_) {
      onReady();
    });
  }
}
