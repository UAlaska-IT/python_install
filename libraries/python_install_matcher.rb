# frozen_string_literal: true

if defined?(ChefSpec)
  ChefSpec.define_matcher(:python_installation)

  def create_python_installation(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:python_installation, :create, resource)
  end
end
