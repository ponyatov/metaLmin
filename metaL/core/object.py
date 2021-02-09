
# ========== base graph node class / generic knowledge representation (AST/ASG)
class Object():

    # node constructor with scalar initializer
    def __init__(self, V):
        # node class/type tag
        self.type = self.__class__.__name__.lower()
        # node name / scalar value
        self.value = V
        # slot{}s / attributes / associative array
        self.slot = {}
        # nest[]ed elements / ordered container
        self.nest = []

    ## ============================================================== text dump

    # `print` callback method
    def __repr__(self): return self.dump()

    # pytest: dump without id,hashes,..
    def test(self): return self.dump(test=True)

    # full text tree dump
    def dump(self, cycle=[], depth=0, prefix='', test=False):
        # head
        ret = self.pad(depth) + self.head(prefix, test)
        # cycle
        if self in cycle:
            return ret + ' _/'
        # slot{}s
        for i in self.keys():
            ret += self[i].dump(cycle + [self], depth + 1, f'{i} = ', test)
        # nest[]ed
        for j, k in enumerate(self.nest):
            ret += k.dump(cycle + [self], depth + 1, f'{j}: ', test)
        # subtree
        return ret

    # tree padding
    def pad(self, depth): return '\n' + '\t' * depth

    # short `<T:V>`` header-only dump
    def head(self, prefix='', test=False):
        ret = f'{prefix}<{self.type}:{self.value}>'
        if not test:
            ret += f' @{id(self):x}'
        return ret

    ## ============================================================== operators

    # ` S.keys() ` sorted slot keys

    def keys(self):
        return sorted(self.slot.keys())

    def __getitem__(self, key):
        assert isinstance(key, str)
        return self.slot[key]

    def __setitem__(self, key, that):
        assert isinstance(key, str)
        assert isinstance(that, Object)
        self.slot[key] = that
        return self

    def __lshift__(self, that):
        return self.__setitem__(that.type, that)

    def __rshift__(self, that):
        return self.__setitem__(that.value, that)

    # ` A // B ` push subgraph
    def __floordiv__(self, that):
        assert isinstance(that, Object)
        self.nest += [that]
        return self

    ## ======================================================= graph evaluation

    def eval(self, env): raise NotImplementedError(self.eval)
