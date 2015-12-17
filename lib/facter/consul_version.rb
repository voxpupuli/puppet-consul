# consul_version.rb

Facter.add(:consul_version) do
  confine :kernel => 'Linux'
  setcode do
    Facter::Core::Execution.exec('consul --version | head -1 | cut -f2 -d\ | cut -c2-')
  end
end

Facter.add(:consul_version) do
  confine :kernel => 'windows'
  setcode do
    Facter::Core::Execution.exec('powershell (((& "C:\Program Files\Consul\consul.exe" "--version") | select -First 1).Split(" ",[StringSplitOptions]"RemoveEmptyEntries")[1]).TrimStart("v")')
  end
end
