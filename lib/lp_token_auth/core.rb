require 'jwt'
require 'lp_token_auth/error'

module LpTokenAuth
  class << self
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

    def check_id!(id)
      unless id.is_a? String || id.is_a? Integer
        raise LpTokenAuth::Error, "id must be a string or integer, you provided #{id}"
      end
    end
  end
end
