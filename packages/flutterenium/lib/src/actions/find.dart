import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Action;

import 'action.dart';
import '../extensions.dart';

sealed class FindAction extends Action {
  const FindAction();

  factory FindAction.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'label' => FindByLabelAction.fromJson(json['data']),
      'text' => FindByTextAction.fromJson(json['data']),
      _ => throw UnimplementedError(),
    };
  }

  /// If this returns `true` then the [execute] method
  /// will return the [element]
  bool matcher(Element element);

  Element? _find(Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    if (matcher(visitor)) {
      result = visitor;
    }
    if (result == null) {
      // as result not found, recursively check for it
      visitor.visitChildren((visitor) {
        result ??= _find(visitor);
      });
    }
    return result;
  }

  Element? execute(WidgetsBinding binding) {
    return _find(binding.rootElement);
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
    bool matched = false;
    final renderObject = element.renderObject;
    if (renderObject is RenderParagraph) {
      final textToMatch = renderObject.toPlainText();
      matched = textToMatch == text;
    }
    return matched;
  }
}

class FindByWidget<T extends Widget> extends FindAction {
  /// Finds an [Element] if the `widget` it is holding
  /// of type [T]. If [root] is `null` then it start
  /// looking for the widget from the rootElement of
  /// the [binding], else it will start looking from
  /// sepecified `root`.
  ///
  /// <br>
  /// If no matches returns `null`.
  const FindByWidget();

  @override
  bool matcher(Element element) {
    return element.widget is T;
  }

  @override
  Element? execute(WidgetsBinding binding, {Element? root}) {
    return _find(root ?? binding.rootElement);
  }

  /// An wrapper around [execute] just to match the `Generics`
  T? find(WidgetsBinding binding, {required Element root}) {
    final element = execute(binding, root: root);
    return (element?.widget as T?);
  }
}
