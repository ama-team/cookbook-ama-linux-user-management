# frozen_string_literal: true

require 'ama-entity-mapper'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class Resource
              include Entity::Mapper::DSL

              any_type = Entity::Mapper::Type::Any::INSTANCE

              attribute :type, Symbol
              attribute :name, String
              attribute :action, Symbol
              attribute :attributes, [Hash, K: Symbol, V: any_type], nullable: true, default: {}

              denormalizer_block do |input, type, context, &block|
                if input.is_a?(String) || input.is_a?(Symbol)
                  input = { action: input }
                end
                unless input.is_a?(Hash)
                  raise "Hash expected, got #{input.class}"
                end
                if ['name', :name].none? { |key| input.key?(key) }
                  input[:name] = context.path.current.name
                end
                if ['type', :type].none? { |key| input.key?(key) }
                  input[:type] = context.path.segments[-2].name
                end
                block.call(input, type, context)
              end

              def id
                "#{@type}[#{@name}]"
              end
            end
          end
        end
      end
    end
  end
end
