# frozen_string_literal: true

require 'set'

require_relative '../mixin/entity'
require_relative 'policy'
require_relative 'privilege'

module AMA
  module Chef
    module User
      module Model
        # Represents Linux user group
        class Group
          include Mixin::Entity

          attribute :id, Symbol
          attribute :members, [Set, T: Symbol], default: Set.new
          attribute :privileges, [Hash, K: Symbol, V: Privilege], default: {}
          attribute :policy, Policy, default: Policy::NONE

          denormalizer_block do |input, type, context, &block|
            if input.is_a?(Hash) && [:id, 'id'].none? { |key| input.key?(key) }
              input[:id] = context.path.current.name
            end
            block.call(input, type, context)
          end

          def initialize(id = nil)
            @id = id
            @members = Set.new
            @privileges = {}
            @policy = Policy::NONE
          end

          def policy=(policy)
            @policy = Policy.wrap(policy)
          end

          # @param [Group] other
          def merge(other)
            raise 'Different ids' unless id == other.id
            members.merge(other.members)
            privileges.merge!(other.privileges)
            self.policy = [policy, other.policy].max
            self
          end

          def to_s
            "Group :#{id}"
          end
        end
      end
    end
  end
end
