# consul_version.rb

Facter.add(:consul_version) do
  confine kernel: 'Linux'
  setcode do
    original_path = ENV.fetch('PATH', nil)
    path = ENV.fetch('PATH') { '/bin:/usr/bin:/usr/local/bin' }
    ENV['PATH'] = path + ':/usr/local/bin'
    begin
      Facter::Util::Resolution.exec('consul --version 2> /dev/null').lines.first.split[1].tr('v', '')
    rescue StandardError
      nil
    ensure
      ENV['PATH'] = original_path
    end
  end
end
