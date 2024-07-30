from enum import Enum

class FinderKind(Enum):
    LABEL = 'label'
    TEXT = 'text'

class By:
    def __init__(self, value: str, kind: FinderKind):
        """Initializes the By class with a value and a finder type.

        Args:
            value (str): The value used for finding elements.
            finder_type (FinderKind): The type of finding mechanism.
        """
        self.value = value
        self.kind = kind

    @classmethod
    def label(cls, label: str) -> 'By':
        """
        Factory method to create a By instance using label.

        Args:
            text (str): The text to find the element.

        Returns:
            By: instance with LABEL FinderKind.
        """
        return cls(value=label, kind=FinderKind.LABEL)

    @classmethod
    def text(cls, text: str) -> 'By':
        """
        Factory method to create a By instance using text.

        Args:
            text (str): The text to find the element.

        Returns:
            By: instance with TEXT FinderKind.
        """
        return cls(value=text, kind=FinderKind.TEXT)
