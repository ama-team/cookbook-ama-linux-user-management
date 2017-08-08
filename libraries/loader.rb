# frozen_string_literal: true

require 'chef'

root = ::File.dirname(__dir__)
vendor_dir = ::File.join(root, 'files', 'default', 'vendor')
spec_pattern = ::File.join(vendor_dir, 'specifications', '*.gemspec')
Dir.glob(spec_pattern).each do |spec_path|
  spec = Gem::Specification.load(spec_path)
  ::Chef::Log.debug("Loading vendored gem #{spec.name} #{spec.version}")
  spec.require_paths.each do |require_path|
    directory = "#{spec.name}-#{spec.version}"
    path = ::File.join(vendor_dir, 'gems', directory, require_path)
    Chef::Log.debug("Adding vendored gem path '#{require_path}' to load path")
    $LOAD_PATH.unshift(path)
  end
end

require 'ama-entity-mapper'

library_dir = ::File.join(root, 'files', 'default', 'lib')
library_pattern = ::File.join(library_dir, '**', '*.rb')

Dir.glob(library_pattern).each do |path|
  Chef::Log.debug("Requiring library file: #{path}")
  require(path)
end
