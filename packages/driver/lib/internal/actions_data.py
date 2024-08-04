from ..action import ActionKind
from . import utils


class ElementActionsData(list):
    def __init__(self, arg):
        super().__init__()
        self.append(arg)

    def __transform(self, item):
        enum_values = [kind.value for kind in ActionKind]
        if item.get("type", None) in enum_values:
            return item
        return utils.to_action(ActionKind.ELEMENT, item)

    def insert(self, index, item):
        super().insert(index, self.__transform(item))

    def append(self, item):
        super().append(self.__transform(item))

    def extend(self, iterable):
        super().extend([self.__transform(item) for item in iterable])
