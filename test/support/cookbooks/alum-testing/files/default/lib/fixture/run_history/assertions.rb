# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative 'assertion'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class Assertions
              include Entity::Mapper::DSL

              type = [Enumerable, T: Assertion]
              attribute :content, type, default: [], virtual: true

              bound_type = self.bound_type

              denormalizer_block do |input, *|
                input = [input] if input.is_a?(String) || input.is_a?(Hash)
                Assertions.new.tap do |entity|
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

              def to_s
                "Assertions: #{content.map(&:to_def).join(', ')}"
              end
            end
          end
        end
      end
    end
  end
end
