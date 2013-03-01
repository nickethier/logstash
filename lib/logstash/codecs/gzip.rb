require 'logstash/namespace'
require 'logstash/codecs/base'
require 'logstash/codecs/plain'
require "zlib"
require "base64"

class LogStash::Codecs::Gzip < LogStash::Codecs::Base

  def initialize(queue=nil)
    @plain = LogStash::Codecs::Plain.new(queue)
    @buffer = ""
  end

  def decode_data(data, opts = {})
    @plain.charset = @charset
    Zlib::GzipReader.new(StringIO.new(data)).each_line do |line|
      if line[-1] == "\n"
        @plain.decode_data((@buffer+line).chomp, opts)
        @buffer = ""
      else
        @buffer += line
      end
    end
  end

  def encode_data(event)
    @on_event.call(Zlib::Deflate.deflate(event.to_s))
  end

end