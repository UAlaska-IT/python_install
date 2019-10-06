# frozen_string_literal: true

include_recipe 'python_install::default'

openssl_installation 'All defaults' unless node['platform_family'] == 'debian'

python_installation 'All Defaults' do
  # RHEL has ancient libs that are not supported by newer Pythons
  openssl_directory default_openssl_directory unless node['platform_family'] == 'debian'
end

directory '/usr/local/python-dl'

directory '/usr/local/python-bld'

directory '/usr/local/python'

directory '/usr/local/python/curr'

directory '/usr/local/python/prev'

user 'bud' do
  shell '/bin/bash'
end

openssl_installation 'All defaults' if node['platform_family'] == 'debian'

sqlite_installation 'All defaults'

python_installation 'Shared' do
  version '3.7.3'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python/curr'
  openssl_directory default_openssl_directory
  sqlite_directory default_sqlite_directory
  build_shared true
end

python_installation 'No Defaults' do
  version '3.6.9'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python/prev'
  openssl_directory default_openssl_directory
  sqlite_directory default_sqlite_directory
  build_shared true
  owner 'bud'
  group 'bud'
end
