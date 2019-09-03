# Python Install Cookbook

[![License](https://img.shields.io/github/license/ualaska-it/python_install.svg)](https://github.com/ualaska-it/python_install)
[![GitHub Tag](https://img.shields.io/github/tag/ualaska-it/python_install.svg)](https://github.com/ualaska-it/python_install)
[![Build status](https://ci.appveyor.com/api/projects/status/l9gqxuw0yhlysnsi/branch/master?svg=true)](https://ci.appveyor.com/project/UAlaska/python-install/branch/master)

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This cookbook provides a single resource that downloads, configures, compiles, and installs Python.
As Python is built from source, build times can be long, especially for Python 3.7.
If building OpenSSL, SQLite, and Python, the first run builds can take more than a half hour.

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle

Platforms validated via Test Kitchen:

* Ubuntu
* Debian
* CentOS
* Oracle
* Fedora
* Amazon

Notes:

* This cookbook should support any recent Linux variant.

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.
It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides one resource for creating an Python installation.

### python_installation

This resource provides a single action to create an Python installation.

__Actions__

One action is provided.

* `:create` - Post condition is that source and binary artifacts exist in specified directories.

__Attributes__

* `version` - Defaults to `nil`.
The version of Python to install.
If nil, will default to the latest version when this cookbook was updated.
The helper `default_python_version` is provided for fetching this value.
* `download_directory` - Defaults to `nil`.
The local path to the directory into which to download the source archive.
See note below about paths.
* `build_directory` - Defaults to `nil`.
The local path to the directory into which to decompress and build the source code.
See note below about paths.
* `install_directory` - Defaults to `nil`.
The local path to the directory into which to install the binary artifacts.
If nil, will default to a platform-standard location.
The helper `default_python_directory` is provided for fetching this location.
See note below about paths.
* `openssl_directory` - Defaults to `nil`.
The local path to the directory where OpenSSL is installed.
If nil, system OpenSSL will be used and must be installed prior to this resource running.
For an OpenSSL resource, see the [openssl_install cookbook](https://github.com/UAlaska-IT/openssl_install)
* `sqlite_directory` - Defaults to `nil`.
The local path to the directory where SQLite is installed.
If nil, system SQLite will be used and must be installed prior to this resource running.
For an SQLite resource, see the [sqlite_install cookbook](https://github.com/UAlaska-IT/sqlite_install)
* `build_shared` - Defaults to `false`.
If true, shared libraries are built.
Building shared libraries increases build time noticeably.
For Python 3.6 (not 3.5, not 3.7) this will also disable optimizations to workaround an [issue in the Python build system](https://bugs.python.org/issue29712).
* `owner` - Defaults to `root`.
The owner of all artifacts.
* `group` - Defaults to `root`.
The group of all artifacts.

__Note on paths__

If a path is set for download, build or install, then the client must assure the directory exists before the resource runs.
The resource runs as root and sets permissions on any created files, so is capable of placing a user-owned directory in a root-owned directory.

Fairly standard defaults are used for paths.
If download_directory or build_directory is nil (default), '/var/chef/cache' will be used.
If install directory is nil (default), "/opt/python/#{version}" will be created and used.

For build_directory, the path given is the _parent_ of the source root that is created when the archive is extracted.
For example, if build_directory is set to '/usr/local/python-src', then the source root will be "/usr/local/python-src/Python-#{version}".

For install_directory, the path given is the root of the install.
For example, if install_directory is set to '/usr/local/python', then the path to the Python executable will be '/usr/local/python/bin/python'.
The lib path must be added to linker and runtime configurations (typically use -L and rpath, respectively) for dependents to load the custom libraries.

## Recipes

This cookbook provides no recipes.

## Examples

Custom resources can be used as below.

```ruby
python_installation 'No Defaults' do
  version '3.6.9'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python'
  openssl_directory '/opt/openssl/1.1.1c'
  sqlite_directory '/opt/sqlite/3290000'
  owner 'some-dude'
  group 'some-dudes'
end
```

## Development

See CONTRIBUTING.md and TESTING.md.
