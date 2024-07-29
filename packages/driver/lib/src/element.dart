typedef ElementActionResponse = Future<(bool, Map?)>;

typedef ElementActionExecuted = ElementActionResponse Function(
  Map<String, dynamic>? action,
);

class Element {
  final ElementActionExecuted onActionExecuted;

  const Element._(this.onActionExecuted);

  factory Element({required ElementActionExecuted onActionExecuted}) {
    return Element._(onActionExecuted);
  }

  /// Finds `this` element & return `true`
  /// if found, else `false`.
  ///
  /// <br>
  /// This won't check whether the element is currently visible
  /// on the screen ot not, to check that condiser using
  /// [isVisible].
  Future<bool> find() async {
    final (didSucceeded, _) = await onActionExecuted(null);
    return didSucceeded;
  }

  /// Get the text of `this` element & return it
  /// if found, else `null`
  Future<String?> getText() async {
    final (didSucceeded, data) = await onActionExecuted(
      {
        "type": "get_text",
      },
    );
    String? text;
    if (didSucceeded) {
      text = data!['text'];
    }
    return text;
  }

  /// Set the [text] for `this` element & return
  /// `true` if succeeded, else `false`
  Future<bool> setText(String text) async {
    final (didSucceeded, _) = await onActionExecuted(
      {
        "type": "set_text",
        "data": {
          "text": text,
        },
      },
    );
    return didSucceeded;
  }

  /// Scrolls `this` by [delta] pixels.
  ///
  /// <br>
  /// If [duration] is null it will jump direclty to location,
  /// else it will animate to the location.
  Future<bool> scrollBy(double delta, {Duration? duration}) async {
    final (didSucceeded, _) = await onActionExecuted(
      {
        "type": "scroll",
        "data": {
          "delta": delta,
          "milliseconds": duration?.inMilliseconds,
        },
      },
    );
    return didSucceeded;
  }

  /// Checks whether the this `element` is actually
  /// visible on the screen or not &
  /// returns `true` or `false` accordingly.
  Future<bool> isVisible() async {
    final (didSucceeded, _) = await onActionExecuted(
      {
        "type": "is_visible",
      },
    );
    return didSucceeded;
  }

  /// Tries to perform a click on this `element` &
  /// returns `true` or `false` accordingly.
  Future<bool> click() async {
    final (didSucceeded, _) = await onActionExecuted(
      {
        "type": "click",
      },
    );
    return didSucceeded;
  }
}
