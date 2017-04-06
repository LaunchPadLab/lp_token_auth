module LpTokenAuth
  class AuthToken
    attr_accessor :cookies

    def initialize(args={})
      @cookies = args[:cookies]
    end

    def cookie_token
      parse_cookie_token || cookies[:lp_auth]
    end

    def header_token
      parse_header_token || fetch_header_auth
    end

    private

    def parse_cookie_token
      begin
        parsed_cookie = JSON.parse(cookies[:lp_auth])
        parsed_cookie.fetch('token', nil)
      rescue JSON::ParserError
        return nil
      end
    end

    def fetch_header_auth
      request.headers.fetch('Authorization', '').split(' ').last
    end

    def parse_header_token
      fetch_header_auth.fetch('token', '')
    end
  end
end
