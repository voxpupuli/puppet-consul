# consul_version.rb

Facter.add(:consul_version) do
  setcode do
    if Facter.value(:kernel) == 'Linux'
      version = Facter::Util::Resolution.exec('consul --version')
      version = version.lines.first.split[1].tr('v','')
    elsif Facter.value(:kernel) == 'windows'
      version = Facter::Util::Resolution.exec('"C:\\Program Files\\Consul\\consul.exe" --version')
      version = version.lines.first.split[1].tr('v','')
    end

    version
  end
end
