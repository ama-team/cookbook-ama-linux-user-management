# frozen_string_literal: true

require 'ama-entity-mapper'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class Assertion
              include AMA::Entity::Mapper::DSL

              attribute :type, Symbol
              attribute :name, Symbol
              attribute :content, [Enumerable, T: :*]
              attribute :property, Symbol

              denormalizer_block do |input, type, context, &block|
                input = input.split(' ') if input.is_a?(String)
                unless input.is_a?(Enumerable)
                  raise "Expected Enumerable, got #{input.class}"
                end
                input = { content: input } unless input.is_a?(Hash)
                unless [:property, 'property'].any?(&input.method(:key?))
                  input[:property] = context.path.segments[-2].name
                end
                unless [:name, 'name'].any?(&input.method(:key?))
                  input[:name] = context.path.segments[-3].name
                end
                unless [:type, 'type'].any?(&input.method(:key?))
                  input[:type] = context.path.segments[-4].name
                end
                block.call(input, type, context)
              end

              def to_def
                prop = property == :it ? '' : property
                "#{type}[#{name}].#{prop} should #{content.join(' ')}"
              end

              def to_s
                "Assertion: #{to_def}"
              end
            end
          end
        end
      end
    end
  end
end
