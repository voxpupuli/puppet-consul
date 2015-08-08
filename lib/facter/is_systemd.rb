# Implemented only at this time for UBUNTU 15.04 due to it having systemd and sysv as options.
# This allows us to create a fact that we can use in site.pp to decide whether to set default
# Service provider to systemd or not
Facter.add('is_systemd') do
  confine :kernel => :Linux

  setcode do
    'systemd' == Facter::Core::Execution.exec('ps -p 1 | grep systemd -o')
  end
end
