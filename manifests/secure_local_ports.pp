#
# Secures consul usage by ensuring that only the
# specified users can access internal consul services
# by default
#
class consul::secure_local_ports(
  $internal_ports = ['8300', '8400', '8500'],
  $consul_user    = 'consul'
) {
  include "firewall"
  Firewall {
    chain       => 'OUTPUT',
    action      => 'accept',
    destination => '127.0.0.1',
    proto       => 'tcp',
    dport       => ['8300', '8400', '8500'],
  }
  firewall { '001consul_allow_root':
    uid         => '0',
  }
  firewall { '002consul_allow_consul':
    uid         => $consul_user,
  }
  firewall { '999consul_drop':
    action => 'drop',
  }
}
