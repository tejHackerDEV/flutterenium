import 'dart:async';

import 'package:flutter/widgets.dart' hide Action;

import '../framework/index.dart';
import 'element.dart';

const _kDebugLabel = 'FluttereniumScrollController';

class ScrollAction extends ElementAction {
  const ScrollAction(this.delta, this.milliseconds)
      : _scrollableFinder = const FindByWidget(),
        _rawGuestureDetectorFinder = const FindByWidget();

  factory ScrollAction.fromJson(Map<String, dynamic> json) {
    return ScrollAction(json['delta'], json['milliseconds']);
  }

  final double delta;
  final int? milliseconds;
  final FindByWidget<Scrollable> _scrollableFinder;
  final FindByWidget<RawGestureDetector> _rawGuestureDetectorFinder;

  @override
  FutureOr<bool> execute(WidgetsBinding binding, Element element) async {
    bool didSucceeded = false;
    // All the code that is written is based on the comments written
    // by Flutter team inside `Scrollable` widget `build` method.
    //
    // So based on the usage of `_ScrollableScope` usage inside
    // `Scrollable` widget this is developed. If flutter teams changes its
    // implementation then we need to change & adjust the code accordingly
    final scrollableElement = _scrollableFinder.execute(binding, root: element);
    if (scrollableElement != null) {
      GlobalKey? globalKey;
      Element? elementForSearch = scrollableElement;
      do {
        // as Flutter team uses `RawGuestureDetector` key to define
        // `notificationContext` we recursively find that widget
        // till we found the `GlobalKey` & use the that context
        elementForSearch = _rawGuestureDetectorFinder.execute(
          binding,
          root: elementForSearch,
        );
        final widget = elementForSearch?.widget;
        if (widget != null) {
          final key = widget.key;
          if (key is GlobalKey) {
            globalKey = key;
          }
        }
      } while (globalKey == null);
      final scrollableState = Scrollable.of(globalKey.currentState!.context);
      // 1.Create our own `ScrollController`
      //
      // 2. Attach the `position` we got from
      //    the `scrollableState` to our controller.
      //
      // 3. Perform any action we want to do using our controller
      //
      // 4. Finally, dispose our controller
      final scrollController = ScrollController(debugLabel: _kDebugLabel);
      scrollController.attach(scrollableState.position);
      final double offset;
      if (delta == 0) {
        // scroll to very top
        offset = scrollController.position.minScrollExtent;
      } else if (delta == -1) {
        // scroll to very bottom
        offset = scrollController.position.maxScrollExtent;
      } else {
        offset = scrollController.offset + delta;
      }
      if ([null, 0].contains(milliseconds)) {
        scrollController.jumpTo(offset);
      } else {
        await scrollController.animateTo(
          offset,
          duration: Duration(milliseconds: milliseconds!),
          curve: Curves.linear,
        );
      }
      scrollController.dispose();
      didSucceeded = true;
    }
    return didSucceeded;
  }
}
