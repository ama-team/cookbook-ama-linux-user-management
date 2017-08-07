# frozen_string_literal: true

root = ::File.dirname(__dir__)
vendor_dir = ::File.join(root, 'files', 'default', 'vendor')
spec_pattern = ::File.join(vendor_dir, 'specifications', '*.gemspec')
Dir.glob(spec_pattern).each do |spec_path|
  spec = Gem::Specification.load(spec_path)
  Chef::Log.debug("Loading vendored gem #{spec.name} #{spec.version}")
  spec.require_paths.each do |require_path|
    path = ::File.join(vendor_dir, "#{spec.name}-#{spec.version}", require_path)
    Chef::Log.debug("Adding vendored gem path '#{require_path}' to load path")
    $LOAD_PATH.unshift(path)
  end
end

library_dir = ::File.join(root, 'lib')
library_pattern = ::File.join(library_dir, '**', '*.rb')

Dir.glob(library_pattern).each do |path|
  Chef::Log.debug("Requiring library file: #{path}")
  require(path)
end
