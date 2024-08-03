from enum import Enum
from typing import Any, Optional
import uuid

from selenium import webdriver

from .internal.constants import *
from .element import Element
from .finder import *


class BrowserKind(Enum):
    CHROME = 0
    FIREFOX = 1


class ActionKind(Enum):
    FRAMEWORK = "framework"
    ELEMENT = "element"


class PumpKind(Enum):
    NORMAL = "normal"
    SETTLE = "settle"


class FluttereniumDriver:
    def __init__(self, browser_kind: BrowserKind):
        match browser_kind:
            case BrowserKind.CHROME:
                self.__driver = webdriver.Chrome()
            case BrowserKind.FIREFOX:
                self.__driver = webdriver.Firefox()
            case _:
                raise ValueError("Unhandled browser value")

    def open(self, url: str) -> None:
        """
        Opens the specified url in the browser
        and waits till the `Flutterenium` is ready
        to accepts the requests and adds a eventListener
        to handle the responses emitted by `Flutterenium`

        Args:
            url (str): Path of the website
        """
        self.__driver.get(url)

        self.__driver.execute_async_script(
            """
            const readyEventName = arguments[0];
            const driverReadyName = arguments[1];
            const callback = arguments[arguments.length - 1];
            window.addEventListener(readyEventName, (event) => {
                window[driverReadyName] = true;
                callback();
            }, {once: true});
            """,
            Constants.FLUTTERENIUM_READY_NAME,
            Constants.FLUTTERENIUM_DRIVER_READY_NAME,
        )

        self.__driver.execute_script(
            """
            const eventLogsName = arguments[0];
            const responseEventName = arguments[1];
            // All the event log responses happens via the driver
            // will be flushed into the below object
            window[eventLogsName] = {};
            window.addEventListener(responseEventName, (event) => {
                const {id, ...rest} = event.detail;
                window[eventLogsName][id] = rest;
            });
            """,
            Constants.FLUTTERENIUM_DRIVER_EVENT_LOGS_NAME,
            Constants.FLUTTERENIUM_RESPONSE_EVENT_NAME,
        )

    def close(self, with_browser=False) -> None:
        """
        Closes the current `window` or `browser` instance.

        Args:
            with_browser (bool, optional): If `True` then entire browser closes, else only closes the window. Defaults to False.
        """
        if not with_browser:
            self.__driver.close()
            return
        self.__driver.quit()

    def __execute_actions(
        self, actions: list[dict[str, Any]]
    ) -> tuple[bool, dict | None]:
        id = str(uuid.uuid4())
        self.__driver.execute_script(
            """
            const id = arguments[0];
            const requestEventName = arguments[1];
            const actionsToExecute = arguments[2];
            window.dispatchEvent(
                new CustomEvent(
                    requestEventName,
                    {
                        detail: {
                            "id": id,
                            "actions": actionsToExecute
                        }
                    }
                )
            );
            """,
            id,
            Constants.FLUTTERENIUM_REQUEST_EVENT_NAME,
            actions,
        )
        response = None
        while response is None:
            response = self.__driver.execute_script(
                """
                const id = arguments[0];
                const eventLogsName = arguments[1];
                return window[eventLogsName][id];
                """,
                id,
                Constants.FLUTTERENIUM_DRIVER_EVENT_LOGS_NAME,
            )
        did_succeeded = bool(response["didSucceeded"])
        data = None
        if did_succeeded:
            data = response["data"]

        if data:
            data = dict(data)
        return (did_succeeded, data)

    def __to_action(self, kind: ActionKind, data: dict[str, Any]) -> dict[str, Any]:
        """
        Use this to convert data into an `Flutterenium` action

        Args:
            kind (ActionKind): into what the action we want to convert
            data (dict[str, Any]): any data that is required by the action while performing

        Returns:
            dict[str, Any]: an action which is converted as per the specified kind
        """
        return {"type": kind.value, "data": data}

    def get(self, by: By) -> Element:
        """
        Get an element no matter whether an element is actually present
        or not. One should use the `actions` to test whether
        element is actually present or not.

        Args:
            by (By): Based on how we need to find the element in order to perform actions

        Returns:
            Element: one should use this as a handle to perform actions
        """
        name = by.kind.value
        find_data = {
            "type": "find",
            "data": {
                "type": name,
                "data": {
                    name: by.value,
                },
            },
        }

        def on_action_executed(
            data: Optional[dict[str, Any]]
        ) -> tuple[bool, dict | None]:
            actions = [self.__to_action(ActionKind.FRAMEWORK, find_data)]
            if data is not None:
                actions.append(self.__to_action(ActionKind.ELEMENT, data))

            return self.__execute_actions(actions)

        return Element(on_action_executed=on_action_executed)

    def pump(self, kind: PumpKind = PumpKind.NORMAL) -> bool:
        """
        This will helpful when we want to wait till the frame/frames gets completed

        Args:
            kind (PumpKind, optional): PumpKind.NORMAL will wait till the current frame gets completed,
              while PumpKind.SETTLE will wait till all the scheduled frames got completed. Defaults to PumpKind.NORMAL.

        Returns:
            bool: `True` if succeeded, else `False`
        """
        (didSucceeded, _) = self.__execute_actions(
            [
                self.__to_action(
                    ActionKind.FRAMEWORK,
                    {
                        "type": "pump",
                        "data": {
                            "type": kind.value,
                        },
                    },
                )
            ],
        )
        return didSucceeded
