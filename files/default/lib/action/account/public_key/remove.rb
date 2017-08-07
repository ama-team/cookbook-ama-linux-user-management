# frozen_string_literal: true

require_relative '../../../action'

module AMA
  module Chef
    module User
      class Action
        module Account
          module PublicKey
            class Remove < Action
              attr_accessor :account
              attr_accessor :key

              # @param [AMA::Chef::User::Model::Account] account
              # @param [AMA::Chef::User::Model::PublicKey] key
              def initialize(account, key)
                @account = account
                @key = key
              end

              def apply(*)
                noop
              end
            end
          end
        end
      end
    end
  end
end
