require 'openssl'

desc 'Generate an RSA key and add to Gemfile'
task :generate_rsa do
  puts OpenSSL::PKey::RSA.generate(2048)
end
