# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative 'resource_matcher'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class ResourceMatchers
              include AMA::Entity::Mapper::DSL

              type = [Enumerable, T: ResourceMatcher]
              attribute :content, type, virtual: true

              bound_type = self.bound_type

              denormalizer_block do |input, *|
                input = [input] if !input.is_a?(Enumerable) || input.is_a?(Hash)
                ResourceMatchers.new.tap do |entity|
                  entity.content = input
                end
              end

              normalizer_block do |entity, _, context|
                type = bound_type.attributes[:content].types.first
                type.normalizer.normalize(entity.content, type, context)
              end

              enumerator_block do |entity, _, context|
                type = bound_type.attributes[:content].types.first
                type.enumerator.enumerate(entity.content, type, context)
              end

              injector_block do |entity, _, attribute, val, ctx|
                type = bound_type.attributes[:content].types.first
                type.injector.inject(entity.content, type, attribute, val, ctx)
              end

              def initialize
                @content = []
              end
            end
          end
        end
      end
    end
  end
end
