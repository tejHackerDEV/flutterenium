import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:flutter_svg/flutter_svg.dart';

import '../../extensions.dart';
import 'framework.dart';

sealed class FindAction extends FrameworkAction {
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

  /// If [skipCurrent] is `true` then the [visitor]
  /// won't be  used to match the `Element`, only their
  /// children will be matched. Defaults to `false`
  Element? _find(Element? visitor, {bool skipCurrent = false}) {
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
        result ??= _find(visitor);
      });
    }
    return result;
  }

  @override
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
    final renderObject = element.renderObject;
    final textToMatch = switch (renderObject) {
      RenderParagraph() => renderObject.toPlainText(),
      RenderEditable() => renderObject.toPlainText(),
      _ => null
    };
    return textToMatch == text;
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

class FindBySvg extends FindByWidget<SvgPicture> {
  final String value;

  /// Finds an [Element] if the `widget` it is holding
  /// is of type [SvgPicture].
  const FindBySvg(this.value);

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
