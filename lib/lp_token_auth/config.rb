module LpTokenAuth
  # `LpTokenAuth::Config` manages the configuration options for tokenable actions. These can be set with the initializer provided with the generator.
  class Config
    # Creates virtual attributes for configuration options:
    # * `algorithm` is a string corresponding to token encryption algorithm to use
    # * `expires` is an integer corresponding to the number of hours that the token is active
    # * `secret` is a string corresponding to the secret key used when encrypting the token
    # * `token_transport` is a string indicating where to include the token in the HTTP response
    attr_accessor :algorithm, :expires, :secret, :token_transport
  end
end
