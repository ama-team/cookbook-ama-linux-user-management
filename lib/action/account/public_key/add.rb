# frozen_string_literal: true

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PublicKey
            class Add < Action
              attr_accessor :account
              attr_accessor :key

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::PublicKey] public_key
              def initialize(account, public_key)
                @account = account
                @key = public_key
              end

              def apply(resource_factory)
                account = @account
                key = @key
                resource_factory.ssh_authorize_key key.full_id do
                  user account.id.to_s
                  key key.content
                  keytype key.type.to_s
                  comment "#{key.owner}:#{key.id}"
                  validate_key key.validate
                end
              end
            end
          end
        end
      end
    end
  end
end
