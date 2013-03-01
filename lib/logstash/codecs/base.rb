require "logstash/namespace"
require "logstash/event"
require "logstash/plugin"
require "logstash/logging"

# This is the base class for logstash codecs.
module LogStash::Codecs
  public
  def self.for(codec)
    return codec if codec.is_a? Class

    #TODO: codec paths or just use plugin paths
    plugin = File.join('logstash', 'codecs', codec) + ".rb"
    #@logger.info "Loading codec", :codec => plugin
    require plugin
    klass_name = codec.capitalize
    if LogStash::Codecs.const_defined?(klass_name)
      return LogStash::Codecs.const_get(klass_name)
    end
    nil
  end

  class Base < LogStash::Plugin

    attr_reader :queue, :on_event
    attr_accessor :charset

    public
    def initialize(queue=nil)
      @queue = queue
    end # def initialize

    public
    def decode_data(data, opts = {})
      raise "#{self.class}#register must be overidden"
    end # def decode

    alias_method :<<, :decode_data

    public
    def encode_data(data)
      raise "#{self.class}#register must be overidden"
    end # def encode

    public
    def on_event(&block)
      @on_event = block
    end

  end # class LogStash::Codecs::Base
end

