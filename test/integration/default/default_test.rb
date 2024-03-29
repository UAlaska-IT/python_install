# frozen_string_literal: true

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

LOCAL_GROUP =
  if node['platform'] == 'debian'
    'staff'
  else
    'root'
  end

LOCAL_MODE =
  if node['platform'] == 'debian'
    0o2755
  else
    0o755
  end

dev =
  if node['platform_family'] == 'debian'
    'dev'
  else
    'devel'
  end

BASE_NAME = 'python'
CURR_VER = '3.7.4'
SHARE_VER = '3.7.3'
PREV_VER = '3.6.9'

def revision(version)
  version_array = version.split('.')
  return "#{version_array[0]}.#{version_array[1]}"
end

CURR_REV = revision(CURR_VER)
SHARE_REV = revision(SHARE_VER)
PREV_REV = revision(PREV_VER)

def archive_file(version)
  return "#{BASE_NAME.capitalize}-#{version}.tgz"
end

def source_dir(version)
  return "#{BASE_NAME.capitalize}-#{version}"
end

# Packages installed by default recipe

describe package('gcc') do
  it { should be_installed }
end

describe package 'g++' do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package 'gcc-c++' do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package('make') do
  it { should be_installed }
end

describe package "libssl-#{dev}" do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package "openssl-#{dev}" do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package "libsqlite3-#{dev}" do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package "sqlite-#{dev}" do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("libbz2-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("bzip2-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("libexpat1-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("expat-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("libffi-#{dev}") do
  it { should be_installed }
end

describe package("libgdbm-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("libgdbm-compat-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian' && node['platform_version'].to_i > 16
end

describe package("gdbm-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("libreadline-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("readline-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("liblzma-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("xz-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("libmpdec-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("libncurses5-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("ncurses-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("tk-#{dev}") do
  it { should be_installed }
end

describe package("uuid-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("libuuid-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package("zlib1g-#{dev}") do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package("zlib-#{dev}") do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

# Created or assumed by test harness

[
  "/usr/local/#{BASE_NAME}-dl",
  "/usr/local/#{BASE_NAME}-bld",
  "/usr/local/#{BASE_NAME}",
  "/usr/local/#{BASE_NAME}/curr",
  "/usr/local/#{BASE_NAME}/prev"
].each do |conf|
  describe file conf do
    it { should exist }
    it { should be_directory }
    it { should be_mode LOCAL_MODE }
    it { should be_owned_by 'root' }
    it { should be_grouped_into LOCAL_GROUP }
  end
end

describe user 'bud' do
  it { should exist }
  its('group') { should eq 'bud' }
  its('groups') { should eq ['bud'] }
  its('home') { should eq '/home/bud' }
  its('shell') { should eq '/bin/bash' }
end

describe file '/opt/openssl/1.1.1d' do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file '/opt/sqlite/3300000' do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

# Begin white-box testing of resources

describe file '/var/chef' do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file '/var/chef/cache' do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{archive_file(CURR_VER)}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-dl/#{archive_file(SHARE_VER)}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-dl/#{archive_file(PREV_VER)}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/var/chef/cache/#{source_dir(CURR_VER)}" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(SHARE_VER)}" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(PREV_VER)}" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{CURR_VER}-dl-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{SHARE_VER}-dl-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{PREV_VER}-dl-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{CURR_VER}-src-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{SHARE_VER}-src-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{PREV_VER}-src-checksum" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{source_dir(CURR_VER)}/README.rst" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(SHARE_VER)}/README.rst" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(PREV_VER)}/README.rst" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}" do
  it { should exist }
  it { should be_directory }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/var/chef/cache/#{source_dir(CURR_VER)}/Makefile" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(SHARE_VER)}/Makefile" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}-bld/#{source_dir(PREV_VER)}/Makefile" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{CURR_VER}-config" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should_not match(%r{-I/opt/openssl/1\.1\.1d/include}) } if node['platform_family'] == 'debian'
  its(:content) { should_not match(%r{-rpath,/opt/openssl/1\.1\.1d/lib}) } if node['platform_family'] == 'debian'
  its(:content) { should match(%r{-I/opt/openssl/1\.1\.1d/include}) } unless node['platform_family'] == 'debian'
  its(:content) { should match(%r{-rpath,/opt/openssl/1\.1\.1d/lib}) } unless node['platform_family'] == 'debian'
  its(:content) { should match(%r{-rpath,/opt/python/#{CURR_VER}}) }
  its(:content) { should match(%r{--prefix=/opt/python/#{CURR_VER}}) }
  its(:content) { should match(%r{--exec_prefix=/opt/python/#{CURR_VER}}) }
  its(:content) { should_not match(/--enable-shared/) }
  its(:content) { should match(/--enable-optimizations/) }
end

[
  "/var/chef/cache/#{BASE_NAME}-#{SHARE_VER}-config",
  "/var/chef/cache/#{BASE_NAME}-#{PREV_VER}-config"
].each do |conf|
  describe file conf do
    it { should exist }
    it { should be_file }
    it { should be_mode 0o644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match(%r{-I/opt/openssl/1\.1\.1d/include}) }
    its(:content) { should match(%r{-rpath,/opt/openssl/1\.1\.1d/lib}) }
    its(:content) { should match(%r{-I/opt/sqlite/3300000/include}) }
    its(:content) { should match(%r{-rpath,/opt/sqlite/3300000/lib}) }
    its(:content) { should match(/--enable-shared/) }
  end
end

describe file "/var/chef/cache/#{BASE_NAME}-#{SHARE_VER}-config" do
  its(:content) { should match(%r{-rpath,/usr/local/#{BASE_NAME}/curr/lib}) }
  its(:content) { should match(%r{--prefix=/usr/local/#{BASE_NAME}/curr}) }
  its(:content) { should match(%r{--exec_prefix=/usr/local/#{BASE_NAME}/curr}) }
  its(:content) { should match(/--enable-optimizations/) }
end

describe file "/var/chef/cache/#{BASE_NAME}-#{PREV_VER}-config" do
  its(:content) { should match(%r{-rpath,/usr/local/#{BASE_NAME}/prev/lib}) }
  its(:content) { should match(%r{--prefix=/usr/local/#{BASE_NAME}/prev}) }
  its(:content) { should match(%r{--exec_prefix=/usr/local/#{BASE_NAME}/prev}) }
  its(:content) { should_not match(/--enable-optimizations/) }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/include/#{BASE_NAME}#{CURR_REV}m/pyconfig.h" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/include/#{BASE_NAME}#{SHARE_REV}m/pyconfig.h" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/include/#{BASE_NAME}#{PREV_REV}m/pyconfig.h" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/lib/lib#{BASE_NAME}3.so" do
  it { should_not exist }
end

describe file "/usr/local/#{BASE_NAME}/curr/lib/lib#{BASE_NAME}3.so" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o555 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/lib/lib#{BASE_NAME}3.so" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o555 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}#{CURR_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}#{SHARE_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}#{PREV_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/pip#{CURR_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/pip#{SHARE_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/pip#{PREV_REV}" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/pip3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/pip3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/pip3" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe file "/opt/#{BASE_NAME}/#{CURR_VER}/bin/pip" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/curr/bin/pip" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file "/usr/local/#{BASE_NAME}/prev/bin/pip" do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o755 }
  it { should be_owned_by 'bud' }
  it { should be_grouped_into 'bud' }
end

describe bash "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}3 --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/3\.7\.4/) }
end

describe bash "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}3 --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/3\.7\.3/) }
end

describe bash "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}3 --version" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/3\.6\.9/) }
end

describe bash "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}3 -c 'import ssl; print(ssl.OPENSSL_VERSION)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should_not match(/1\.1\.1d/) } if node['platform_family'] == 'debian'
  its(:stdout) { should match(/1\.1\.1d/) } unless node['platform_family'] == 'debian'
end

describe bash "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}3 -c 'import ssl; print(ssl.OPENSSL_VERSION)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/1\.1\.1d/) }
end

describe bash "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}3 -c 'import ssl; print(ssl.OPENSSL_VERSION)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/1\.1\.1d/) }
end

describe bash "/opt/#{BASE_NAME}/#{CURR_VER}/bin/#{BASE_NAME}3 -c 'import sqlite3; print(sqlite3.sqlite_version)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should_not match(/3\.30\.0/) } # Different on every distro
end

describe bash "/usr/local/#{BASE_NAME}/curr/bin/#{BASE_NAME}3 -c 'import sqlite3; print(sqlite3.sqlite_version)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/3\.30\.0/) }
end

describe bash "/usr/local/#{BASE_NAME}/prev/bin/#{BASE_NAME}3 -c 'import sqlite3; print(sqlite3.sqlite_version)'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/3\.30\.0/) }
end
