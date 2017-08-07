# frozen_string_literal: true

require 'ama-entity-mapper'

module AMA
  module Chef
    module User
      module Mixin
        # Base methods for entities (models) used across project
        module Entity
          class << self
            def included(klass)
              klass.send(:include, AMA::Entity::Mapper::DSL)
            end
          end

          def ==(other)
            eql?(other)
          end

          def eql?(other)
            return false unless other.is_a?(self.class) || is_a?(other.class)
            return false unless other.instance_variables == instance_variables
            instance_variables.each do |variable|
              value = other.instance_variable_get(variable)
              return false unless instance_variable_get(variable) == value
            end
            true
          end
        end
      end
    end
  end
end
