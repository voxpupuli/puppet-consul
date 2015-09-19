source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :unit_tests do
  gem 'rake',                                              :require => false
  gem 'rspec', '< 3.2',                                    :require => false if RUBY_VERSION =~ /^1.8/
  gem 'rspec-puppet',                                      :require => false
  gem 'puppetlabs_spec_helper',                            :require => false
  gem 'metadata-json-lint',                                :require => false
  gem 'puppet-lint',                                       :require => false
  gem 'rspec-puppet-facts',                                :require => false
end

group :system_tests do
  #gem 'beaker',              :require => false
  gem 'beaker', github: 'puppetlabs/beaker', branch: 'master'
  gem 'beaker-rspec',        :require => false
  gem 'beaker_spec_helper',  :require => false
  gem 'serverspec',          :require => false
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end
