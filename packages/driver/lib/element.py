from typing import Callable, Optional


from .action import PressKind
from .finder import By
from .internal.actions_data import *
from .internal.typedefs import *
from .internal.utils import *


class Element:
    def __init__(
        self,
        on_actions_executed: Callable[[ActionData], ActionResponse],
    ):
        self.__on_action_executed = on_actions_executed

    def get(self, by: By):
        """
        Works same as `driver.get()`, only difference was driver
        will start looking from the root element, where as this
        will start looking from the element on which this was called

        Args:
            by (By): Same as `driver.get()`
        """

        return Element(
            on_actions_executed=lambda data: on_element_actions_executed(
                find_action=by._to_action(),
                data=data,
                callback=self.__on_action_executed,
            ),
        )

    def is_valid(self) -> bool:
        """
        Checks whether the element is a vaid one to peform actions or not.

        Note: This method does not check if the element is currently visible on the screen. To check visibility, use `is_visible`.

        Returns:
            `True` if valid, otherwise `False`
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
                },
            },
        )
        return did_succeed

    def get_preceding_sibling(self, skip_gaps: bool = True):
        """
        This will helpful when we want to get the preceding sibiling of an element

        Args:
            skip_gaps (bool, optional): `True` will skip the empty element which don't have child/children associated to them,
                while `False` will get the sibling even though it is an empty element which doesn't have any child/children with them.

        Returns:
            bool: `True` if succeeded, else `False`
        """
        return Element(
            on_actions_executed=lambda data: on_element_actions_executed(
                find_action=utils.to_action(
                    ActionKind.FRAMEWORK,
                    {
                        "type": "find",
                        "data": {
                            "type": "preceding_sibling",
                            "data": {
                                "skip_gaps": skip_gaps,
                            },
                        },
                    },
                ),
                data=data,
                callback=self.__on_action_executed,
            ),
        )

    def get_following_sibling(self, skip_gaps: bool = True):
        """
        This will helpful when we want to get the following sibiling of an element

        Args:
            skip_gaps (bool, optional): `True` will skip the empty element which don't have child/children associated to them,
                while `False` will get the sibling even though it is an empty element which doesn't have any child/children with them.

        Returns:
            bool: `True` if succeeded, else `False`
        """
        return Element(
            on_actions_executed=lambda data: on_element_actions_executed(
                find_action=utils.to_action(
                    ActionKind.FRAMEWORK,
                    {
                        "type": "find",
                        "data": {
                            "type": "following_sibling",
                            "data": {
                                "skip_gaps": skip_gaps,
                            },
                        },
                    },
                ),
                data=data,
                callback=self.__on_action_executed,
            ),
        )
