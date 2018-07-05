source "https://rubygems.org"

group :development do
  gem "beaker", "> 2.0.0"
  gem "beaker-rspec", ">= 5.1.0"
  gem "beaker-puppet_install_helper"
  gem "beaker-module_install_helper"
  gem "beaker-hostgenerator"
  gem "pry"
  gem "serverspec"
  gem "vagrant-wrapper"
  gem "fog-openstack", "0.1.25" if RUBY_VERSION < '2.2.2'
end

group :test do
  # Pin for 1.9.3 compatibility for now
  gem "json", '~> 1.8.3'
  gem "json_pure", '~> 1.8.3'

  gem "rake"
  gem "puppet", ENV['PUPPET_VERSION'] || '~> 5.0'
  gem "puppet-lint"

  gem "rspec"
  gem "rspec-core"
  gem "rspec-puppet"

  gem "puppet-syntax"
  gem "puppetlabs_spec_helper"
  gem "hiera"
  gem "webmock", "~> 2.3.0"
  gem "public_suffix"
end

group :release do
  gem 'github_changelog_generator',  :require => false, :git => 'https://github.com/skywinder/github-changelog-generator' if RUBY_VERSION >= '2.2.2'
  gem 'puppet-blacksmith',           :require => false
  gem 'voxpupuli-release',           :require => false, :git => 'https://github.com/voxpupuli/voxpupuli-release-gem'
end
