class Security < ActiveRecord::Base
  require 'rc4'
  require 'base64'

  def self.rc4_encrypt(str)
    key = Digest::SHA256.hexdigest('jeon_S@lt_#2211').upcase
    enc = RC4.new(key)
    return Base64.strict_encode64(enc.encrypt(str))
  end

  def self.rc4_decrypt(str)
    key = Digest::SHA256.hexdigest('jeon_S@lt_#2211').upcase
    dec = RC4.new(key)
    return dec.decrypt(Base64.decode64(str))
  end

  def self.is_complex_password(str, complexity_level)
    has_uppercase = str.match(/[A-Z]/) ? 1 : 0
    has_lowercase = str.match(/[a-z]{1}/) ? 1 : 0
    has_extra_chars = str.match(/\W/) ? 1 : 0
    has_digits = str.match(/\d/) ? 1 : 0

    score = has_uppercase + has_digits + has_extra_chars + has_lowercase
    return score >= complexity_level
  end

  def self.sha256(str)
    return Digest::SHA256.hexdigest('jeon_S@lt_#2211' + str).upcase
  end

end
