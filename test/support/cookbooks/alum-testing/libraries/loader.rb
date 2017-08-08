# frozen_string_literal: true

cookbook_root = ::File.realpath(::File.dirname(__dir__))
cookbook_repo = ::File.dirname(cookbook_root)
project_root = (0..2).reduce(cookbook_repo) { |path| ::File.dirname(path) }
library_root = ::File.join(cookbook_root, 'files', 'default', 'lib')
pattern = ::File.join(library_root, '**', '*.rb')

parent_loader_candidates = [cookbook_repo, project_root].map do |path|
  "#{path}/libraries/loader.rb"
end
parent_loader_candidates.each do |path|
  next unless ::File.exist?(path)
  require path.sub(/\.rb$/, '')
end

Dir.glob(pattern).each do |path|
  require path.sub(/\.rb$/, '')
end
