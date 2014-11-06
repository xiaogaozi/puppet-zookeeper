# == Class: zookeeper::server
#
# Configures a ZooKeeper server.
# This requires that ZooKeeper is installed
# And that the current nodes hostname is an entry in the
# $::zookeeper::hosts array.
#
# === Parameters
#
# [*jmx_port*]
#   JMX port. Set this to false if you don't want to expose JMX.
#
# [*cleanup_count*]
#   If this is > 0, this installs a cron to cleanup transaction
#   and snapshot logs. +/usr/bin/zookeeper-server-cleanup -n $cleanup_count+
#   will be run daily. Default: 10
#
# === Examples
#
#  include zookeeper::server
#
class zookeeper::server(
  $jmx_port         = $::zookeeper::defaults::jmx_port,
  $cleanup_count    = $::zookeeper::defaults::cleanup_count,
  $cleanup_script   = $::zookeeper::defaults::cleanup_script,
  $default_template = $::zookeeper::defaults::default_template,
  $log4j_template   = $::zookeeper::defaults::log4j_template
) {
  # need ZooKeeper common package and config.
  Class['zookeeper'] -> Class['zookeeper::server']

  # Install ZooKeeper server package
  package { 'zookeeper-server':
    ensure => $::zookeeper::version,
  }

  file { '/etc/default/zookeeper':
    content => template($default_template),
    require => Package['zookeeper-server']
  }

  file { '/etc/zookeeper/conf/log4j.properties':
    content => template($log4j_template),
    require => Package['zookeeper-server'],
  }

  file { $::zookeeper::data_dir:
    ensure  => 'directory',
    owner   => 'zookeeper',
    group   => 'zookeeper',
    mode    => '0755',
    require => Package['zookeeper-server'],
  }

  # Get this host's $myid from the $hostname in the $zookeeper_hosts hash.
  $myid = $::zookeeper::hosts[$::hostname]
  file { '/etc/zookeeper/conf/myid':
    content => $myid,
    require => Package['zookeeper-server'],
  }
  file { "${::zookeeper::data_dir}/myid":
    ensure  => 'link',
    target  => '/etc/zookeeper/conf/myid',
    require => File['/etc/zookeeper/conf/myid'],
  }

  exec { 'zookeeper-server-initialize':
    command => '/usr/sbin/service zookeeper-server init',
    creates => "${::zookeeper::data_dir}/version-2",
    user    => 'root',
    require => [Package['zookeeper-server'], File[$::zookeeper::data_dir]],
  }

  service { 'zookeeper-server':
    ensure     => running,
    require    => [
      Package['zookeeper-server'],
      File[$::zookeeper::data_dir],
      File["${::zookeeper::data_dir}/myid"],
      Exec['zookeeper-server-initialize'],
    ],
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [
      File['/etc/default/zookeeper'],
      File['/etc/zookeeper/conf/zoo.cfg'],
      File['/etc/zookeeper/conf/myid'],
      File['/etc/zookeeper/conf/log4j.properties'],
    ],
  }

  cron { 'zookeeper-cleanup':
    command => "${cleanup_script} -n ${cleanup_count}",
    hour    => 0,
    user    => 'zookeeper',
    require => Service['zookeeper-server'],
  }

  # if !$cleanup_count, then ensure this cron is absent.
  if (!$cleanup_count or $cleanup_count <= 0) {
    Cron['zookeeper-cleanup'] { ensure => 'absent' }
  }
}
