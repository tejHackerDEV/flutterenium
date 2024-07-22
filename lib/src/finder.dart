import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterenium/src/index.dart';

class Finder {
  final WidgetsBinding _binding;

  const Finder(this._binding);

  Element? _findByText(String text, Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    final renderObject = visitor.renderObject;
    if (renderObject is RenderParagraph) {
      final textToMatch = renderObject.text
          .getSemanticsInformation()
          .map((info) => info.text)
          .join('');
      if (textToMatch == text) {
        result = visitor;
      }
    }
    return result ?? _findByText(text, visitor);
  }

  /// Finds an [Element] if the `text` it is rendering
  /// matched with the given [text].
  ///
  /// <br>
  /// If no matches returns `null`.
  Element? findByText(String text) {
    return _findByText(text, _binding.rootElement);
  }

  Element? _findByLabel(String label, Element? visitor) {
    if (visitor == null) {
      return null;
    }
    Element? result;
    if (visitor.widget.label == label) {
      result = visitor;
    }
    return result ?? _findByLabel(label, visitor);
  }

  /// Finds an [Element] if the `label` it is assigned
  /// matched with the given [label].
  ///
  /// <br>
  /// If no matches returns `null`.
  Element? findByLabel(String label) {
    return _findByLabel(label, _binding.rootElement);
  }
}
