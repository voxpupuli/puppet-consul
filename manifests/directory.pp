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
define consul::directory (
  $directory = undef,
) {
  include consul

  if $directory {
    case $facts['os']['name'] {
      'windows': {
        exec { "Create ${$directory} Log Folder":
          path    => $facts['system32'],
          command => "cmd.exe /c mkdir ${$directory}",
          creates => $directory,
        }
      }
      default: {
        exec { "Create ${$directory} Log Folder":
          path    => $facts['path'],
          command => "mkdir -p ${$directory}",
          creates => $directory,
        }
      }
    }
    file { $directory:
      ensure  => 'directory',
      owner   => $consul::user_real,
      group   => $consul::group_real,
      mode    => $consul::data_dir_mode,
      require => Exec["Create ${$directory} Log Folder"],
    }
  }
}
