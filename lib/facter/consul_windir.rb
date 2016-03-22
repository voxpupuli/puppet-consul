Facter.add(:consul_windir) do
  confine :osfamily => :windows
  setcode do
    program_data = `echo %SYSTEMDRIVE%\\ProgramData`.chomp
    if File.directory? program_data
      "#{program_data}\\Consul"
    else
      "C:\\Consul"
    end
  end
end
