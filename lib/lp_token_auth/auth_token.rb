require 'json'

module LpTokenAuth
  class AuthToken
    attr_accessor :cookies, :request_headers

    def initialize(args={})
      @cookies = args[:cookies]
      @request_headers = args[:request_headers]
    end

    def cookie_token
      return nil unless cookies[:lp_auth]
      parse_cookie_token || cookies[:lp_auth]
    end

    def header_token
      parse_header_token || fetch_header_auth if request_headers
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
      request_headers.fetch('Authorization', '').split(' ').last
    end

    def parse_header_token
      begin
        parsed_header = JSON.parse(fetch_header_auth)
        parsed_header.fetch('token', nil)
      rescue JSON::ParserError
        return nil
      end
    end
  end
end
