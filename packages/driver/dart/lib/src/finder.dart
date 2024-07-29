enum FinderType {
  label,
  text,
}

class By {
  final String value;
  final FinderType type;

  const By._(this.value, this.type);

  /// Upon getting an element by this constuctor,
  /// any action that is performed on that element
  /// will first execute the `FindAction` by the [label]
  /// & then execute the specified actions on that
  factory By.label(String label) {
    return By._(label, FinderType.label);
  }

  /// Upon getting an element by this constuctor,
  /// any action that is performed on that element
  /// will first execute the `FindAction` by the [text]
  /// & then execute the specified actions on that
  factory By.text(String text) {
    return By._(text, FinderType.text);
  }
}
