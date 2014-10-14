# Puppet ZooKeeper Module

Installs and configures a ZooKeeper client and/or ZooKeeper server.

This module has been implemented and tested on Ubuntu Precise, and uses
the ZooKeeper package in CDH repository.

# Usage

```puppet
class { 'zookeeper':
  hosts    => { 'zoo1.domain.org' => 1, 'zoo2.domain.org' => 2, 'zoo3.domain.org' => 3 },
  data_dir => '/var/lib/zookeeper'
}
```

The above setup should be used to configure a 3 node ZooKeeper cluster.
You can include the above class on any of your nodes that will need to talk
to the ZooKeeper cluster.

On the 3 ZooKeeper server nodes, you should also include:

```puppet
include zookeeper::server
```

This will ensure that the ZooKeeper server is running.
Remember that this requires that you also include the
ZooKeeper class as defined above as well as the server class.

On each of the defined ZooKeeper hosts, a `myid` file must be created
that identifies the host in the ZooKeeper quorum.  This `myid` number
will be extracted from the hosts Hash keyed by the node's `$hostname`.
E.g. `zoo1.domain.org`'s `myid` will be '1', `zoo2.domain.org`'s `myid` will be 2, etc.

By default the ```zookeeper::server``` class will install a 'zookeeper-cleanup'
cronjob that will run ```/usr/bin/zookeeper-server-cleanup``` daily.  You can
adjust the number of old snapshots and logs you want to keep by setting the
```$cleanup_count``` parameter.
