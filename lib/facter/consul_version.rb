# consul_version.rb

Facter.add(:consul_version) do
  confine :kernel => 'Linux'
  setcode do
    version = Facter::Util::Resolution.exec('consul --version 2> /dev/null')
    version = version.lines.first.split[1].tr('v','')
    version
  end
end
