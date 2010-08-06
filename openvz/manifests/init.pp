class openvz {
  $pkgs = [ 'ovzkernel', 'vzctl', 'vzquota']

  File {
    owner => 'root',
    group => 'root',
    mode => '0644'
  }

  file {
    'vzscript':
      path => '/etc/sysconfig/vz-scripts',
      ensure => present,
      recurse => true,
      source => ['puppet:///modules/sitefiles/vz-scripts', 'puppet:///modules/openvz/vz-scripts'];
    '/etc/yum.repos.d/openvz.repo':
      source => ['puppet:///modules/sitefiles/openvz.repo', 'puppet:///modules/openvz/openvz.repo'],
      notify => Exec['openvz-reboot'];
    '/etc/sysctl.conf':
      source => ['puppet:///modules/sitefiles/openvz/sysctl.conf', 'puppet:///modules/openvz/sysctl.conf'],
      notify => Exec['openvz-reboot'];
    #'/etc/sysconfig/network-scripts/ifcfg-br0': content => template('openvz/ifcfg-br0.erb'),  
    #  notify => Exec['openvz-reboot'];
    #'/etc/sysconfig/network-scripts/ifcfg-eth0': source => 'puppet:///modules/openvz/ifcfg-eth0',  
    #  notify => Exec['openvz-reboot'];
  }

  package { $pkgs:
    ensure => installed,
    require => File['/etc/yum.repos.d/openvz.repo'],
  }

  exec { "openvz-reboot":
    subscribe => Package["ovzkernel", "vzquota", "vzctl"],
    command => '/sbin/shutdown -r +5', 
    creates => '/vz/reboot',
    refreshonly => true,
  }

  define virt (
    $ensure = 'present',
    $hostname,
    $ostemplate,
    $ip,
    $nameserver,
    $hostalias,
    $onboot = 'true',
    $setparams = false,
    $kmemsize = '300331648:150331648',
    $lockedpages = '24000:24000', 
    $privvmpages = '262144:9999999999999999',
    $shmpages = '4097152:4097152',
    $numproc = '1600:1600',
    $physpages = '0:9223372036854775807',
    $vmguarpages = '262144', 
    $oomguarpages = '262144',
    $numtcpsock = '9000:9900',
    $numflock = '800:840',
    $numpty = '64:64', 
    $numsiginfo = '256:256',
    $tcpsndbuf = '57600000:115200000',
    $tcprcvbuf = '57600000:115200000',
    $othersockbuf = '57600000:115200000',
    $dgramrcvbuf = '922144:1022144',
    $numothersock = '1800:2000',
    $dcachesize = '24582912:24680064',
    $numfile = '30000:30000',
    $avnumproc = '360:360', 
    $numiptent = '128:128',
    $diskspace = '41943040:43943040', 
    $diskinodes = '2000000:2200000',
    $quotatime = '0',
    $cpuunits = '1000',
    $features = 'nfs:on',
    $meminfo  = 'privvmpages:1',
    $bootstrap = '') {
    Exec { path => '/bin:/sbin:/usr/bin:/usr/sbin', logoutput => on_failure }
   $beancounters = "--kmemsize $kmemsize --lockedpages $lockedpages --privvmpages $privvmpages --shmpages $shmpages --numproc $numproc --physpages $physpages  --vmguarpages $vmguarpages --oomguarpages $oomguarpages --numtcpsock $numtcpsock --numflock $numflock --numpty $numpty --numsiginfo $numsiginfo --tcpsndbuf $tcpsndbuf --tcprcvbuf $tcprcvbuf --othersockbuf $othersockbuf --dgramrcvbuf $dgramrcvbuf --numothersock $numothersock --dcachesize $dcachesize  --numfile $numfile --avnumproc $avnumproc --numiptent $numiptent --diskspace $diskspace --diskinodes $diskinodes --quotatime $quotatime  --cpuunits $cpuunits --features $features --meminfo $meminfo"
  
    case $ensure {
      present: {
        exec {"create-vz-${name}":
          command => "vzctl create ${name} --conf vps.basic --ostemplate ${ostemplate} --ipadd ${ip} --hostname ${hostname}", 
          creates => "/vz/private/${name}",
          logoutput => on_failure,
        }
        file {"/etc/sysconfig/vz-scripts/${name}.conf":
          ensure => present,
          require => Exec["create-vz-${name}"],
        }
        if $setparams { 
          exec {"set-vz-${name}":
            command => "vzctl set ${name} --nameserver $nameserver --save ${beancounters}",  
            #refreshonly => true,
            #subscribe => Exec["create-vz-${name}"],
            #notify => Exec["start-vz-${name}"],
          }
        }
        exec {"start-vz-${name}":
          command => "vzctl start ${name} --wait",  
          onlyif => "[ \$(vzlist ${name} -H -o status) == stopped ]", 
          subscribe => Exec["create-vz-${name}"],
          logoutput => on_failure,
        } 
        if $bootstrap {
          exec {"exec-vz-${name}":
            command => "vzctl exec ${name} '$bootstrap'",  
            refreshonly => true,
            require => Exec["start-vz-${name}"],
            logoutput => on_failure,
          }
        }
      }
      absent: {
        exec {"stop-vz-${name}":
          command => "vzctl stop ${name}",
          creates => "/vz/private/${name}",
          unless => "[ \$(vzlist ${name} -H -o status) == stopped ]", 
          logoutput => on_failure,
        }
      } 
      default: {
        fail("${ensure} is not a valid option")
      } 
    }
  }
}
