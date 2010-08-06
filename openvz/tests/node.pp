$script = "/bin/rpm -Uvh http://download.fedora.redhat.com/pub/epel/5/i386/epel-release-5-3.noarch.rpm && /bin/yum install puppet && /etc/init.d/puppetd start"  
openvz::node {'200':
  ensure => 'present',
  hostname => 'test01.puppetlabs.lan',
  vzalias => 'test01',
  ostemplate => 'centos-5-x86',
  config => 'vps.basic',
  ip => '172.16.238.200',
  nameserver => '172.16.238.2',
  bootstrap => $script
  # gateway => "",
  # broadcast => "",
  # network => "",
  # networkmask => "",
}

#
# Generict CentOS 5.4 setup (described in rapids)
# inherit:
#   - beancounter: max
# 
# hardware-type: openvz
# ostemplate: generic-centos54-x86_64
# 
# packages:
#   - vz-utils       latest
#   - rsyslog.x86_64 latest
# 
# files:
#   - /etc/rc.d/init.d/halt
#   
# exec:
#   /root/.ssh:
#     unless: test -d /root/.ssh
#     command: mkdir -p /root/.ssh
#   /etc/sysconfig/rsyslog:
#     unless: test -e /var/run/rsyslogd.pid
#     command: /sbin/service syslog stop && /sbin/chkconfig syslog off && /sbin/service rsyslog start && /sbin/chkconfig rsyslog on
#

# Sample OpenVZ Conf file
#
#ONBOOT="yes"
#KMEMSIZE="300331648:150331648"
#LOCKEDPAGES="24000:24000"
#PRIVVMPAGES="99999999999999999:99999999999999999"
#SHMPAGES="4097152:4097152"
#NUMPROC="1600:1600"
#PHYSPAGES="0:9223372036854775807"
#VMGUARPAGES="33792:9223372036854775807"
#OOMGUARPAGES="610351:9223372036854775807"
#NUMTCPSOCK="9000:9900"
#NUMFLOCK="800:840"
#NUMPTY="64:64"
#NUMSIGINFO="512:512"
#TCPSNDBUF="57600000:115200000"
#TCPRCVBUF="57600000:115200000"
#OTHERSOCKBUF="57600000:115200000"
#DGRAMRCVBUF="522144:522144"
#NUMOTHERSOCK="1800:2000"
#DCACHESIZE="24582912:24680064"
#NUMFILE="30000:30000"
#AVNUMPROC="360:360"
#NUMIPTENT="128:128"
#DISKSPACE="171943040:193943040"
#DISKINODES="2000000:2200000"
#QUOTATIME="0"
#CPUUNITS="1000"
#IPTABLES="iptable_nat"
#VE_ROOT="/vz/root/$VEID"
#VE_PRIVATE="/vz/private/$VEID"
#OSTEMPLATE="centos-2-x86_64"
#ORIGIN_SAMPLE="vps.basic"
#NETIF="ifname=eth0,mac=00:18:51:C7:97:03,host_ifname=veth569.0,host_mac=00:18:51:A1:EC:7F"
#NAMESERVER="10.4.2.8"
#HOSTNAME="yum20.sf.verticalresponse.com"
#FEATURES="nfs:on "
#MEMINFO="privvmpages:1"
#

# Sample OpenVZ Mount Script
##!/bin/sh
#
## Check if global Virtuozzo configuration and container configuration files exist
#[ -f /etc/sysconfig/vz ] || exit 1
#[ -f $VE_CONFFILE ] || exit 1
#
## Source both files. Note the order, it is important
#source /etc/sysconfig/vz
#source $VE_CONFFILE
#
#for dir in mofo/mail5 vr/stor vr/media2 session_tmp backups logarchive space
#do
#  [ ! -e $VE_ROOT/mnt/$dir ] && mkdir -p $VE_ROOT/mnt/$dir
#done
#mount -n --rbind /mnt $VE_ROOT/mnt
#exit 0


#openvz::node {'212':
#  ensure => 'absent',
#  config => 'vps.basic',
#  vzalias => 'foohost',
#  nameserver => '10.0.0.10',
#  ip => '10.0.0.112',
#  ostemplate => 'centos-5-x86',
#  hostname => "test.foo.com",
#}
#openvz::node {'312':
#  ensure => 'fail',
#  config => 'vps.basic',
#  vzalias => 'foohost',
#  nameserver => '10.0.0.10',
##  ip => '10.0.0.112',
#  ostemplate => 'centos-5-x86',
#  hostname => "test.foo.com",
#}
