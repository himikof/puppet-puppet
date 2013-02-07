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
      # No more needed with recent ruby-augeas
      portage::mask { 'ruby_augeas_fix':
        ensure  => absent,
        package => '=app-admin/augeas-0.10.0',
        before  => Package['puppet'],
      }
      package { 'puppet':
        ensure  => 'latest',
        require => Portage::Use_flags['puppet'],
      }
      
      service { 'puppet':
        enable => 'true',
      }
      
      augeas { 'puppet_conf':
        context => '/files/etc/puppet/puppet.conf',
        changes => [
          'set main/pluginsync true',
          'set agent/report true',
        ],
        require => Package['puppet'],
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
