module LpTokenAuth
  def self.config
    @config ||= LpTokenAuth::Config.new
    if block_given?
      yield @config
    else
      @config
    end
  end
end

require 'lp_token_auth/config'
require 'lp_token_auth/error'
require 'lp_token_auth/core'
require 'lp_token_auth/controller'
require 'lp_token_auth/version'
