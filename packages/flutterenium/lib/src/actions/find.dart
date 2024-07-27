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

  Element? execute(WidgetsBinding binding);
}

class FindByLabelAction extends FindAction {
  final String label;

  const FindByLabelAction(this.label);

  factory FindByLabelAction.fromJson(Map<String, dynamic> json) {
    return FindByLabelAction(json['label']);
  }

  Element? _find(Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    if (visitor.widget.label == label) {
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

  /// Finds an [Element] if the `label` it is assigned
  /// matched with the given [label].
  ///
  /// <br>
  /// If no matches returns `null`.
  @override
  Element? execute(WidgetsBinding binding) {
    return _find(binding.rootElement);
  }
}

class FindByTextAction extends FindAction {
  final String text;

  const FindByTextAction(this.text);

  factory FindByTextAction.fromJson(Map<String, dynamic> json) {
    return FindByTextAction(json['text']);
  }

  Element? _find(Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    final renderObject = visitor.renderObject;
    if (renderObject is RenderParagraph) {
      final textToMatch = renderObject.toPlainText();
      if (textToMatch == text) {
        result = visitor;
      }
    }
    if (result == null) {
      // as result not found, recursively check for it
      visitor.visitChildren((visitor) {
        result ??= _find(visitor);
      });
    }
    return result;
  }

  /// Finds an [Element] if the `text` it is rendering
  /// matched with the given [text].
  ///
  /// <br>
  /// If no matches returns `null`.
  @override
  Element? execute(WidgetsBinding binding) {
    return _find(binding.rootElement);
  }
}

class FindByWidget<T extends Widget> extends FindAction {
  const FindByWidget();

  Element? _find(Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    if (visitor.widget is T) {
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

  /// Finds an [Element] if the `widget` it is holding
  /// of type [T]. If [root] is `null` then it start
  /// looking for the widget from the rootElement of
  /// the [binding], else it will start looking from
  /// sepecified `root`.
  ///
  /// <br>
  /// If no matches returns `null`.
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
