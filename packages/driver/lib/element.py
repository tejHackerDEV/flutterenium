from typing import Callable, Any, Optional


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

    def click(self) -> bool:
        """
        Tries to perform a click on the element and returns `True` if succeeded, otherwise `False`.
        """
        did_succeed, _ = self.__on_action_executed(
            {
                "type": "click",
            },
        )
        return did_succeed
