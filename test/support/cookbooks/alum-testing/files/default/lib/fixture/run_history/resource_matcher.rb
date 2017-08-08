# frozen_string_literal: true

require 'ama-entity-mapper'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class ResourceMatcher
              include AMA::Entity::Mapper::DSL

              attribute :type, Symbol
              attribute :name, String
              attribute :action, Symbol, NilClass
              attribute :properties, [Hash, K: Symbol, V: :*], nullable: true, default: {}
              attribute :inverse, TrueClass, FalseClass, default: false

              denormalizer_block do |input, type, context, &block|
                if [TrueClass, FalseClass].any? { |klass| input.is_a?(klass) }
                  input = { inverse: !input }
                elsif [String, Symbol].any? { |klass| input.is_a?(klass) }
                  input = { action: input }
                end
                unless input.is_a?(Hash)
                  raise "Hash expected, got #{input.class}"
                end
                if ['name', :name].none? { |key| input.key?(key) }
                  input[:name] = context.path.segments[-2].name
                end
                if ['type', :type].none? { |key| input.key?(key) }
                  input[:type] = context.path.segments[-3].name
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
