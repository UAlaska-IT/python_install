# frozen_string_literal: true

resource_name :python_installation
provides :python_installation

default_action :create

action :create do
  create_install(@new_resource)
end

action_class do
  include PythonInstall::Helper
end
