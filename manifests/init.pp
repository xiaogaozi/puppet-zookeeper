# == Class: zookeeper
#
# Installs common ZooKeeper package and configs.
#
# === Parameters
#
# [*hosts*]
#   Hash of ZooKeeper hostname to myids.
#
# [*data_dir*]
#   ZooKeeper dataDir.  Default: /var/lib/zookeeper
#
# [*data_log_dir*]
#   Zookeeper dataLogDir.  Default: undef.
#
# [*tick_time*]
#   The length of a single tick, which is the basic time unit used by
#   ZooKeeper, as measured in milliseconds.  Default: 2000
#
# [*init_limit*]
#   Amount of time in ticks to allow followers to connect and sync to
#   a leader.  Default: 10
#
# [*sync_limit*]
#   Amount of tim to allow followers to sync with ZooKeeper.  Default: 5
#
# [*version*]
#   Zookeeper package version number.  Set this if you need to
#   override the default package version.  Default: installed.
#
# === Examples
#
#  class { 'zookeeper':
#    hosts    => { 'zoo1.domain.org' => 1, 'zoo2.domain.org' => 2, 'zoo3.domain.org' => 3 },
#    data_dir => '/var/lib/zookeeper',
#  }
#
# The above setup should be used to configure a 3 node ZooKeeper cluster.
# You can include the above class on any of your nodes that will need to talk
# to the ZooKeeper cluster.
#
# On the 3 ZooKeeper server nodes, you should also include:
#
#  include zookeeper::server
#
# This will ensure that the ZooKeeper server is running.
# Remember that this requires that you also include the
# ZooKeeper class as defined above as well as the server class.
#
# On each of the defined ZooKeeper hosts, a myid file must be created
# that identifies the host in the ZooKeeper quorum.  This myid number
# will be inferred from the nodes index in the ZooKeeper hosts array.
# e.g. zoo1.domain.org's myid will be '1', zoo2.domain.org's myid will be 2, etc.
#
class zookeeper(
  $hosts         = $::zookeeper::defaults::hosts,
  $data_dir      = $::zookeeper::defaults::data_dir,
  $data_log_dir  = $::zookeeper::defaults::data_log_dir,
  $tick_time     = $::zookeeper::defaults::tick_time,
  $init_limit    = $::zookeeper::defaults::init_limit,
  $sync_limit    = $::zookeeper::defaults::sync_limit,
  $conf_template = $::zookeeper::defaults::conf_template,
  $version       = $::zookeeper::defaults::version
) inherits zookeeper::defaults
{
  package { 'zookeeper':
    ensure => $version,
  }

  file { '/etc/zookeeper/conf/zoo.cfg':
    content => template($conf_template),
    require => Package['zookeeper'],
  }
}
