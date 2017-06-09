require_relative 'config'

class BaseNode
  attr_reader :id
  def initialize(id)
    @id = id
    @root = false
    @parent = nil
    @semaphore = Mutex.new
    @completed = false
    @log_enabled = true
  end

  def send_message(message = Message.new, overhear = nil)
    @semaphore.lock
    puts message.send_format(overhear || message.destination) if @log_enabled
    MESSAGE_QUEUE[overhear || message.destination] << message
    @semaphore.unlock
  end

  def listen_message(listen_proc, complete_proc)
    time = 0.0
    until @completed
      sleep 0.5
      time += 0.5
      if MESSAGE_QUEUE[@id].size > 0
        @semaphore.lock
        message = MESSAGE_QUEUE[@id].pop(non_block=true)
        @semaphore.unlock
        time = 0
        puts message.receive_format(@id) if @log_enabled
        listen_proc.call(message)
      end
      @completed = time >= 5
      complete_proc.call if @completed && @root
    end
  end
end