require_relative 'base_node'

class Node < BaseNode
  attr_reader :neighbours, :states, :low, :depth, :cut_vertex

  def initialize(id)
    super(id)
    @neighbours = GRAPH.edges[@id]
    @states = GRAPH.edges[@id].map{|x| x ? States::UNVISITED : -1}
    @low = 999
    @depth = 999
    @cut_vertex = false
    @neighbour_count = @neighbours.select{|n| n}.count
  end

  def start_operation
    listen_proc   = Proc.new {|message| message_received(message)}
    complete_proc = Proc.new {report_to_sink}
    listen_message(listen_proc, complete_proc)
  end

  private

  def message_received(message = Message.new)
    destination = message.destination
    case message.message_type
      when Messages::START
        if destination == @id
          @root = true
          @low = 0
          @depth = 0
          discover_neighbour
        end
      when Messages::DISCOVER
        if destination == @id && @parent == nil && @neighbour_count > 1
          @parent = message.source
          @depth = message.value
          @low = [@low, @depth].min
          @states[message.source] = States::PARENT
          discover_neighbour
        elsif @neighbour_count != 1
          @low = [@low, message.value - 1].min
          @states[message.source] = States::BACK_NODE
        elsif @neighbour_count == 1 && !@root
          @parent = message.source
          @depth = message.value
          @low = [@low, message.value - 1].min
          message = Message.new(message_type: Messages::FINISH, source: @id, destination: @parent)
          send_message(message)
          @completed = true
        end
      when Messages::BACKTRACK
        if destination == @id
          @states[message.source] == States::BACK_CHILD
          @low = [@low, message.value].min
          if @depth <= message.value && !@root
            @cut_vertex = true
          elsif @root && (@states.select {|x| x == States::BACK_CHILD}.count >= 2 || @states.select {|x| x == States::CHILD}.count >= 2)
            @cut_vertex = true
          end
          discover_neighbour
        else
          @states[message.source] = States::BACK_NODE
        end
      when Messages::FINISH
        if @states[message.source] == States::CHILD
          @states[message.source] == States::BACK_CHILD
          discover_neighbour
        end
        @states[message.source] == States::BACK_CHILD
        @cut_vertex = true
      else
        raise Exception('You shouln\t be here!')
    end
  end

  def discover_neighbour
    if @states.select{|n| n == States::UNVISITED}.count > 0
      j_id = @states.rindex(States::UNVISITED)
      @states[j_id] = States::CHILD
      @neighbours.each_with_index do |neighbour, index|
        if neighbour
          message = Message.new(message_type: Messages::DISCOVER, source: @id, destination: j_id, value: @depth + 1)
          send_message(message, index)
        end
      end
    elsif @states.select{|n| n == States::UNVISITED}.count == 0
      if @root
        report_to_sink
      else
        message = Message.new(message_type: Messages::BACKTRACK, source: @id, destination: @parent, value: @low)
        send_message(message)
      end
      @completed = true
    end
  end

  def report_to_sink
    puts '*'*40
    puts 'Finished'
    puts '*'*40
  end
end
