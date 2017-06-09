require_relative 'src/node'

threads = []
nodes = []
NODE_COUNT.times do |i|
  threads << Thread.new {
    node = Node.new(i)
    nodes << node
    node.start_operation
  }
end

threads.map{|thr| thr.join}

puts 'Cut Vertices: ' + nodes.select{|x| x.cut_vertex}.map{|x| x.id }.inspect