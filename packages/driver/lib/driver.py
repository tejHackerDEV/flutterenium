from enum import Enum
import uuid

from selenium import webdriver

from .action import *
from .element import *
from .finder import *
from .internal.actions_data import *
from .internal.constants import *
from .internal.typedefs import *

import lib.internal.utils as utils


class BrowserKind(Enum):
    CHROME = 0
    FIREFOX = 1


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
            with_browser (bool, optional): If `True` then entire browser closes,
            else only closes the window. Defaults to False.
        """
        if not with_browser:
            self.__driver.close()
            return
        self.__driver.quit()

    def __execute_actions(self, actions: list[Action]) -> ActionResponse:
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

        return Element(
            on_actions_executed=lambda data: on_element_actions_executed(
                find_action=by._to_action(),
                data=data,
                callback=self.__execute_actions,
            )
        )

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
                utils.to_action(
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
