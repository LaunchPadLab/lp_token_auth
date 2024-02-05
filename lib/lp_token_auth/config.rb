require 'lp_token_auth/error'

module LpTokenAuth
  # `LpTokenAuth::Config` manages the configuration options for the token.
  # These can be set with the initializer provided with the generator.
  class Config
    # Creates virtual attributes for configuration options:
    # * `algorithm` is a string corresponding to token encryption algorithm to use
    # * `expires` is an integer corresponding to the number of hours that the token is active
    # * `secret` is a string corresponding to the secret key used when encrypting the token
    # * `token_transport` is a string indicating where to include the token in the HTTP response
    attr_accessor :algorithm, :expires, :secret, :token_transport, :jwe_private_key, :jwe_encryption

    # Provides default values to token options
    # ENV defaults defined as procs to ensure they return their
    # latest value at call time (else they return nil,
    # since ENV values may not be initialized before gem code)
    DEFAULT_VALUES = {
      algorithm: 'HS512',
      expires: (7 * 24),
      token_transport: [:cookie],
      jwe_private_key: -> { ENV['JWE_PRIVATE_KEY'] },
      jwe_encryption: -> { ENV['JWE_ENCRYPTION'] || 'A256GCM' }
    }

    # Retrieves value for token option, either as set by the application, or the default
    # @param [Symbol] key the token option name
    # @raise [LpTokenAuth::Error] if the option has not been set by the application and a default value does not exist
    # @return [String,Integer] the value of the token option
    def get_option(key)
      option = send(key) || get_default_value(key)
      raise LpTokenAuth::Error, "Missing config option value: #{key}" unless option
      option
    end

    # Retrieves default value for a token option
    # @param [Symbol] key the token option name
    # @return [String,Integer] the value of the token option
    def get_default_value(key)
      default = DEFAULT_VALUES[key]
      default.is_a?(Proc) ? default.call : default
    end
  end
end
