require "logstash/codecs/encryption"
require "logstash/event"
require "insist"

describe LogStash::Codecs::Encryption do
  subject do
    next LogStash::Codecs::Encryption.new(
      "public_key" => "./spec/codecs/encryption/public.key",
      "private_key" => "./spec/codecs/encryption/private.key",
      "private_key_passphrase" => "logstash")
  end

  context "#decode" do
    it "should return decrypted data" do
      data = {"foo" => "bar", "baz" => {"bah" => ["a","b","c"]}}
      subject.on_event do |d|
        subject.decode(d) do |event|
          insist { event } == data.to_json
        end
      end
      subject.encode(data)
    end
  end
end
