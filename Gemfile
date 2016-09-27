source "https://rubygems.org"

group :development do
  gem "beaker", "> 2.0.0"
  gem "beaker-rspec", ">= 5.1.0"
  gem "beaker-puppet_install_helper"
  gem "pry"
  gem "puppet-blacksmith"
  gem "serverspec"
  gem "vagrant-wrapper"
end

group :test do
  # Pin for 1.9.3 compatibility for now
  gem "json", '~> 1.8.3'
  gem "json_pure", '~> 1.8.3'

  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 3.7.0'
  gem "puppet-lint"

  gem "rspec"
  gem "rspec-core"
  gem "rspec-puppet"

  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "hiera"
  gem "hiera-puppet-helper"
end
