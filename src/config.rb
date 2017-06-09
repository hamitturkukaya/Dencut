require_relative 'graph'
require_relative 'message'
require_relative 'message_types'
require_relative 'states'

NODE_COUNT = 10
MESSAGE_QUEUE = (0..NODE_COUNT).to_a.map{Queue.new}
GRAPH = Graph.new(NODE_COUNT)

GRAPH.add_edge(0, 1)
GRAPH.add_edge(1, 2)
GRAPH.add_edge(1, 3)
GRAPH.add_edge(1, 4)
GRAPH.add_edge(3, 5)
GRAPH.add_edge(3, 6)
GRAPH.add_edge(4, 6)
GRAPH.add_edge(5, 6)
GRAPH.add_edge(5, 8)
GRAPH.add_edge(6, 7)
GRAPH.add_edge(7, 9)

# NODE_COUNT = 9
# GRAPH.add_edge(0,1)
# GRAPH.add_edge(0,2)
# GRAPH.add_edge(0,4)
# GRAPH.add_edge(1,2)
# GRAPH.add_edge(2,3)
# GRAPH.add_edge(3,4)
# GRAPH.add_edge(4,5)
# GRAPH.add_edge(5,6)
# GRAPH.add_edge(5,7)
# GRAPH.add_edge(6,7)
# GRAPH.add_edge(7,8)
root = 0
MESSAGE_QUEUE[root] << Message.new(message_type: Messages::START, destination: root)