# Update APT Cache
class { 'apt':
  always_apt_update => true,
}


# Java is required
class { 'java': }

#MySQL
class { '::mysql::server':
  root_password           => 'vagrant',
  remove_default_accounts => true,
  override_options        => $override_options
}

mysql::db { 'druidmetastore':
  user     => 'druid',
  password => 'vagrant',
  dbname   => 'druidmetastore',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
