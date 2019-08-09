# frozen_string_literal: true

# This module implements helpers that are used for resources
module PythonInstall
  # This module exposes helpers to the client
  module Public
  end
  # This module implements custom logic for this installer
  def Custom
  end
  # This module implements hooks into the base install
  def Hook
  end
  # This module implements helpers that are used for resources
  module Install
    def openssl_inc_directory(new_resource)
      return File.join(new_resource.openssl_directory, 'include')
    end

    def openssl_lib_directory(new_resource)
      return File.join(new_resource.openssl_directory, 'lib')
    end

    def sqlite_inc_directory(new_resource)
      return File.join(new_resource.sqlite_directory, 'include')
    end

    def sqlite_lib_directory(new_resource)
      return File.join(new_resource.sqlite_directory, 'lib')
    end

    def python_revision(new_resource)
      version_array = new_resource.version.split('.')
      revision = "#{version_array[0]}.#{version_array[1]}"
      return revision
    end

    def rel_path_to_python_binary(new_resource)
      revision = python_revision(new_resource)
      return "bin/python#{revision}"
    end

    def path_to_python_binary(install_directory, new_resource)
      return File.join(install_directory, rel_path_to_python_binary(new_resource))
    end

    def path_to_pip_binary(install_directory, new_resource)
      revision = python_revision(new_resource)
      return File.join(install_directory, "bin/pip#{revision}")
    end

    def make_python_link(install_directory, new_resource)
      link 'Python Link' do
        target_file File.join(install_directory, 'bin/python')
        to path_to_python_binary(install_directory, new_resource)
        owner new_resource.owner
        group new_resource.group
      end
    end

    def make_python3_link(install_directory, new_resource)
      link 'Python3 Link' do
        target_file File.join(install_directory, 'bin/python3')
        to path_to_python_binary(install_directory, new_resource)
        owner new_resource.owner
        group new_resource.group
      end
    end

    def make_python_links(install_directory, new_resource)
      make_python_link(install_directory, new_resource)
      make_python3_link(install_directory, new_resource)
    end

    def make_pip_link(install_directory, new_resource)
      link 'Pip Link' do
        target_file File.join(install_directory, 'bin/pip')
        to path_to_pip_binary(install_directory, new_resource)
        owner new_resource.owner
        group new_resource.group
      end
    end

    def make_pip3_link(install_directory, new_resource)
      link 'Pip3 Link' do
        target_file File.join(install_directory, 'bin/pip3')
        to path_to_pip_binary(install_directory, new_resource)
        owner new_resource.owner
        group new_resource.group
      end
    end

    def make_pip_links(install_directory, new_resource)
      make_pip_link(install_directory, new_resource)
      make_pip3_link(install_directory, new_resource)
    end

    def generate_bin_config(_install_directory, _new_resource)
      return ''
    end

    def generate_run_config(install_directory, new_resource)
      code = ''
      code += ",-rpath,#{openssl_lib_directory(new_resource)}" if new_resource.openssl_directory
      code += ",-rpath,#{sqlite_lib_directory(new_resource)}" if new_resource.sqlite_directory
      code += ",-rpath,#{File.join(install_directory, 'lib')}"
      return code
    end

    def generate_lib_config(install_directory, new_resource)
      code = ''
      code += 'export LDFLAGS="-Wl'
      code += generate_run_config(install_directory, new_resource)
      code += " -L#{openssl_lib_directory(new_resource)}" if new_resource.openssl_directory
      code += " -L#{sqlite_lib_directory(new_resource)}" if new_resource.sqlite_directory
      code += "\"\n"
      return code
    end

    def generate_inc_config(new_resource)
      any_config = new_resource.openssl_directory || new_resource.sqlite_directory
      code = ''
      code += 'export CPPFLAGS="' if any_config
      code += " -I#{openssl_inc_directory(new_resource)}" if new_resource.openssl_directory
      code += " -I#{sqlite_inc_directory(new_resource)}" if new_resource.sqlite_directory
      code += "\"\n" if any_config
      return code
    end

    def generate_configure_options(install_directory)
      code = ''
      code += ' --enable-shared'
      code += " --prefix=#{install_directory}"
      code += " --exec_prefix=#{install_directory}"
      code += ' --with-system-ffi'
      code += ' --enable-optimizations'
      return code
    end

    # Hooks for install

    def create_config_code(install_directory, new_resource)
      code = generate_bin_config(install_directory, new_resource)
      code += generate_lib_config(install_directory, new_resource)
      code += generate_inc_config(new_resource)
      code += ' ./configure'
      code += generate_configure_options(install_directory)
      return code
    end

    def base_name(_new_resource)
      return 'Python'
    end

    def extract_creates_file(_new_resource)
      return 'README.rst'
    end

    def archive_file_name(new_resource)
      return "#{base_name(new_resource)}-#{new_resource.version}.tgz"
    end

    def download_url(new_resource)
      return "https://www.python.org/ftp/python/#{new_resource.version}/#{archive_file_name(new_resource)}"
    end

    def archive_root_directory(new_resource)
      return "#{base_name(new_resource)}-#{new_resource.version}"
    end

    def bin_creates_file(new_resource)
      return rel_path_to_python_binary(new_resource)
    end

    def install_command(_new_resource)
      return 'make altinstall'
    end

    def post_build_logic(install_directory, new_resource)
      make_python_links(install_directory, new_resource)
      make_pip_links(install_directory, new_resource)
    end

    # For common install code see base_install cookbook
  end
end
