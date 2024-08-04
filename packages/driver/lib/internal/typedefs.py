from typing import Any, Optional, Union

ActionData = Optional[Union[dict[str, Any], list[dict[str, Any]]]]
ActionResponse = tuple[bool, dict | None]
Action = dict[str, Any]
