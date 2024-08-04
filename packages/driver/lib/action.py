from enum import Enum


class ActionKind(Enum):
    FRAMEWORK = "framework"
    ELEMENT = "element"


class PressKind(Enum):
    NOMRAL = "normal_press"
    LONG = "long_press"


class PumpKind(Enum):
    NORMAL = "normal"
    SETTLE = "settle"
