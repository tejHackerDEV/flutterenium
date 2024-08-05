from enum import Enum


class ActionKind(Enum):
    FRAMEWORK = "framework"
    ELEMENT = "element"


class PressKind(Enum):
    NOMRAL = "normal"
    LONG = "long"


class PumpKind(Enum):
    NORMAL = "normal"
    SETTLE = "settle"
