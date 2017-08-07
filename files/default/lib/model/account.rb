# frozen_string_literal: true

require_relative '../mixin/entity'
require_relative 'policy'
require_relative 'public_key'
require_relative 'private_key'
require_relative 'privilege'

module AMA
  module Chef
    module User
      module Model
        # Depicts linux user account
        #
        # Private and public keys are stored in { owner => { owner keys } }
        # structure (grouped by effective owner).
        #
        # @!attribute id
        #   @return [Symbol]
        # @!attribute privileges
        #   @return [Hash{Symbol, Privilege}]
        # @!attribute public_keys
        #   @return [Hash{Symbol, Hash{Symbol, PublicKey}}]
        # @!attribute private_keys
        #   @return [Hash{Symbol, Hash{Symbol, PrivateKey}]
        # @!attribute policy
        #   @return [Symbol] :edit or :manage
        class Account
          include Mixin::Entity

          # rubocop:disable Metrics/LineLength
          attribute :id, Symbol
          attribute :privileges, [Hash, K: Symbol, V: Privilege], default: {}
          attribute :public_keys, [Hash, K: Symbol, V: [Hash, K: Symbol, V: PublicKey]], default: {}
          attribute :private_keys, [Hash, K: Symbol, V: [Hash, K: Symbol, V: PrivateKey]], default: {}
          attribute :policy, Policy, default: Policy::NONE
          # rubocop:enable Metrics/LineLength

          denormalizer_block do |input, type, context, &block|
            if input.is_a?(Hash) && [:id, 'id'].none? { |key| input.key?(key) }
              input[:id] = context.path.current.name
            end
            block.call(input, type, context)
          end

          def initialize(id = nil)
            @id = id
            @privileges = {}
            @public_keys = {}
            @private_keys = {}
            @policy = Policy::NONE
          end

          def policy=(policy)
            @policy = Policy.wrap(policy)
          end

          def public_keys!(client_id)
            public_keys[client_id] = {} unless public_keys.key?(client_id)
            public_keys[client_id]
          end

          def private_keys!(client_id)
            private_keys[client_id] = {} unless private_keys.key?(client_id)
            private_keys[client_id]
          end

          # rubocop:disable Metrics/AbcSize
          # @param [Account] other
          def merge(other)
            other.privileges.each do |type, privilege|
              privileges[type] = privilege unless privileges[type]
              privileges[type].options.merge!(privilege.options)
            end
            other.public_keys.each do |owner, keys|
              public_keys!(owner).merge!(keys)
            end
            other.private_keys.each do |owner, keys|
              private_keys!(owner).merge!(keys)
            end
            self.policy = [policy, other.policy].max
            self
          end
          # rubocop:enable Metrics/AbcSize

          def to_s
            "Account :#{id} { policy: :#{policy} }"
          end
        end
      end
    end
  end
end
