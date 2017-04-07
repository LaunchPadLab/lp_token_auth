require 'minitest/autorun'
require 'lp_token_auth/controller'

def token_with_context
  { token: 'xyz987', context: 'admin' }
end

def token_str
  'abc123'
end

def cookie_str
  { lp_auth: token_str }
end

def header_str
  { 'Authorization' => token_str }
end

def cookie_obj
  { lp_auth: token_with_context.to_json }
end

def header_obj
  { 'Authorization' => "Token #{token_with_context.to_json}" }
end

def initialize_token_config(token_type)
  LpTokenAuth.config do |config|
    config.token_transport = [token_type]
    config.secret = 'ABC123'
    config.expires = 7 * 24
    config.algorithm = 'HS512'
  end
end

class MockUser
  def id
    1
  end
end

class MiniTest::Test
  include LpTokenAuth::Controller
  attr_accessor :cookies, :request
end

class ControllerTest < MiniTest::Test

  describe '.login' do
    before do
      initialize_token_config(:cookie)
      self.cookies = {}
    end

    it 'sets current user and token' do
      assert login(MockUser.new, 'admin')
    end
  end

  describe '.get_token' do
    describe 'with a cookie token' do
      before do
        initialize_token_config(:cookie)
      end

      describe 'when the cookie is an object' do
        before do
          self.cookies = cookie_obj
        end

        it 'returns the cookie token' do
          assert_equal get_token, token_with_context[:token]
        end
      end

      describe 'when the cookie is a string' do
        before do
          self.cookies = cookie_str
        end

        it 'returns the cookie token' do
          assert_equal get_token, token_str
        end
      end
    end

    describe 'with a header token' do
      before do
        initialize_token_config(:header)
        self.cookies = {}
      end

      describe 'when the header is an object' do
        before do
          request_hash = { headers: header_obj }
          self.request = OpenStruct.new(request_hash)
        end

        it 'returns the header token' do
          assert_equal get_token, token_with_context[:token]
        end
      end

      describe 'when to header is a string' do
        before do
          request_hash = { headers: header_str }
          self.request = OpenStruct.new(request_hash)
        end

        it 'returns the header token' do
          assert_equal get_token, token_str
        end
      end
    end
  end
end

