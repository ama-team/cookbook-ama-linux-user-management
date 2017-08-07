# frozen_string_literal: true

require_relative '../mixin/entity'
require_relative 'public_key'
require_relative 'private_key'
require_relative 'client/role_tree'

module AMA
  module Chef
    module User
      module Model
        # Represents external node client
        class Client
          include Mixin::Entity

          attribute :id, Symbol
          attribute :roles, RoleTree, default: RoleTree.new
          attribute :public_keys, [Hash, K: Symbol, V: PublicKey]
          attribute :private_keys, [Hash, K: Symbol, V: PrivateKey]

          def initialize(id = nil)
            @id = id
          end

          denormalizer_block do |input, type, context, &block|
            input = {} if input.nil?
            if input.is_a?(Hash) && ['id', :id].none? { |key| input.key?(key) }
              input[:id] = context.path.current.name
            end
            block.call(input, type, context)
          end

          def to_s
            "Client :#{id}"
          end
        end
      end
    end
  end
end
