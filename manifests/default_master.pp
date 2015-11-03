# Update APT Cache
class { 'apt':
  always_apt_update => true,
}


# Java is required
class { 'java': }