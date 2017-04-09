require 'lp_token_auth/core'
require 'json'

module LpTokenAuth
  module Controller
    def login(user, context='')
      token = LpTokenAuth.issue_token(user.id)
      set_current_user user
      set_token token, context
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

    def set_token(token, context)
      lp_auth_cookie = { token: token, context: context }.to_json
      cookies[:lp_auth] = lp_auth_cookie if includes_transport?(:cookie)
      response.headers['X-LP-AUTH'] = lp_auth_cookie if includes_transport?(:header)
    end

    def clear_token
      cookies.delete :lp_auth if includes_transport?(:cookie)
    end

    def get_token
      [cookie_token, header_token].compact.first
    end

    def cookie_token
      return nil unless includes_transport?(:cookie)
      parse_token(cookies[:lp_auth])
    end

    def header_token
      return nil unless includes_transport?(:header)
      parse_token(fetch_header_auth)
    end

    def fetch_header_auth
      request.headers.fetch('Authorization', '').split(' ').last
    end

    def parse_token(token_path)
      return nil unless token_path
      begin
        parsed = JSON.parse(token_path)
        parsed.fetch('token', nil)
      rescue JSON::ParserError
        token_path
      end
    end

    def includes_transport?(type)
      LpTokenAuth.config.token_transport.include?(type)
    end
  end
end
