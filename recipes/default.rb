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

package 'gcc'
package 'make'

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
