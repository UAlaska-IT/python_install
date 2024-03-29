# frozen_string_literal: true

name 'python_install'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Provides a resource for installing Python from source'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

git_url = 'https://github.com/ualaska-it/python_install'
source_url git_url if respond_to?(:source_url)
issues_url "#{git_url}/issues" if respond_to?(:issues_url)

version '1.2.0'

supports 'ubuntu', '>= 16.0'
supports 'debian', '>= 9.0'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'
supports 'oracle', '>= 6.0'
supports 'fedora'
supports 'amazon'
# supports 'suse'
# supports 'opensuse'

chef_version '>= 14.0' if respond_to?(:chef_version)

depends 'openssl_install'
depends 'source_install'
depends 'sqlite_install'
