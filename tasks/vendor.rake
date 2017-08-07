# frozen_string_literal: true

task :vendor do
  require 'ama-entity-mapper'
  version = ::AMA::Entity::Mapper::Version::VERSION
  sh "gem install --install-dir files/default/vendor --no-document ama-entity-mapper -v '#{version}' --prerelease"
end
