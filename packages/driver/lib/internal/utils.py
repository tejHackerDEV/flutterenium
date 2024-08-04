from typing import Any, Callable

from .actions_data import ElementActionsData
from .typedefs import *
from ..driver import ActionKind


def to_action(kind: ActionKind, data: dict[str, Any]) -> dict[str, Any]:
    """
    Use this to convert data into an `Flutterenium` action

    Args:
        kind (ActionKind): into what the action we want to convert
        data (dict[str, Any]): any data that is required by the action while performing

    Returns:
        dict[str, Any]: an action which is converted as per the specified kind
    """
    return {"type": kind.value, "data": data}


def on_element_actions_executed(
    find_action: Action,
    data: ActionData,
    callback: Callable[[ElementActionsData], ActionResponse],
) -> ActionResponse:
    actions = ElementActionsData(find_action)
    if data is not None:
        if isinstance(data, list):
            actions.extend(data)
        else:
            actions.append(data)

    return callback(actions)
