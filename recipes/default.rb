# frozen_string_literal: true

dev =
  if node['platform_family'] == 'debian'
    'dev'
  else
    'devel'
  end

apt_update 'Pre-Install Update' do
  action :update
end

include_recipe 'openssl_install::default'

include_recipe 'sqlite_install::default'

package 'gcc'
package 'g++' if node['platform_family'] == 'debian'
package 'gcc-c++' unless node['platform_family'] == 'debian'
package 'make'

# Essential dependencies, in case we are using system versions

package "libssl-#{dev}" if node['platform_family'] == 'debian'
package "openssl-#{dev}" unless node['platform_family'] == 'debian'

package "libsqlite3-#{dev}" if node['platform_family'] == 'debian'
package "sqlite-#{dev}" unless node['platform_family'] == 'debian'

# Optional dependencies

package "libbz2-#{dev}" if node['platform_family'] == 'debian'
package "bzip2-#{dev}" unless node['platform_family'] == 'debian'

package "libffi-#{dev}"

package "libgdbm-#{dev}" if node['platform_family'] == 'debian'
package "libgdbm-compat-#{dev}" if node['platform_family'] == 'debian' && node['platform_version'].to_i > 16
package "gdbm-#{dev}" unless node['platform_family'] == 'debian'

package "libreadline-#{dev}" if node['platform_family'] == 'debian'
package "readline-#{dev}" unless node['platform_family'] == 'debian'

package "liblzma-#{dev}" if node['platform_family'] == 'debian'
package "xz-#{dev}" unless node['platform_family'] == 'debian'

package "libncurses5-#{dev}" if node['platform_family'] == 'debian'
package "ncurses-#{dev}" unless node['platform_family'] == 'debian'

package "tk-#{dev}"

package "uuid-#{dev}" if node['platform_family'] == 'debian'
package "libuuid-#{dev}" unless node['platform_family'] == 'debian'

package "zlib1g-#{dev}" if node['platform_family'] == 'debian'
package "zlib-#{dev}" unless node['platform_family'] == 'debian'
