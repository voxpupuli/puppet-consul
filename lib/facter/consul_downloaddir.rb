Facter.add(:consul_downloaddir) do
  setcode do
    case Facter.value(:osfamily)
    when 'windows'
      program_data = `echo %SYSTEMDRIVE%\\ProgramData`.chomp
      if File.directory? program_data
        "#{program_data}\\puppet-archive"
      else
        "C:\\Puppet-Archive"
      end
    else
      '/opt/puppet-archive'
    end
  end
end
