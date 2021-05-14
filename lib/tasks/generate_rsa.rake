require 'openssl'

desc 'Generate an RSA key and add to Gemfile'
task :generate_rsa do
  key = OpenSSL::PKey::RSA.generate(2048)
  arr = key.to_s.split("\n")
  str = arr.join("\\n")

  puts str
end
