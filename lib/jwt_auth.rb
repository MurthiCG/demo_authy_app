# frozen_string_literal: true

class JwtAuth
  def self.configuration
    @algorithm = 'HS256'
    @key = Digest::SHA256.digest('Dummy App')
    @expiration = Time.now.to_i + 1.week.to_i
  end

  def self.encode(hash)
    configuration
    hash[:exp] = @expiration
    JWT.encode(hash, @key, @algorithm)
  end

  def self.decode(token)
    configuration
    begin
      JWT.decode(token, @key, true, { algorithm: @algorithm }).first
    rescue StandardError
      {}
    end
  end
end
