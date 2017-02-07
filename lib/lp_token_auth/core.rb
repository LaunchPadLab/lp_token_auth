require 'jwt'
require 'lp_token_auth/error'

module LpTokenAuth
  class << self
    def issue_token(id, **payload)
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
  end
end
