# Needed for os.distro.codebase fact
if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['full'] == '18.04' and versioncmp($facts['puppetversion'], '7') <= 0 {
  package{'lsb-release':
    ensure => present,
  }
}
