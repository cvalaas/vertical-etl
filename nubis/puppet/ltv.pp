cron::weekly { "${project_name}-ltv":
  weekday => '3',
  hour    => '1',
  minute  => '30',
  user    => 'etl',
  command => "nubis-cron ${project_name}-adi /opt/etl/ltv/run",
}

python::virtualenv { "${virtualenv_path}/ltv" :
  ensure      => present,
  virtualenv  => 'virtualenv-3',
  environment => [
    'VIRTUALENV_PYTHON=python2.7',
  ],
  require     => [
    File[$virtualenv_path],
  ],
}

file { '/opt/etl/ltv':
  ensure  => directory,
  require => [
    File['/opt/etl'],
  ]
}

file { '/var/lib/etl/ltv':
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

# Install ltv python libraries 
python::requirements { 'ltv':
  requirements => '/opt/etl/ltv/requirements.txt',
  forceupdate  => true,
  virtualenv   => "${virtualenv_path}/ltv",
  require      => [
    Python::Virtualenv["${virtualenv_path}/ltv"],
    File['/opt/etl/ltv/requirements.txt'],
  ],
}

file { '/opt/etl/ltv/fetch':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/fetch.sh',
}

file { '/opt/etl/ltv/util.py':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/util.py',
}

file { '/opt/etl/ltv/requirements.txt':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0644',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/requirements.txt',
}

file { '/opt/etl/ltv/load_client_details':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/load_client_details.py',
}

file { '/opt/etl/ltv/load_search_history':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/load_search_history.py',
}

file { '/opt/etl/ltv/ltv_calc_v1':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/ltv_calc_v1.py',
}

file { '/opt/etl/ltv/test_ltv_calc_v1':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/test_ltv_calc_v1.py',
}

file { '/opt/etl/ltv/ltv_aggr_v1':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/ltv_aggr_v1.py',
}

file { '/opt/etl/ltv/push_to_gcp':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/push_to_gcp.sh',
}

file { '/opt/etl/ltv/run':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0755',
  require => [
    File['/opt/etl/ltv'],
  ],
  source  => 'puppet:///nubis/files/ltv/run.sh',
}
