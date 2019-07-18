# frozen_string_literal: true

resource_name :python_installation
provides :python_installation

default_action :create

property :version, String, default: '3280000'
property :download_directory, [String, nil], default: nil
property :build_directory, [String, nil], default: nil
property :install_directory, [String, nil], default: nil
property :owner, String, default: 'root'
property :group, String, default: 'root'

action :create do
  create_install(@new_resource)
end

action_class do
  include PythonInstall::Helper
end
