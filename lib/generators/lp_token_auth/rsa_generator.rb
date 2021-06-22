require 'openssl'

module LpTokenAuth
  module Generators
    class RsaGenerator < Rails::Generators::Base
      desc 'Generate an RSA key and add to Gemfile'

      def generate_rsa
        key = OpenSSL::PKey::RSA.generate(2048)
        arr = key.to_s.split("\n")
        str = arr.join("\\n")

        puts str
      end
    end
  end
end
