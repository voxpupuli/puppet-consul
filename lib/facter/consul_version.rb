# consul_version.rb

Facter.add(:consul_version) do
  confine :kernel => 'Linux'
  setcode do
    begin
      Facter::Util::Resolution.exec('consul --version 2> /dev/null').lines.first.split[1].tr('v','')
    rescue
      nil
    end
  end
end
