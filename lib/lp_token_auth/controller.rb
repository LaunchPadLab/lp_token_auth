require 'lp_token_auth/core'

module LpTokenAuth
  module Controller
    def login(user)
      token = LpTokenAuth.issue_token(user.id)
      set_current_user user

      if LpTokenAuth.config.token_transport.include? :cookie
        cookies[:lp_auth] = {
          value: token,
          expires: LpTokenAuth.config.expires.hours.from_now,
        }
      end

      if LpTokenAuth.config.token_transport.include? :header
        response.headers['X-LP-AUTH'] = token
      end

      return token
    end

    def logout
      if LpTokenAuth.config.token_transport.include? :cookie
        cookies.delete :lp_auth
      end
    end

    def authenticate_request!
      token = cookie_token || header_token
      begin
        authenticate_token! token
      rescue LpTokenAuth::Error => error
        raise error
      rescue => error
        raise LpTokenAuth::Error, error
      ensure
        logout
      end
    end

    def authenticate_token!(token)
      decoded = LpTokenAuth.decode!(token)
      @current_user = User.find(decoded['id'])
    end

    def current_user
      @current_user
    end

    private
    def set_current_user(user)
      @current_user = user
    end

    def cookie_token
      cookies[:lp_auth]
    end

    def header_token
      request.headers.fetch('Authorization', '').split(' ').last
    end
  end
end
