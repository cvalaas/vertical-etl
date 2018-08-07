cron::daily { "${project_name}-salesforce_sfmc":
  user    => 'etl',
  command => "nubis-cron ${project_name}-salesforce_sfmc /opt/etl/salesforce_sfmc/run",
}

python::pyvenv { "${virtualenv_path}/sfmc-fetcher" :
  ensure  => present,
  version => '3.4',
  require => [
    File[$virtualenv_path],
  ],
}

# Install Mozilla's sfmc-fetcher
python::pip { 'sfmc-fetcher':
  ensure     => 'present',
  virtualenv => "${virtualenv_path}/data-integrations",
  url        => 'git+https://github.com/mozilla-it/data-integrations@714002a4ca8a13e92f3086284f8b699101921bb9',
  require    => [
  ],
}

file { '/usr/local/bin/sfmc-fetcher':
  ensure  => link,
  target  => '${virtualenv_path}/data-integrations/bin/brickftp_poc.py',
  require => [
    Python::Pip['sfmc-fetcher'],
  ],
}

file { '/opt/etl/salesforce_sfmc':
  ensure  => directory,
  require => [
    File['/opt/etl'],
  ]
}

file { '/var/lib/etl/salesforce_sfmc':
  ensure  => directory,
  owner   => 'etl',
  group   => 'etl',
  mode    => '0755',

  require => [
    User['etl'],
    Group['etl'],
    File['/var/lib/etl'],
  ]
}

file { '/opt/etl/salesforce_sfmc/fetch':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/salesforce_sfmc'],
  ],
  source  => 'puppet:///nubis/files/salesforce_sfmc/fetch.sh',
}

file { '/opt/etl/salesforce_sfmc/load':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/salesforce_sfmc'],
  ],
  source  => 'puppet:///nubis/files/salesforce_sfmc/load.sh',
}

file { '/opt/etl/salesforce_sfmc/load.yml':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/salesforce_sfmc'],
  ],
  source  => 'puppet:///nubis/files/salesforce_sfmc/load.yml',
}

file { '/opt/etl/salesforce_sfmc/run':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/salesforce_sfmc'],
  ],
  source  => 'puppet:///nubis/files/salesforce_sfmc/run.sh',
}
