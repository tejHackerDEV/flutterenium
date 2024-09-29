from enum import Enum

from .driver import ActionKind
from .internal import utils


class FinderKind(Enum):
    LABEL = "label"
    TEXT = "text"
    SVG = "svg"
    ICON = "icon"


class By:
    def __init__(self, value: str | int, kind: FinderKind):
        """Initializes the By class with a value and a finder type.

        Args:
            value (str): The value used for finding elements.
            finder_type (FinderKind): The type of finding mechanism.
        """
        self.value = value
        self.kind = kind

    @classmethod
    def label(cls, label: str) -> "By":
        """
        Factory method to create a By instance using label.

        Args:
            text (str): The text to find the element.

        Returns:
            By: instance with LABEL FinderKind.
        """
        return cls(value=label, kind=FinderKind.LABEL)

    @classmethod
    def text(cls, text: str) -> "By":
        """
        Factory method to create a By instance using text.

        Args:
            text (str): The text to find the element.

        Returns:
            By: instance with TEXT FinderKind.
        """
        return cls(value=text, kind=FinderKind.TEXT)

    @classmethod
    def svg(cls, text: str) -> "By":
        """
        Factory method to create a By instance using svg.

        Args:
            text (str): The svg to find the element.

        Returns:
            By: instance with SVG FinderKind.
        """
        return cls(value=text, kind=FinderKind.SVG)

    @classmethod
    def icon(cls, value: int) -> "By":
        """
        Factory method to create a By instance using icon.

        Args:
            value (int): The CharCode to find the icon element.

        Returns:
            By: instance with ICON FinderKind.
        """
        return cls(value=value, kind=FinderKind.ICON)

    def _to_action(self):
        name = self.kind.value
        return utils.to_action(
            ActionKind.FRAMEWORK,
            {
                "type": "find",
                "data": {
                    "type": name,
                    "data": {
                        name: self.value,
                    },
                },
            },
        )
