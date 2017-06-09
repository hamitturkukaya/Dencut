class Graph
  attr_reader :edges
  def initialize(node_count)
    @edges = (0..node_count).to_a.map { Array.new(node_count, false) }
  end

  def add_edge(source, dest)
    @edges[source][dest] = true
    @edges[dest][source] = true
  end
end