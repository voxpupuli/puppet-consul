source ENV['GEM_SOURCE'] || 'https://rubygems.org'

def location_for(place_or_version, fake_version = nil)
  git_url_regex = %r{\A(?<url>(https?|git)[:@][^#]*)(#(?<branch>.*))?}
  file_url_regex = %r{\Afile:\/\/(?<path>.*)}

  if place_or_version && (git_url = place_or_version.match(git_url_regex))
    [fake_version, { git: git_url[:url], branch: git_url[:branch], require: false }].compact
  elsif place_or_version && (file_url = place_or_version.match(file_url_regex))
    ['>= 0', { path: File.expand_path(file_url[:path]), require: false }]
  else
    [place_or_version, { require: false }]
  end
end

ruby_version_segments = Gem::Version.new(RUBY_VERSION.dup).segments
minor_version = ruby_version_segments[0..1].join('.')

group :development do
  gem "json", '= 2.0.4',                                                     require: false if Gem::Requirement.create('~> 2.4.2').satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.1.0',                                                     require: false if Gem::Requirement.create(['>= 2.5.0', '< 2.7.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "json", '= 2.3.0',                                                     require: false if Gem::Requirement.create(['>= 2.7.0', '< 2.8.0']).satisfied_by?(Gem::Version.new(RUBY_VERSION.dup))
  gem "puppet-module-posix-default-r#{minor_version}", '~> 1.0',             require: false, platforms: [:ruby]
  gem "puppet-module-posix-dev-r#{minor_version}", '~> 1.0',                 require: false, platforms: [:ruby]
  gem "puppet-module-win-default-r#{minor_version}", '~> 1.0',               require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "puppet-module-win-dev-r#{minor_version}", '~> 1.0',                   require: false, platforms: [:mswin, :mingw, :x64_mingw]
  gem "beaker", '~> 4.26',                                                   require: false
  gem "beaker-rspec", '~> 6.3',                                              require: false
  gem "beaker-puppet_install_helper", '~> 0.9.8',                            require: false
  gem "beaker-module_install_helper", '~> 0.1.7',                            require: false
  gem "beaker-hostgenerator", '~> 1.3',                                      require: false
  gem "beaker-docker", '~> 0.8.4',                                           require: false
  gem "beaker-puppet", '~> 1.21',                                            require: false
  gem "fog-openstack", '~> 1.0',                                             require: false
  gem "github_changelog_generator", '~> 1.15',                               require: false
  gem "public_suffix", '~> 4.0',                                             require: false
  gem "puppet-lint-absolute_classname-check", '~> 3.0',                      require: false
  gem "puppet-lint-absolute_template_path", '~> 1.0',                        require: false
  gem "puppet-lint-anchor-check", '~> 1.0',                                  require: false
  gem "puppet-lint-classes_and_types_beginning_with_digits-check", '~> 0.1', require: false
  gem "puppet-lint-empty_string-check", '~> 0.2',                            require: false
  gem "puppet-lint-file_ensure-check", '~> 0.3',                             require: false
  gem "puppet-lint-leading_zero-check", '~> 0.1',                            require: false
  gem "puppet-lint-legacy_facts-check", '~> 1.0',                            require: false
  gem "puppet-lint-manifest_whitespace-check", '~> 0.1',                     require: false
  gem "puppet-lint-param-docs", '~> 1.6',                                    require: false
  gem "puppet-lint-resource_reference_syntax", '~> 1.0',                     require: false
  gem "puppet-lint-spaceship_operator_without_tag-check", '~> 0.1',          require: false
  gem "puppet-lint-strict_indent-check", '~> 2.0',                           require: false
  gem "puppet-lint-top_scope_facts-check", '~> 1.0',                         require: false
  gem "puppet-lint-topscope-variable-check", '~> 1.0',                       require: false
  gem "puppet-lint-trailing_comma-check", '~> 0.4',                          require: false
  gem "puppet-lint-trailing_newline-check", '~> 1.1',                        require: false
  gem "puppet-lint-undef_in_function-check", '~> 0.2',                       require: false
  gem "puppet-lint-unquoted_string-check", '~> 2.0',                         require: false
  gem "puppet-lint-variable_contains_upcase", '~> 1.2',                      require: false
  gem "puppet-lint-version_comparison-check", '~> 0.2',                      require: false
  gem "puppet_metadata", '~> 0.3.0',                                         require: false
  gem "serverspec", '~> 2.41',                                               require: false
  gem "vagrant-wrapper", '~> 2.0',                                           require: false
  gem "voxpupuli-acceptance", '~> 0.3.0',                                    require: false
  gem "voxpupuli-release", '~> 1.0',                                         require: false
  gem "webmock", '~> 3.12',                                                  require: false
end
group :system_tests do
  gem "puppet-module-posix-system-r#{minor_version}", '~> 1.0', require: false, platforms: [:ruby]
  gem "puppet-module-win-system-r#{minor_version}", '~> 1.0',   require: false, platforms: [:mswin, :mingw, :x64_mingw]
end

puppet_version = ENV['PUPPET_GEM_VERSION']
facter_version = ENV['FACTER_GEM_VERSION']
hiera_version = ENV['HIERA_GEM_VERSION']

gems = {}

gems['puppet'] = location_for(puppet_version)

# If facter or hiera versions have been specified via the environment
# variables

gems['facter'] = location_for(facter_version) if facter_version
gems['hiera'] = location_for(hiera_version) if hiera_version

gems.each do |gem_name, gem_params|
  gem gem_name, *gem_params
end

# Evaluate Gemfile.local and ~/.gemfile if they exist
extra_gemfiles = [
  "#{__FILE__}.local",
  File.join(Dir.home, '.gemfile'),
]

extra_gemfiles.each do |gemfile|
  if File.file?(gemfile) && File.readable?(gemfile)
    eval(File.read(gemfile), binding)
  end
end
# vim: syntax=ruby
