from ssrspeed.type.node.basis import BasisNode


class NodeHysteria(BasisNode):
    def __init__(self, config: dict):
        super().__init__(config)
        self._type = "Hysteria"


class NodeHysteria2(BasisNode):
    def __init__(self, config: dict):
        super().__init__(config)
        self._type = "Hysteria2"
