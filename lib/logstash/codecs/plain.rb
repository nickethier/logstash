require 'logstash/namespace'
require 'logstash/codecs/base'

class LogStash::Codecs::Plain < LogStash::Codecs::Base

  def decode_data(data, opts = {})
    event = LogStash::Event.new(opts)
    data.force_encoding(@charset)
    if @charset != "UTF-8"
      # Convert to UTF-8 if not in that character set.
      data = data.encode("UTF-8", :invalid => :replace, :undef => :replace)
    end
    event.message = data
    @queue << event
  end

  def encode_data(event)
    @on_event.call(event.to_s)
  end

end