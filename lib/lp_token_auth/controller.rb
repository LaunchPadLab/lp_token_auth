require 'lp_token_auth/core'
require 'json'

module LpTokenAuth
  # `LpTokenAuth::Controller` contains the primary functionality of the `LpTokenAuth` gem.
  # The `Controller` module contains the logic around setting and clearing tokens for 
  # a resource, as well as authenticating requests with a token.
  module Controller

    # Creates and sets a JWT token for a resource
    # @param [Object] user the resource
    # @param [String] context any contextual information necessary for authentication
    # @return [String] encoded token
    def login(user, context='')
      token = LpTokenAuth.issue_token(user.id)
      set_current_user user
      set_token token, context
      token
    end

    # Deletes the `lp_auth` key from the `cookies` hash
    # @return [nil]
    def logout
      clear_token
    end

    # Retrieves and authenticates the token for the given resource
    # @param [Symbol, String] resource the symbolized or stringified class of the resource
    # @raise [LpTokenAuth::Error] if the token is invalid or otherwise unable to be decoded
    # @return [Object] @current_user
    def authenticate_request!(resource=:user)
      token = get_token
      authenticate_token! token, resource
    end

    # Decodes the token, and finds and sets the current user
    # @param [String] token the token object
    # @param [Symbol, String] resource the symbolized or stringified class of the resource
    # @raise [LpTokenAuth::Error] if the token is invalid or otherwise unable to decoded
    # @return [Object] @current_user
    def authenticate_token!(token, resource=:user)
      begin
        decoded = LpTokenAuth.decode!(token)
        @current_user = find_lp_resource(resource, decoded)
      rescue LpTokenAuth::Error => error
        logout
        raise error
      rescue => error
        logout
        raise LpTokenAuth::Error, error
      end
    end

    # Helper method to retrieve the current user
    # @return [Object] @current_user
    def current_user
      @current_user
    end

    private

    def set_current_user(user)
      @current_user = user
    end

    def set_token(token, context)
      lp_auth_cookie = { token: token, context: context }.to_json
      cookies[:lp_auth] = lp_auth_cookie if has_transport?(:cookie)
      response.headers['X-LP-AUTH'] = lp_auth_cookie if has_transport?(:header)
    end

    def clear_token
      cookies.delete :lp_auth if has_transport?(:cookie)
    end

    def get_token
      [cookie_token, header_token].compact.first
    end

    def cookie_token
      return nil unless has_transport?(:cookie)
      parse_token(cookies[:lp_auth])
    end

    def header_token
      return nil unless has_transport?(:header)
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

    def has_transport?(type)
      LpTokenAuth.config.get_option(:token_transport).include?(type)
    end

    def find_lp_resource(resource, decoded)
      klass = resource.to_s.classify.constantize
      klass.find(decoded['id'])
    end
  end
end
