# frozen_string_literal: true

module AMA
  module Chef
    module User
      module Test
        module ChefSpec
          class SoloRunner < ::ChefSpec::SoloRunner
            def initialize(**configuration)
              @example = configuration[:example]
              @group = configuration[:group]
              @logger = create_logger(@example)
              @original_logger = ::Chef::Log.logger
              ::Chef::Log.logger = @logger
              super
              @injected_data_bags = configuration[:data_bags] || {}
              @injected_attributes = configuration[:attributes]
              setup_attributes(configuration[:attributes] || {})
              setup_data_bags(@group, configuration[:data_bags] || {})
            end

            def converge(*)
              @example.attach_yaml(node.attributes, 'chef.attributes.initial')
              name = 'chef.attributes.injected'
              @example.attach_yaml(@injected_attributes, name)
              @example.attach_yaml(@injected_data_bags, 'chef.data_bags')
              return super
            ensure
              @example.attach_resources(resource_collection)
              @example.attach_yaml(node.attributes, 'chef.attributes.final')
            end

            def close
              @logger.close
              ::Chef::Log.logger = @original_logger
            end

            private

            def create_logger(example)
              target = Tempfile.new('ama-linux-user-management-')
              Logger.new(target).tap do |logger|
                logger.define_singleton_method(:target) do
                  target
                end
                handler = logger.method(:close)
                logger.define_singleton_method(:close) do |*args|
                  handler.call(*args)
                  options = { mime_type: 'text/plain' }
                  example.attach_file('chef.log', target, options)
                  target.unlink
                end
              end
            end

            def setup_data_bags(group, data_bags)
              @injected_data_bags ||= {}
              data_bags.each do |name, content|
                group.stub_data_bag(name).and_return(content.keys)
                data_bag = {}
                content.each do |id, value|
                  normalized = normalize(value)
                  group.stub_data_bag_item(name, id).and_return(normalized)
                  data_bag[id] = normalized
                end
                @injected_data_bags[name] = data_bag
              end
            end

            def setup_attributes(attributes)
              @injected_attributes ||= {}
              attributes.each do |key, value|
                normalized = normalize(value)
                node.normal[key] = normalized
                @injected_attributes[key] = normalized
              end
            end

            def normalize(data)
              options = { include_sensitive_attributes: true }
              Entity::Mapper.normalize(data, **options)
            end
          end
        end
      end
    end
  end
end
