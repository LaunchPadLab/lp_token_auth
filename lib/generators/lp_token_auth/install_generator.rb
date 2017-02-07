require 'securerandom'

module LpTokenAuth
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates a LpTokenAuth initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/lp_token_auth.rb'
      end

      def secret_key
        SecureRandom.hex(64)
      end
    end
  end
end
