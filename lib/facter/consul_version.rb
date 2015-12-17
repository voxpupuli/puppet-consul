# consul_version.rb

if Facter.value(:kernel) == 'Linux'
  version = %x[consul --version]
  version = version.lines.first.split[1].tr('v','')
elsif Facter.value(:kernel) == 'windows'
  version = %x["C:\\Program Files\\Consul\\consul.exe" --version]
  version = version.lines.first.split[1].tr('v','')
end

Facter.add(:consul_version) do
  setcode do
      version
  end
end
