# frozen_string_literal: true

require 'allure-rspec'
require 'English'
require 'uuid'

module AMA
  module Chef
    module User
      module Test
        module Allure
          module DSL
            def attach_yaml(data, title = 'data', **options)
              file = Tempfile.new
              begin
                unless options[:mime_type]
                  options[:mime_type] = 'application/yaml'
                end
                normalized = ::AMA::Entity::Mapper.normalize(data)
                yaml = ::YAML.dump(normalized)
                content = "# random string: #{UUID.generate}\n#{yaml}"
                IO.write(file.path, content)
                title = "#{title}.yml" unless title =~ /\.yml^/
                attach_file(title, file, **options)
              ensure
                file.close(true)
              end
            end

            def attach_data(data, title = 'data', **options)
              attach_yaml(data, title, **options)
            end

            def attach_resources(resources, title = 'chef.resources', **opts)
              resource_mapping
              attach_yaml(resources.map(&:itself), title, **opts)
            end

            def ignored_resource_attributes
              %w[
                allowed_actions
                before
                enclosing_provider
                guard_interpreter
                not_if
                only_if
                provider
                run_context
              ]
            end

            def resource_mapping
              return if Entity::Mapper[::Chef::Resource]
              mapping = Entity::Mapper::Type.new(::Chef::Resource)
              ignored_attributes = ignored_resource_attributes
              mapping.normalizer_block do |input, *|
                variables = input.instance_variables
                variables.each_with_object({}) do |variable, carrier|
                  variable_name = variable[1..-1]
                  next if ignored_attributes.include?(variable_name)
                  carrier[variable_name] = input.instance_variable_get(variable)
                end
              end
              Entity::Mapper.types.register(mapping)
              mapping
            end
          end
        end
      end
    end
  end
end
