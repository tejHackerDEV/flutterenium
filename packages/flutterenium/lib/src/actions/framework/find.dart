import 'package:flutter/material.dart' hide Action;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../extensions.dart';
import 'framework.dart';

sealed class FindAction extends FrameworkAction {
  const FindAction();

  factory FindAction.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'label' => FindByLabelAction.fromJson(json['data']),
      'text' => FindByTextAction.fromJson(json['data']),
      'svg' => FindBySvgAction.fromJson(json['data']),
      'icon' => FindByIconAction.fromJson(json['data']),
      'preceding_sibling' => FindPrecedingSiblingAction.fromJson(json['data']),
      'following_sibling' => FindFollowingSiblingAction.fromJson(json['data']),
      _ => throw UnimplementedError(),
    };
  }

  /// If this returns `true` then the [execute] method
  /// will return the [element]
  bool matcher(Element element);

  /// If [skipCurrent] is `true` then the [visitor]
  /// won't be  used to match the `Element`, only their
  /// children will be matched.
  Element? _find(Element? visitor, {required bool skipCurrent}) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    if (!skipCurrent && matcher(visitor)) {
      result = visitor;
    }
    if (result == null) {
      // as result not found, recursively check for it
      visitor.visitChildren((visitor) {
        result ??= _find(visitor, skipCurrent: false);
      });
    }
    return result;
  }

  @override
  Element? execute(
    WidgetsBinding binding, {
    Element? root,
    bool skipCurrent = false,
  }) {
    return _find(root ?? binding.rootElement, skipCurrent: skipCurrent);
  }
}

class FindByLabelAction extends FindAction {
  final String label;

  /// Finds an [Element] if the `label` it is assigned
  /// matched with the given [label].
  ///
  /// <br>
  /// If no matches returns `null`.
  const FindByLabelAction(this.label);

  factory FindByLabelAction.fromJson(Map<String, dynamic> json) {
    return FindByLabelAction(json['label']);
  }

  @override
  bool matcher(Element element) {
    return element.widget.label == label;
  }
}

class FindByTextAction extends FindAction {
  final String text;

  /// Finds an [Element] if the `text` it is rendering
  /// matched with the given [text].
  ///
  /// <br>
  /// If no matches returns `null`.
  const FindByTextAction(this.text);

  factory FindByTextAction.fromJson(Map<String, dynamic> json) {
    return FindByTextAction(json['text']);
  }

  @override
  bool matcher(Element element) {
    final widget = element.widget;
    final renderObject = element.renderObject;
    final textToMatch = switch (widget) {
      InputDecorator() => widget.decoration.hintText,
      _ => switch (renderObject) {
          RenderParagraph() => renderObject.toPlainText(),
          RenderEditable() => renderObject.toPlainText(),
          _ => null
        }
    };
    return textToMatch == text;
  }
}

class FindByIconAction extends FindAction {
  final int icon;

  /// Finds an [Element] if the `icon` it is rendering
  /// matched with the given [icon].
  ///
  /// <br>
  /// If no matches returns `null`.
  const FindByIconAction(this.icon);

  factory FindByIconAction.fromJson(Map<String, dynamic> json) {
    return FindByIconAction(json['icon']);
  }

  @override
  bool matcher(Element element) {
    final widget = element.widget;
    if (widget is! Icon) {
      return false;
    }
    return widget.icon?.codePoint == icon;
  }
}

class FindByWidget<T extends Widget> extends FindAction {
  /// Finds an [Element] if the `widget` it is holding
  /// is of type [T]. If [root] is `null` then it start
  /// looking for the widget from the rootElement of
  /// the [binding], else it will start looking from
  /// sepecified `root`. By default it skips the speicifed
  /// `root` & starts looping from its children, this can
  /// be overriden by passing [skipCurrent] to `false`.
  ///
  /// <br>
  /// If no matches returns `null`.
  const FindByWidget();

  @override
  bool matcher(Element element) {
    return element.widget is T;
  }

  @override
  Element? execute(
    WidgetsBinding binding, {
    Element? root,
    bool skipCurrent = true,
  }) {
    return _find(root ?? binding.rootElement, skipCurrent: skipCurrent);
  }

  /// An wrapper around [execute] just to match the `Generics`
  T? find(WidgetsBinding binding, {required Element root}) {
    final element = execute(binding, root: root);
    return (element?.widget as T?);
  }
}

class FindBySvgAction extends FindByWidget<SvgPicture> {
  final String value;

  /// Finds an [Element] if the `widget` it is holding
  /// is of type [SvgPicture] & matches the [value].
  const FindBySvgAction(this.value);

  factory FindBySvgAction.fromJson(Map<String, dynamic> json) {
    return FindBySvgAction(json['svg']);
  }

  @override
  bool matcher(Element element) {
    bool didMatched = false;
    if (super.matcher(element)) {
      final bytesLoader = (element.widget as SvgPicture).bytesLoader;
      final valueToMatch = switch (bytesLoader) {
        SvgAssetLoader() => bytesLoader.assetName,
        SvgFileLoader() => bytesLoader.file.path,
        SvgNetworkLoader() => bytesLoader.url,
        _ => null,
      };
      if (valueToMatch != null) {
        didMatched = RegExp(value).hasMatch(valueToMatch);
      }
    }
    return didMatched;
  }
}

sealed class FindSiblingAction extends FindAction {
  final bool skipGaps;

  /// Finds the sibling for a given element.
  ///
  /// <br>
  /// If no sibling found then returns `null`.
  const FindSiblingAction(this.skipGaps);

  FindSiblingAction.fromJson(Map<String, dynamic> json)
      : skipGaps = json['skip_gaps'];

  @override
  bool matcher(Element element) {
    if (!skipGaps) {
      return true;
    }
    return !_isDummyWidget(element.widget);
  }

  @override
  Element? _find(Element? visitor, {required bool skipCurrent}) =>
      throw UnimplementedError();

  bool _isDummyWidget(Widget widget) {
    if (widget is SingleChildRenderObjectWidget) {
      return widget.child == null;
    }
    if (widget is MultiChildRenderObjectWidget) {
      return widget.children.isEmpty;
    }
    return false;
  }
}

class FindPrecedingSiblingAction extends FindSiblingAction {
  const FindPrecedingSiblingAction(super.skipGaps);

  FindPrecedingSiblingAction.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  @override
  Element? _find(Element? visitor, {required bool skipCurrent}) {
    if (visitor == null) {
      return null;
    }
    Element prevVisitor = visitor;
    Element? result;
    visitor.visitAncestorElements((ancestor) {
      final siblings = <Element>[];
      bool didReachedVisitor = false;
      ancestor.visitChildren((element) {
        if (!didReachedVisitor) {
          didReachedVisitor = element == prevVisitor;
        }

        if (!didReachedVisitor) {
          if (matcher(element)) {
            siblings.add(element);
          }
        }
      });
      if (!didReachedVisitor || siblings.isEmpty) {
        // as result not found, recursively check for it
        prevVisitor = ancestor;
        return true;
      }
      result = siblings[siblings.length - 1];
      return false;
    });

    return result;
  }
}

class FindFollowingSiblingAction extends FindSiblingAction {
  const FindFollowingSiblingAction(super.skipGaps);

  FindFollowingSiblingAction.fromJson(Map<String, dynamic> json)
      : super.fromJson(json);

  @override
  Element? _find(Element? visitor, {required bool skipCurrent}) {
    if (visitor == null) {
      return null;
    }
    Element prevVisitor = visitor;
    Element? result;
    visitor.visitAncestorElements((ancestor) {
      final siblings = <Element>[];
      bool didReachedVisitor = false;
      ancestor.visitChildren((element) {
        if (didReachedVisitor) {
          if (matcher(element)) {
            siblings.add(element);
          }
        } else {
          didReachedVisitor = element == prevVisitor;
        }
      });
      if (!didReachedVisitor || siblings.isEmpty) {
        // as result not found, recursively check for it
        prevVisitor = ancestor;
        return true;
      }
      result = siblings[0];
      return false;
    });

    return result;
  }
}
