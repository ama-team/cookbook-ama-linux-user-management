# frozen_string_literal: true

require 'pathname'
require 'yaml'
require 'ama-entity-mapper'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class Loader
            INSTANCE = new

            def root
              path = (0..1).reduce(__dir__) do |directory, *|
                ::File.dirname(directory)
              end
              ::Pathname.new(path)
            end

            def fixture_root
              root.join('fixture')
            end

            def single(name, id, type)
              regexp = /\.yml$/
              id = "#{id}.yml" unless id =~ regexp
              path = fixture_root.join(name).join(id)
              content = ::IO.read(path)
              data = ::YAML.safe_load(content, [], [], true)
              AMA::Entity::Mapper.map(data, type).tap do |instance|
                instance.id = id.sub(regexp, '')
              end
            rescue StandardError => e
              raise "Unexpected error during loading #{path}: #{e.message}"
            end

            def load(name, type)
              root = fixture_root.join(name)
              pattern = "#{root}/**/*.yml"
              Dir.glob(pattern).map do |path|
                path = ::Pathname.new(path)
                relative_path = path.relative_path_from(root)
                single(name, relative_path.to_s, type)
              end
            end

            def fuse(target, name, type = nil)
              instance = self
              target.define_singleton_method(:each) do |*args, &block|
                instance.load(name, type || target).send(:each, *args, &block)
              end
              target.define_singleton_method(:single) do |id|
                instance.single(name, id, type || target)
              end
              target.send(:extend, ::Enumerable)
            end

            class << self
              Loader.instance_methods.each do |method|
                define_method(method) do |*args|
                  Loader::INSTANCE.send(method, *args)
                end
              end
            end
          end
        end
      end
    end
  end
end
