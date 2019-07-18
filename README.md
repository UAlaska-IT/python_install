# Python Install Cookbook

[![License](https://img.shields.io/github/license/ualaska-it/python_install.svg)](https://github.com/ualaska-it/python_install)
[![GitHub Tag](https://img.shields.io/github/tag/ualaska-it/python_install.svg)](https://github.com/ualaska-it/python_install)
[![Build status](https://ci.appveyor.com/api/projects/status/l9gqxuw0yhlysnsi/branch/master?svg=true)](https://ci.appveyor.com/project/UAlaska/python-install/branch/master)

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This cookbook provides a single resource that downloads, configures, compiles, and installs Python.

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle
* Suse

Platforms validated via Test Kitchen:

* Ubuntu
* Debian
* CentOS
* Oracle
* Fedora
* Amazon
* Suse

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
  sqlite_directory '/opt/sqlite/3280000'
  owner 'some-dudette'
  group 'some-dudettes'
end
```

## Development

See CONTRIBUTING.md and TESTING.md.
