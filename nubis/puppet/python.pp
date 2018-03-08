$virtualenv_path = '/usr/local/virtualenvs'

class { 'python':
  version    => 'python34',
  pip        => true,
  dev        => true,
  virtualenv => true,
}

file { $virtualenv_path:
  ensure => directory,
}

python::pyvenv { "${virtualenv_path}/data-collectors" :
  ensure  => present,
  version => '3.4',
  require => [
    File[$virtualenv_path],
  ],
}

python::pyvenv { "${virtualenv_path}/salesforce-fetcher" :
  ensure  => present,
  version => '3.4',
  require => [
    File[$virtualenv_path],
  ],
}

python::pyvenv { "${virtualenv_path}/vertica-csv-loader" :
  ensure  => present,
  version => '3.4',
  require => [
    File[$virtualenv_path],
  ],
}

# System dependencies

package { 'gcc-c++':
  ensure => 'present',
}

package { 'unixODBC-devel':
  ensure => 'present',
}

# Install Mozilla's data-collector
python::pip { 'data-collectors':
  ensure     => 'present',
  virtualenv => "${virtualenv_path}/data-collectors",
  url        => 'git+https://github.com/gozer/data-collectors@cdf44388106e62a4b5740008579dd2ea2631e1af',
  require    => [
    Package['gcc-c++'],
    Package['unixODBC-devel'],
  ],
}

# Install Mozilla's salesforce-fetcher
python::pip { 'salesforce-fetcher':
  ensure     => 'present',
  virtualenv => "${virtualenv_path}/salesforce-fetcher",
  url        => 'git+https://github.com/gozer/salesforce-fetcher@213a4a683df9b0cd264cc50802197f4489e9750c',
  require    => [
  ],
}

# Install Mozilla's vertica-csv-loader
python::pip { 'vertica-csv-loader':
  ensure     => 'present',
  virtualenv => "${virtualenv_path}/vertica-csv-loader",
  url        => 'git+https://github.com/gozer/vertica-csv-loader@8c5ec54255aa267e0e71a0c68c94c9bf102e6131',
  require    => [
  ],
}

file { '/etc/salesforce-fetcher':
  ensure => directory,
}

file { '/var/salesforce-fetcher':
  ensure => directory,
}

file { '/etc/data-collectors':
  ensure => directory,
}

file { '/usr/local/virtualenvs/data-collectors/lib/python3.4/site-packages/collectors/defaults':
  ensure  => link,
  target  => '../../../../collectors/defaults',
  require => [
    Python::Pip['data-collectors'],
  ],
}
