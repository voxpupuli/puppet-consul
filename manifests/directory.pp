# == Define consul::check
#
# Sets up a Consul healthcheck
# http://www.consul.io/docs/agent/checks.html
#
# == Parameters
#
# [*directory*]
#   Define folder that needs to be created.
#   Defaults to undef
#
# [*owner*]
#   Define the folder's owner
#   Defaults to undef
#
# [*group*]
#   Define the folder's group
#   Defaults to undef
#
# [*mode*]
#   Define the folder's permissions
#   Defaults to undef
#
# [*purge*]
#   Define if the folder should be purged
#   Defaults to false
#
# [*recurse*]
#   Define if the folder should be recursive
#   Defaults to false
#
define consul::directory (
  $directory = undef,
  $owner     = undef,
  $group     = undef,
  $mode      = undef,
  $purge     = false,
  $recurse   = false,
) {
  include consul

  if $directory {
    case $facts['os']['name'] {
      'windows': {
        exec { "Create ${$directory} Folder":
          path    => $facts['system32'],
          command => "cmd.exe /c mkdir ${$directory}",
          creates => $directory,
        }
      }
      default: {
        exec { "Create ${$directory} Folder":
          path    => $facts['path'],
          command => "mkdir -p ${$directory}",
          creates => $directory,
        }
      }
    }
    file { $directory:
      ensure  => 'directory',
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      purge   => $purge,
      recurse => $recurse,
      require => Exec["Create ${$directory} Folder"],
    }
  }
}
