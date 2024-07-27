enum FindType {
  label,
  text,
}

class Element {
  final String value;
  final FindType type;

  const Element._(this.value, this.type);

  /// Upon creating an element by this constuctor,
  /// any action that is performed on `this` will first
  /// execute the `FindAction` by the [label] & then
  /// execute the specified actions on that
  factory Element.byLabel(String label) {
    return Element._(label, FindType.label);
  }

  /// Upon creating an element by this constuctor,
  /// any action that is performed on `this` will first
  /// execute the `FindAction` by the [text] & then
  /// execute the specified actions on that
  factory Element.byText(String text) {
    return Element._(text, FindType.text);
  }

  Map<String, dynamic> toFindAction() {
    final name = type.name;
    return {
      "type": "find",
      "data": {
        "type": name,
        "data": {
          name: value,
        },
      }
    };
  }

  Map<String, dynamic> toGetTextAction() {
    return {
      "type": "get_text",
    };
  }

  Map<String, dynamic> toSetTextAction(String text) {
    return {
      "type": "set_text",
      "data": {
        "text": text,
      },
    };
  }

  Map<String, dynamic> toScrollAction(double by, Duration? duration) {
    return {
      "type": "scroll",
      "data": {
        "by": by,
        "milliseconds": duration?.inMilliseconds,
      },
    };
  }
}
