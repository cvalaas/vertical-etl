$vsql_major_version = '8.1'
$vsql_version = "${vsql_major_version}.1-13"

package { 'vsql':
  ensure          => present,
  provider        => 'rpm',
  name            => 'vertica-client-fips',
  source          => "https://my.vertica.com/client_drivers/${vsql_major_version}.x/${vsql_version}/vertica-client-fips-${vsql_version}.${::architecture}.rpm",
  install_options => [
    '--noscripts',
  ],
}

package { 'pyodbc':
  ensure => present,
}

package { 'GeoIP-data':
  ensure => present,
}

package { 'GeoIP-update':
  ensure => present,
}

# Fix missing error XML file
file { '/opt/vertica/lib64/en-US':
  ensure  => 'link',
  target  => '../en-US',
  require => [
    Package['vsql'],
  ],
}

yumrepo { 'google-cloud-sdk':
  descr         => 'Google Cloud SDK',
  baseurl       => 'https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64',
  enabled       => 1,
  gpgcheck      => 1,
  repo_gpgcheck => 1,
  gpgkey        => "https://packages.cloud.google.com/yum/doc/yum-key.gpg\n       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg",
}

package { 'google-cloud-sdk':
  ensure  => latest,
  require => [
    Yumrepo['google-cloud-sdk'],
  ]
}

package { 'epel-release':
  ensure => latest,
}
  -> yumrepo { 'epel':
  enabled => 1,
}
