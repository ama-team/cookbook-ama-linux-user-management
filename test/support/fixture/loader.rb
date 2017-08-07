# frozen_string_literal: true

require 'pathname'
require 'yaml'

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
              Pathname.new(path)
            end

            def fixture_root
              root.join('fixture')
            end

            def load(name, type)
              root = fixture_root.join(name)
              pattern = "#{root}/**/*.yml"
              Dir.glob(pattern).map do |path|
                begin
                  path = ::Pathname.new(path)
                  content = ::IO.read(path)
                  data = ::YAML.safe_load(content, [], [], true)
                  relative_path = path.relative_path_from(root)
                  AMA::Entity::Mapper.map(data, type).tap do |instance|
                    instance.id = relative_path.to_s.sub(/\.yml$/, '')
                  end
                rescue StandardError => e
                  raise "Unexpected error during loading #{path}: #{e.message}"
                end
              end
            end

            def fuse(target, name, type = nil)
              instance = self
              target.define_singleton_method(:each) do |*args, &block|
                instance.load(name, type || target).send(:each, *args, &block)
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
