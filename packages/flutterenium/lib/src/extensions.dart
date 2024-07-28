import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

extension WidgetExtension on Widget {
  /// Add's an extra property to any class that extends [Widget]
  static final _expando = Expando<String>();

  /// This will be used in finding `this` widget, while crawling
  /// the widget tree, so its suggested to use unique value
  /// for every widget.
  String? get label => _expando[this];

  set label(String? value) => _expando[this] = value;
}

extension RenderObjectExtension on RenderObject {
  // Works same as [paintBounds] only difference
  // was this will give output in global coordinates
  //
  // <br>
  // https://stackoverflow.com/a/71568630
  Rect get globalPaintBounds {
    final matrix = getTransformTo(null);
    return MatrixUtils.transformRect(matrix, paintBounds);
  }
}

extension RenderParagraphExtension on RenderParagraph {
  String toPlainText() {
    return text.toPlainText(
      includeSemanticsLabels: false,
      includePlaceholders: false,
    );
  }
}

extension RenderEditableExtension on RenderEditable {
  String toPlainText() {
    return text?.toPlainText(
          includeSemanticsLabels: false,
          includePlaceholders: false,
        ) ??
        '';
  }
}
