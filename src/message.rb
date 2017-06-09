class Message
  attr_accessor :message_type, :source, :destination, :value
  def initialize(options = {})
    @message_type = options.delete :message_type
    @source       = options.delete :source
    @destination  = options.delete :destination
    @value        = options.delete :value
  end

  def receive_format(id)
    if @destination == id
      "#{@message_type}: #{@destination} <- #{@source} - #{@value}"
    else
      "#{@message_type}: #{id} overheared #{@destination} <- #{@source} - #{@value}"
    end
  end

  def send_format(id)
    "#{@message_type}: #{@source} Sent Message To #{@destination}"
  end
end