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
    powershell = 'powershell'
    command = ' (((&\"C:\Program Files\Consul\consul.exe\" --version)[0]).Split(\"Consul v\")[8]).trim() '
    Facter::Util::Resolution.exec(%Q{#{powershell} -command "#{command}"})
  end
end
