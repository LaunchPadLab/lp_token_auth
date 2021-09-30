require 'test_helper'

def initialize_config
  LpTokenAuth.config do |config|
    config.secret = 'ABC123'
    config.expires = 7 * 24
    config.algorithm = 'HS512'
  end
end

class MockUser
  def id
    3
  end
end

describe '#issue_token' do
  before do
    initialize_config
    @id = 5
  end

  it 'returns a token' do
    assert LpTokenAuth.issue_token(@id)
  end
end

describe '#decode!' do
  before do
    initialize_config
    @id = 5
  end

  it 'reciprocates #issue_token' do
    token = LpTokenAuth.issue_token(@id)
    assert_equal LpTokenAuth.decode!(token)['id'], @id
  end

  it 'raises when invalid' do
    assert_raises LpTokenAuth::Error do
      LpTokenAuth.decode!('foobar')
    end
  end

  it 'raises when expired' do
    token = LpTokenAuth.issue_token(@id, exp: (Time.now - 10000).to_i)
    assert_raises LpTokenAuth::Error do
      LpTokenAuth.decode!(token)
    end
  end

  it 'returns the payload' do
    payload = { foo: 'bar', baz: 'foo' }
    token = LpTokenAuth.issue_token(@id, **payload)
    decoded = LpTokenAuth.decode!(token)
    assert_equal decoded['id'], @id
    assert_equal decoded['foo'], payload[:foo]
    assert_equal decoded['baz'], payload[:baz]
  end
end
