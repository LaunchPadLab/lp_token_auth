require 'jwt'
require 'lp_token_auth/error'

module LpTokenAuth
  class << self
    
    # Encodes the JWT token
    # @param [Integer, String] id the id of the resource
    # @param [Symbol=>String] payload keyword arguments required to create the token
    # @return [String] token
    def issue_token(id, **payload)

      check_id!(id)

      payload[:id] = id

      unless payload.has_key? :exp
        payload[:exp] = (Time.now + LpTokenAuth.config.expires * 60 * 60).to_i
      end

      JWT.encode(
        payload,
        LpTokenAuth.config.secret,
        LpTokenAuth.config.algorithm
      )
    end

    # Decodes the JWT token
    # @param [String] token the token to decode
    # @raise [LpTokenAuth::Error] if the token is expired, or if any errors occur during decoding
    # @return [String] token
    def decode!(token)
      begin
        JWT.decode(
          token,
          LpTokenAuth.config.secret,
          true,
          { algorithm: LpTokenAuth.config.algorithm }
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
    def check_id!(id)
      unless id.is_a?(String) || id.is_a?(Integer)
        raise LpTokenAuth::Error, "id must be a string or integer, you provided #{id}"
      end
    end
  end
end
