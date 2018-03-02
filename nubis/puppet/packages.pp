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

file { '/opt/vertica/lib64/en-US':
  ensure  => present,
  type    => link,
  target  => '../en-US',
  require => [
    package['vsql'],
  ],
}
