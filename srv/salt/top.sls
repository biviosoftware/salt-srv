#!py
# -*-python-*-

def run():
    """Include bivio:state_trees in the order they need to run.

    state_trees are "state files" with dependencies specified
    in pillars as follows::

        bivio:
          state_trees:
            utilities:
               include: True
               require: []
            jupyterhub:
               include: True
               require: [ utilities ]

    jupyterhub depends on utilities. If include is False, they
    won't be included in the list of state trees to run.
    """
    todo = {}
    for k, v in __pillar__['bivio']['state_trees'].iteritems():
        if v and v['include']:
            todo[k] = v['require']

    return {
        'base': {
            '*': _toposort(todo)
        },
    }


def _toposort(todo):
    """Topological sort dependencies"""
    done = {}
    res = []

    def _visit(node):
        if node in done:
            assert done[node], '{}: not a DAG'.format(node)
            return
        done[node] = False
        for edge in todo[node]:
            _visit(edge)
        done[node] = True
        res.append(node)

    nodes = sorted(todo.keys())
    for n in nodes:
        if not n in done:
            _visit(n)
    print res
    return res
