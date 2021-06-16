# require 'rake/testtask'

# Rake::TestTask.new do |t|
#   t.libs << 'test'
# end

# desc "Run tests"
# task :default => :test

# load('lib/tasks/generate_rsa.rake')

require 'lp_token_auth'

spec = Gem::Specification.find_by_name 'lp_token_auth'
rakefile = "#{spec.gem_dir}/lib/Rakefile"
load rakefile
