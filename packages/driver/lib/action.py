from enum import Enum
from datetime import timedelta


class ActionKind(Enum):
    FRAMEWORK = "framework"
    ELEMENT = "element"


class PressKind(Enum):
    NOMRAL = "normal"
    LONG = "long"


class PumpKind(Enum):
    NORMAL = "normal"
    SETTLE = "settle"

    def get_default_time_delta(self):
        match self:
            case PumpKind.NORMAL:
                result = timedelta(seconds=0)
            case PumpKind.SETTLE:
                result = timedelta(seconds=10)
            case _:
                raise ValueError("Unhandled pump value")

        return result
