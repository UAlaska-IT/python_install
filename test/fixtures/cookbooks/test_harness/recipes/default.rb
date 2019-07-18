# frozen_string_literal: true

include_recipe 'python_install::default'

python_installation 'All Defaults'

directory '/usr/local/python-dl'

directory '/usr/local/python-bld'

directory '/usr/local/python'

user 'bud' do
  shell '/bin/bash'
end

python_installation 'No Defaults' do
  version '3.6.9'
  download_directory '/usr/local/python-dl'
  build_directory '/usr/local/python-bld'
  install_directory '/usr/local/python'
  owner 'bud'
  group 'bud'
end
