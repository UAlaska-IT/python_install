# frozen_string_literal: true

include_recipe 'python_install::default'

python_installation 'All Defaults' do
  # RHEL has ancient libs that are not supported by newer Pythons
  openssl_directory '/opt/openssl/1.1.1c' unless node['platform_family'] == 'debian'
end

directory '/usr/local/python-dl'

directory '/usr/local/python-bld'

directory '/usr/local/python'

user 'bud' do
  shell '/bin/bash'
end

include_recipe 'openssl_install::default'
include_recipe 'sqlite_install::default'

openssl_installation 'All defaults'

sqlite_installation 'All defaults'

python_installation 'No Defaults' do
  version '3.6.9'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python'
  openssl_directory '/opt/openssl/1.1.1c'
  sqlite_directory '/opt/sqlite/3280000'
  owner 'bud'
  group 'bud'
end
