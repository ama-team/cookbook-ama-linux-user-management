# frozen_string_literal: true

require_relative '../mixin/entity'

module AMA
  module Chef
    module User
      module Model
        # Helper class for mangling entity policies
        class Policy
          include Comparable
          include Mixin::Entity

          def self.values
            %i[none edit manage]
          end

          attribute :value, Symbol, values: values, default: :none

          normalizer_block do |entity, *|
            entity.value
          end

          denormalizer_block do |input, type, context, &block|
            if input.is_a?(String) || input.is_a?(Symbol)
              input = { value: input }
            end
            block.call(input, type, context)
          end

          def initialize(value = :none)
            self.value = value
          end

          NONE = new(:none)
          EDIT = new(:edit)
          MANAGE = new(:manage)

          def self.wrap(value)
            return value if value.is_a?(Policy)
            condition = value.is_a?(String) || value.is_a?(Symbol)
            if condition && Policy.const_defined?(value.upcase)
              return Policy.const_get(value.upcase)
            end
            raise ArgumentError, "Invalid policy value: #{value}"
          end

          def edit?
            self > NONE
          end

          def create?
            self > NONE
          end

          def remove?
            self == MANAGE
          end

          def manage?
            self == MANAGE
          end

          def nothing?
            self == NONE
          end

          def <=>(other)
            other = Policy.wrap(other)
            unless other.is_a?(Policy)
              raise ArgumentError, "Invalid input: #{other.inspect}"
            end
            values = self.class.values
            values.index(value) - values.index(other.value)
          end

          def eq?(other)
            return false unless other.is_a?(Policy)
            other.value == @value
          end

          def ==(other)
            eq?(other)
          end

          def to_s
            value.to_s
          end
        end
      end
    end
  end
end
