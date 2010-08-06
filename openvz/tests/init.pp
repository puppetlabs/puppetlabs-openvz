$vzpath = '/etc/puppet/nodes'
include openvz 
makenodes("${vzpath}/${fqdn}")
