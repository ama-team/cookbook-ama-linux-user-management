# frozen_string_literal: true

require 'ama-entity-mapper'

require_relative 'privilege'
require_relative 'partition/filter'
require_relative 'partition/policy_group'

module AMA
  module Chef
    module User
      module Model
        # Represents definition of client partition: how clients will be matched
        # and what would be done next
        class Partition
          include Mixin::Entity

          attribute :id, Symbol
          attribute :privileges, [Hash, K: Symbol, V: Privilege], default: {}
          attribute :filters, [Enumerable, T: Filter], default: []
          attribute :policy, PolicyGroup, default: PolicyGroup::DEFAULT
          attribute :impersonation, [Hash, K: Symbol, V: [:*, NilClass]]

          denormalizer_block do |input, type, context, &block|
            input = [context.path.current.name] if input.nil?
            if input.is_a?(Enumerable) && !input.is_a?(Hash)
              input = { filters: input }
            end
            if input.is_a?(Hash) && ['id', :id].none? { |key| input.key?(key) }
              input[:id] = context.path.current.name
            end
            block.call(input, type, context)
          end

          # @param [AMA::Chef::User::Model::Client] client
          def applies_to(client)
            filters.any? { |filter| filter.apply(client) }
          end

          def to_s
            "Partition #{id}"
          end
        end
      end
    end
  end
end
