# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
include consul

# allows for a quick and dirty test of the consul_key_value with consul.
# You can execute consul in docker using:
# > docker run -d -p 8500:8500 --name=dev-consul consul
# use this to find the hostname
# > docker exec -t dev-consul consul members
# node default {
#   consul_key_value{'sample/key':
#     ensure => 'absent',
#     value  => 'testValue',
#     datacenter  => 'dc1'
#   }
# }
