source "http://rubygems.org"

group :test do
  gem "rake"
  gem 'beaker', '~> 1.11.0'
  gem "puppet-blacksmith"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.4.0'
  gem "puppet-lint"
  gem "rspec-puppet", :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
end

group :development do
  gem 'json'
#  gem "travis"
#  gem "travis-lint"
  gem 'beaker', '~> 1.11.0'
  gem 'beaker-rspec'
#  gem "puppet-blacksmith"
  gem "guard-rake"
end
