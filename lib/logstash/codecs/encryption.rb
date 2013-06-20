require "logstash/codecs/base"
require "openssl"

class LogStash::Codecs::Encryption < LogStash::Codecs::Base
  config_name "encryption"

  plugin_status "experimental"

  config :public_key, :validate => :string, :default => nil

  config :private_key, :validate => :string, :default => nil

  config :private_key_passphrase, :validate => :string, :default => nil

  config :cipher, :validate => :string, :default => "aes-256-cbc"

  public
  def decode(data)
    # Expect a hash with { 'iv' => <encrypted_iv>, 'key' => <encrypted_key>, 
    #   'data' => <encrypted_data>}
    # Or Logstash::Event with the same fields.

    key = OpenSSL::PKey::RSA.new(File.read(@private_key),@private_key_passphrase)

    cipher = OpenSSL::Cipher::Cipher.new(@cipher)
    cipher.decrypt
    cipher.key = key.private_decrypt(data['key'])
    cipher.iv = key.private_decrypt(data['iv'])

    decrypted_data = cipher.update(data['data'])
    decrypted_data << cipher.final
    yield decrypted_data
  end # def decode

  public
  def encode(event)
    cipher = OpenSSL::Cipher::Cipher.new(@cipher)
    cipher.encrypt

    cipher.key = random_key = cipher.random_key
    cipher.iv = random_iv = cipher.random_iv

    encrypted_data = cipher.update(event.to_json)
    encrypted_data << cipher.final

    public_key = OpenSSL::PKey::RSA.new(File.read(@public_key))

    encrypted_key = public_key.public_encrypt(random_key)
    encrypted_iv = public_key.public_encrypt(random_iv)

    @on_event.call ({'iv' => encrypted_iv, 'key' => encrypted_key, 'data' => encrypted_data})
  end # def encode

end # class LogStash::Codecs::Msgpack
