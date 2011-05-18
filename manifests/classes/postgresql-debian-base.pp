/*

==Class: postgresql::debian::base

This class is dedicated to the common parts 
shared by the different flavors of Debian

*/
class postgresql::debian::base inherits postgresql::base {

  include postgresql::params

  Package["postgresql"] {
    name   => "postgresql-${version}",
    notify => Exec["drop initial cluster"],
  }

  package {[
    "libpq-dev",
    "libpq5",
    "postgresql-client-${version}",
    "postgresql-common",
    "postgresql-client-common",
    "postgresql-contrib-${version}"
    ]:
    ensure  => present,
    require => Package["postgresql"],
  }

  exec {"drop initial cluster":
    command => "pg_dropcluster --stop ${version} main",
    onlyif  => "test \$(su -c 'psql -lx' postgres |awk '/Encoding/ {printf tolower(\$3)}') = 'sql_asciisql_asciisql_ascii'",
    timeout => 60,
    before  => Postgresql::Cluster["main"],
  }
  
  postgresql::cluster {"main":
    ensure      => present,
    clustername => "main",
    version     => $version,
    encoding    => "UTF8",
    data_dir    => "${postgresql::params::data_dir}",
    require     => [Package["postgresql"], Exec["drop initial cluster"]],
  }
  
}
