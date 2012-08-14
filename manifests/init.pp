import 'stdlib'

# Class puppet
#
#  Manages the puppet installation
#
# @author Nikita Ofitserov <himikof@gmail.com>
# @version 1.0
# @package puppet
#
class puppet (
  $mutual_restart = true,
) {

  # Package installation
  case $operatingsystem {
    gentoo:
    {
      portage::use_flags { 'puppet':
        package => 'app-admin/puppet',
        use     => 'shadow sqlite3 augeas',
      }
      package { 'puppet':
        ensure  => 'latest',
        require => Portage::Use_flags['puppet'],
      }
      
      service { 'puppet':
        enable => 'true',
      }
      
      if $mutual_restart {
        # Mutual restart pattern
        cron { 'restart-puppet':
          command => "/etc/init.d/puppet status -q || /etc/init.d/puppet start",
          user => 'root',
          minute => 0,
        }
      }
      
    }
  }
}
