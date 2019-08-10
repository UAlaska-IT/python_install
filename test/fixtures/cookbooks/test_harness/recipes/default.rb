# frozen_string_literal: true

include_recipe 'python_install::default'

include_recipe 'openssl_install::default' unless node['platform_family'] == 'debian'

openssl_installation 'All defaults' unless node['platform_family'] == 'debian'

python_installation 'All Defaults' do
  # RHEL has ancient libs that are not supported by newer Pythons
  openssl_directory default_openssl_directory unless node['platform_family'] == 'debian'
end

directory '/usr/local/python-dl'

directory '/usr/local/python-bld'

directory '/usr/local/python'

user 'bud' do
  shell '/bin/bash'
end

include_recipe 'openssl_install::default' if node['platform_family'] == 'debian'

openssl_installation 'All defaults' if node['platform_family'] == 'debian'

include_recipe 'sqlite_install::default'

sqlite_installation 'All defaults'

python_installation 'No Defaults' do
  version '3.6.9'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python'
  openssl_directory default_openssl_directory
  sqlite_directory default_sqlite_directory
  owner 'bud'
  group 'bud'
end
