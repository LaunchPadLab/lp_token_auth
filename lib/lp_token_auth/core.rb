require 'jwt'
require 'jwe'
require 'lp_token_auth/error'

module LpTokenAuth
  # The `LpTokenAuth` class performs all of the logic of encoding and decoding JWT tokens,
  # and raises appropriate error messages if any errors occur.
  class << self
    
    # Encodes the JWT token with the payload
    # @param [Integer, String] id the identifier of the resource
    # @param [Symbol=>String] payload keyword arguments required to create the token
    # @raise [LpTokenAuth::Error] if the `id` is not a `String` or `Integer`
    # @return [String] encoded token
    def issue_token(id, **payload)

      check_id!(id)

      payload[:id] = id

      unless payload.has_key? :exp
        payload[:exp] = (Time.now + LpTokenAuth.config.get_option(:expires) * 60 * 60).to_i
      end

      jwt = JWT.encode(
        payload,
        LpTokenAuth.config.get_option(:secret),
        LpTokenAuth.config.get_option(:algorithm)
      )

      JWE.encrypt(jwt, private_key, enc: LpTokenAuth.config.get_option(:jwe_encryption))
    end

    # Decodes the JWT token
    # @param [String] token the token to decode
    # @raise [LpTokenAuth::Error] if the token is expired, or if any errors occur during decoding
    # @return [Array] decoded token
    def decode!(encrypted_token)
      begin
        token = JWE.decrypt(encrypted_token, private_key)
        JWT.decode(
          token,
          LpTokenAuth.config.get_option(:secret),
          true,
          algorithm: LpTokenAuth.config.get_option(:algorithm)
        ).first
      rescue JWT::ExpiredSignature => msg
        raise LpTokenAuth::Error, msg
      rescue StandardError => msg
        raise LpTokenAuth::Error, msg
      end
    end

    # Determines if the `id` provided is either a `String` or an `Integer`
    # @param [Integer, String] id the identifier of the resource
    # @raise [LpTokenAuth::Error] if the `id` is not a `String` or `Integer`
    # @return [nil]
    def check_id!(id)
      unless id.is_a?(String) || id.is_a?(Integer)
        raise LpTokenAuth::Error, "id must be a string or integer, you provided #{id}"
      end
    end

    private

    def private_key
      key = LpTokenAuth.config.get_option(:jwe_private_key)
      raise LpTokenAuth::Error, 'You do not have a private key.' if key.nil?

      OpenSSL::PKey::RSA.new(key.split("\\n").join("\n"))
    rescue OpenSSL::PKey::RSAError => msg
      raise LpTokenAuth::Error, 'Your private key is formatted incorrectly.'
    end
  end
end
