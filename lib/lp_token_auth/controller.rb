require 'lp_token_auth/core'

module LpTokenAuth
  module Controller
    def login(user, options={})
      token = LpTokenAuth.issue_token(user.id)
      set_current_user user
      set_token token, options
      token
    end

    def logout
      clear_token
    end

    def authenticate_request!(resource=:user)
      token = get_token
      authenticate_token! token, resource
    end

    def authenticate_token!(token, resource=:user)
      begin
        decoded = LpTokenAuth.decode!(token)
        klass = resource.to_s.classify.constantize
        @current_user = klass.find(decoded['id'])
      rescue LpTokenAuth::Error => error
        logout
        raise error
      rescue => error
        logout
        raise LpTokenAuth::Error, error
      end
    end

    def current_user
      @current_user
    end

    private

    def set_current_user(user)
      @current_user = user
    end

    def set_token(token, options={})
      if LpTokenAuth.config.token_transport.include? :cookie
        cookies[:lp_auth] = { token: token, options: options }
      end

      if LpTokenAuth.config.token_transport.include? :header
        response.headers['X-LP-AUTH'] = token
      end
    end

    def clear_token
      if LpTokenAuth.config.token_transport.include? :cookie
        cookies.delete :lp_auth
      end
    end

    def get_token
      cookie_token || header_token
    end

    def cookie_token
      cookies[:lp_auth] || cookies[:lp_token_auth][:token]
    end

    def header_token
      request.headers.fetch('Authorization', '').split(' ').last
    end
  end
end
