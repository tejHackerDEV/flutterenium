from typing import Callable, Any, Optional
from enum import Enum


class PressKind(Enum):
    NOMRAL = "normal_press"
    LONG = "long_press"


class Element:
    def __init__(
        self, on_action_executed: Callable[[dict[str, Any]], tuple[bool, dict | None]]
    ):
        self.__on_action_executed = on_action_executed

    def find(self) -> bool:
        """
        Finds the element and returns `True` if found, otherwise `False`.

        Note: This method does not check if the element is currently visible on the screen. To check visibility, use `is_visible`.
        """
        did_succeed, _ = self.__on_action_executed(None)
        return did_succeed

    def get_text(self) -> Optional[str]:
        """
        Gets the text of the element and returns it if found, otherwise returns `None`.
        """
        did_succeed, data = self.__on_action_executed(
            {
                "type": "get_text",
            },
        )
        return data.get("text") if did_succeed else None

    def set_text(self, text: str) -> bool:
        """
        Sets the text for the element and returns `True` if succeeded, otherwise `False`.

        Args:
            text: The text to set for the element.
        """
        did_succeed, _ = self.__on_action_executed(
            {
                "type": "set_text",
                "data": {
                    "text": text,
                },
            }
        )
        return did_succeed

    def scroll_by(self, delta: float, duration: Optional[int] = None) -> bool:
        """
        Scrolls the element by a specified number of pixels.

        Args:
            delta: The number of pixels to scroll.
            duration: The duration in milliseconds for scrolling. If `None`, it will jump directly to the location.
        """
        did_succeed, _ = self.__on_action_executed(
            {
                "type": "scroll",
                "data": {
                    "delta": delta,
                    "milliseconds": duration,
                },
            }
        )
        return did_succeed

    def is_visible(self) -> bool:
        """
        Checks whether the element is visible on the screen and returns `True` or `False` accordingly.
        """
        did_succeed, _ = self.__on_action_executed(
            {
                "type": "is_visible",
            },
        )
        return did_succeed

    def press(self, kind: PressKind = PressKind.NOMRAL) -> bool:
        """
        Tries to perform a click on the element

        Args:
            kind (PressKind, optional): If this is normal it just does a regular click.
            If this is long it performs an long click. Defaults to PressKind.NOMRAL.

        Returns:
            bool: `True` if succeeded, otherwise `False`.
        """
        did_succeed, _ = self.__on_action_executed(
            {
                "type": "press",
                "data": {
                    "type": kind.value,
                }
            },
        )
        return did_succeed
