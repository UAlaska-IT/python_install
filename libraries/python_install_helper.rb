# frozen_string_literal: true

# This module implements helpers that are used for resources
module PythonInstall
  # This module implements helpers that are used for resources
  module Helper
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

    def generate_runtime_config(new_resource)
      code = ''
      code += ",-rpath,#{openssl_lib_directory(new_resource)}" if new_resource.openssl_directory
      code += ",-rpath,#{sqlite_lib_directory(new_resource)}" if new_resource.sqlite_directory
      return code
    end

    def generate_linker_config(new_resource)
      code = ''
      code += " -L#{openssl_lib_directory(new_resource)}" if new_resource.openssl_directory
      code += " -L#{sqlite_lib_directory(new_resource)}" if new_resource.sqlite_directory
      return code
    end

    def generate_ld_config(new_resource)
      any_config = new_resource.openssl_directory || new_resource.sqlite_directory
      code = ''
      code += 'LDFLAGS="-Wl' if any_config
      code += generate_runtime_config(new_resource)
      code += generate_linker_config(new_resource)
      code += '\"' if any_config
      return code
    end

    def generate_include_config(new_resource)
      any_config = new_resource.openssl_directory || new_resource.sqlite_directory
      code = ''
      code += ' CPPFLAGS=\"' if any_config
      code += " -I#{openssl_inc_directory(new_resource)}" if new_resource.openssl_directory
      code += " -I#{sqlite_inc_directory(new_resource)}" if new_resource.sqlite_directory
      code += '\"' if any_config
      return code
    end

    def create_config_code(install_directory, new_resource)
      code = generate_ld_config(new_resource)
      code += generate_include_config(new_resource)
      code += ' ./configure'
      code += " --prefix=#{install_directory}"
      code += " --with-openssl=#{new_resource.openssl_directory}" if new_resource.openssl_directory
      code += ' --with-system-ffi'
      # Optimizations are broken on ancient CentOS package versions
      code += ' --enable-optimizations' if node['platform_family'] == 'debian'
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

    def post_build_logic(install_directory, new_resource)
      make_python_links(install_directory, new_resource)
      make_pip_links(install_directory, new_resource)
    end

    def create_default_directories
      directory '/var/chef' do
        mode 0o755
        owner 'root'
        group 'root'
      end
      directory '/var/chef/cache' do
        mode 0o755
        owner 'root'
        group 'root'
      end
    end

    def path_to_download_directory(new_resource)
      return new_resource.download_directory if new_resource.download_directory

      create_default_directories
      return '/var/chef/cache'
    end

    def path_to_download_file(new_resource)
      directory = path_to_download_directory(new_resource)
      file = File.join(directory, archive_file_name(new_resource))
      return file
    end

    def download_archive(new_resource)
      download_file = path_to_download_file(new_resource)
      url = download_url(new_resource)
      remote_file download_file do
        source url
        owner new_resource.owner
        group new_resource.group
      end
      return download_file
    end

    def path_to_build_directory(new_resource)
      base = archive_root_directory(new_resource)
      return File.join(new_resource.build_directory, base) if new_resource.build_directory

      create_default_directories
      return File.join('/var/chef/cache', base)
    end

    def clear_source_directory(build_directory, new_resource)
      dir = build_directory
      bash 'Clear Archive' do
        code "rm -rf #{dir}\nmkdir #{dir}\nchmod #{new_resource.owner} #{dir}\nchgrp #{new_resource.group} #{dir}"
        # Run as root so we blow it away if the owner changes
        action :nothing
        subscribes :run, 'checksum_file[Download Checksum]', :immediate
      end
    end

    def manage_source_directory(download_file, build_directory, new_resource)
      checksum_file 'Download Checksum' do
        source_path download_file
        target_path "/var/chef/cache/#{base_name(new_resource).downcase}-#{new_resource.version}-dl-checksum"
      end
      clear_source_directory(build_directory, new_resource)
    end

    def extract_command(filename)
      return 'unzip -q' if filename.match?(/\.zip/)

      return 'tar xzf' if filename.match?(/\.(:?tar\.gz|tgz)/)

      raise "Archive not supported: #{filename}"
    end

    def code_for_extraction(download_file, build_directory, new_resource)
      code = <<~CODE
        #{extract_command(download_file)} #{download_file}
        chown -R #{new_resource.owner} #{build_directory}
        chgrp -R #{new_resource.group} #{build_directory}
      CODE
      return code
    end

    def extract_download(download_file, build_directory, new_resource)
      # Built-in archive_file requires Chef 15 and poise_archive is failing to exhibit idempotence on zip files
      parent = File.dirname(build_directory)
      code = code_for_extraction(download_file, build_directory, new_resource)
      bash 'Extract Archive' do
        code code
        cwd parent
        # Run as root in case it is installing in directory without write access
        creates File.join(build_directory, extract_creates_file(new_resource))
      end
    end

    def extract_archive(build_directory, new_resource)
      download_file = download_archive(new_resource)
      manage_source_directory(download_file, build_directory, new_resource)
      extract_download(download_file, build_directory, new_resource)
    end

    def default_install_directory(new_resource)
      return "/opt/#{base_name(new_resource).downcase}/#{new_resource.version}"
    end

    def create_opt_directories(new_resource)
      directory "/opt/#{base_name(new_resource).downcase}" do
        mode 0o755
        owner 'root'
        group 'root'
      end
      directory default_install_directory(new_resource) do
        mode 0o755
        owner 'root'
        group 'root'
      end
    end

    def path_to_install_directory(new_resource)
      return new_resource.install_directory if new_resource.install_directory

      create_opt_directories(new_resource)
      return default_install_directory(new_resource)
    end

    def configure_build(build_directory, install_directory, new_resource)
      code = create_config_code(install_directory, new_resource)
      bash 'Configure Build' do
        code code
        cwd build_directory
        user new_resource.owner
        group new_resource.group
        creates File.join(build_directory, 'Makefile')
      end
    end

    def check_build_directory(build_directory, new_resource)
      checksum_file 'Source Checksum' do
        source_path build_directory
        target_path "/var/chef/cache/#{base_name(new_resource).downcase}-#{new_resource.version}-src-checksum"
      end
    end

    def manage_bin_file(bin_file)
      file bin_file do
        action :nothing
        manage_symlink_source false
        subscribes :delete, 'checksum_file[Source Checksum]', :immediate
      end
    end

    def execute_build(build_directory, bin_file, new_resource)
      bash 'Compile' do
        code 'make'
        cwd build_directory
        user new_resource.owner
        group new_resource.group
        creates bin_file
      end
    end

    def execute_install(build_directory, bin_file)
      bash 'Install' do
        code 'make install'
        cwd build_directory
        # Run as root in case it is installing in directory without write access
        creates bin_file
      end
    end

    def recurse_command(path)
      return ' -R' if File.directory?(path)

      return ''
    end

    def command_for_file(install_directory, filename, new_resource)
      path = File.join(install_directory, filename)
      recurse = recurse_command(path)
      return "\nchown#{recurse} #{new_resource.owner} #{path}\nchgrp#{recurse} #{new_resource.group} #{path}"
    end

    def iterate_install_directory(install_directory, new_resource)
      command = ''
      Dir.foreach(install_directory) do |filename|
        next if ['.', '..'].include?(filename)

        command += command_for_file(install_directory, filename, new_resource)
      end
      return command
    end

    def build_permission_command(install_directory, new_resource)
      ruby_block 'Build Children' do
        block do
          files = iterate_install_directory(install_directory, new_resource)
          node.run_state['build_permission_command'] = files
        end
        action :nothing
        subscribes :run, 'bash[Install]', :immediate
      end
    end

    # Some install scripts create artifacts in the source directory
    def set_src_permissions(build_directory, new_resource)
      bash 'Set Config Permissions' do
        code "chown -R #{new_resource.owner} #{build_directory}\nchgrp -R #{new_resource.group} #{build_directory}"
        action :nothing
        subscribes :run, 'bash[Install]', :immediate
      end
    end

    def set_install_permissions(build_directory, install_directory, new_resource)
      build_permission_command(install_directory, new_resource)
      bash 'Change Install Permissions' do
        code(lazy { node.run_state['build_permission_command'] })
        cwd install_directory
        action :nothing
        subscribes :run, 'bash[Install]', :immediate
      end
      set_src_permissions(build_directory, new_resource)
    end

    def make_build(build_directory, install_directory, bin_file, new_resource)
      execute_build(build_directory, bin_file, new_resource)
      execute_install(build_directory, bin_file)
      set_install_permissions(build_directory, install_directory, new_resource)
    end

    def compile_and_install(build_directory, install_directory, new_resource)
      check_build_directory(build_directory, new_resource)
      bin_file = File.join(install_directory, bin_creates_file(new_resource))
      manage_bin_file(bin_file)
      make_build(build_directory, install_directory, bin_file, new_resource)
    end

    def build_binary(build_directory, new_resource)
      install_directory = path_to_install_directory(new_resource)
      configure_build(build_directory, install_directory, new_resource)
      compile_and_install(build_directory, install_directory, new_resource)
      post_build_logic(install_directory, new_resource)
    end

    def create_install(new_resource)
      build_directory = path_to_build_directory(new_resource)
      extract_archive(build_directory, new_resource)
      build_binary(build_directory, new_resource)
    end
  end
end
