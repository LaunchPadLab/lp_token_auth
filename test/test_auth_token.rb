require 'minitest/autorun'
require 'lp_token_auth/auth_token'

def token_with_options
  { token: 'abc123', options: { user_type: 'test' } }
end

def cookie
  { lp_auth: 'abc123' }
end

describe '.cookie_token' do
  describe 'when a token is nested under \'token\' key' do
    before do
      @token = LpTokenAuth::AuthToken.new(
        cookies: { lp_auth: token_with_options.to_json }
      )
    end

    it 'returns a token' do
      assert_equal @token.cookie_token, token_with_options[:token]
    end
  end

  describe 'when a token is not nested' do
    before do
      @token = LpTokenAuth::AuthToken.new(cookies: cookie)
    end

    it 'returns a token' do
      assert_equal @token.cookie_token, cookie[:lp_auth]
    end
  end
end
