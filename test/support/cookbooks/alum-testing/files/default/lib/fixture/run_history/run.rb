# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative 'resource_matchers'
require_relative 'assertions'

module AMA
  module Chef
    module User
      module Test
        module Fixture
          class RunHistory
            class Run
              include AMA::Entity::Mapper::DSL

              attribute :id, Integer, nullable: true
              attribute :clients, [Hash, K: Symbol, V: Model::Client], default: {}
              attribute :partitions, [Hash, K: Symbol, V: Model::Partition], default: {}
              attribute :resources, [Hash, K: Symbol, V: [Hash, K: Symbol, V: ResourceMatchers]], default: {}
              attribute :assertions, [Hash, K: Symbol, V: [Hash, K: Symbol, V: [Hash, K: Symbol, V: Assertions]]], default: {}

              def resource_matchers
                resources.values.flat_map do |resource_hash|
                  resource_hash.values.flat_map(&:content)
                end
              end

              def flat_assertions
                assertions.values.flat_map do |assertion_type|
                  assertion_type.values.flat_map do |assertion_name|
                    assertion_name.values.flat_map(&:content)
                  end
                end
              end

              def typed_assertions(type)
                flat_assertions.select do |assertion|
                  assertion.type == type
                end
              end
            end
          end
        end
      end
    end
  end
end
